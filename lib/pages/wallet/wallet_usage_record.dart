import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../global.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/pager_box.dart';

class WalletUsage extends StatefulWidget {
  const WalletUsage({super.key});

  static const String path = 'wallet/usage';

  @override
  State<WalletUsage> createState() => _WalletUsageState();
}

class _WalletUsageState extends State<WalletUsage> {
  int limit = 20;
  List<GUserIntegralModel> _list = [];
  double integral = 0.0;
  bool showIntegral = false;

  _init() async {
    await Global.syncLoginUser();
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = UserApi(apiClient());
    try {
      var res = await api.userListUserIntegral(
        V1ListUserIntegralArgs(
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : _list.length.toString(),
          ),
        ),
      );
      if (res == null || !mounted) return 0;
      List<GUserIntegralModel> l = res.list.toList();
      setState(() {
        if (init) {
          _list = l;
        } else {
          _list.addAll(l);
        }
      });
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '历史记录'.tr(),
        ),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            Expanded(
              child: PagerBox(
                limit: limit,
                onInit: () async {
                  return await _getList(init: true);
                },
                onPullDown: () async {
                  return await _getList(init: true);
                },
                onPullUp: () async {
                  return await _getList();
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: _list.map((v) {
                        var status = '默认渠道'.tr();
                        var numberType = v.op == GSure.YES ? '+' : '-';
                        switch (v.userIntegralType) {
                          case GUserIntegralType.EXCHANGE_NUMBER:
                            status = '兑换靓号'.tr();
                            break;
                          case GUserIntegralType.INVITE:
                            status = '邀请'.tr();
                            break;
                          case GUserIntegralType.NIL:
                            break;
                          case GUserIntegralType.BUY_CHANGE_NICKNAME_CARD:
                            status = '兑换唯名卡'.tr();
                            break;
                          case GUserIntegralType.BUY_VIP:
                            status = '购买VIP'.tr();
                            break;
                          case GUserIntegralType.CARD_RECHARGE:
                            status = '卡密充值'.tr();
                            break;
                          case GUserIntegralType.BUY_ACCELERATE_CARD:
                            status = '兑换加速卡'.tr();
                            break;
                          case GUserIntegralType.BUY_RECHARGE:
                            status = '充值'.tr();
                            break;
                          case GUserIntegralType.GROWTH_VALUE:
                            status = '购买成长值'.tr();
                            break;
                          case GUserIntegralType.RECEIVE_RED:
                            status = '获得红包'.tr();
                            break;
                          case GUserIntegralType.REFUND_RED:
                            status = '红包退款'.tr();
                            break;
                          case GUserIntegralType.RENEW_NUMBER:
                            status = '靓号续费'.tr();
                            break;
                          case GUserIntegralType.SEND_RED:
                            status = '发红包'.tr();
                            break;
                          case GUserIntegralType.GIVE_RELIABLE:
                            status = '赠送靠谱草'.tr();
                            break;
                          case GUserIntegralType.ADMIN_CHANGE:
                            break;
                        }
                        return shadowBox(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 11),
                                    Text(
                                      time2date(v.createTime),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: myColors.subIconThemeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$numberType${v.integral}',
                                style: TextStyle(
                                  color: numberType == '-'
                                      ? myColors.red
                                      : myColors.iconThemeColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: myColors.isDark
            ? null
            : [
                BoxShadow(
                  color: myColors.bottomShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
