import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../global.dart';
import '../../notifier/theme_notifier.dart';

class GoodNumberRenew extends StatefulWidget {
  const GoodNumberRenew({super.key});

  static const String path = 'GoodNumber/renew';

  @override
  State<GoodNumberRenew> createState() => _GoodNumberRenewState();
}

class _GoodNumberRenewState extends State<GoodNumberRenew> {
  String vipIndex1 = '';
  int limit = 20;
  double integral = 0;
  double _selectPay = 0; //选择价格
  bool showIntegral = false;
  List<GProductServerModel> vipList = [];
  String userNumber = ''; //用户靓号
  String userNumberDueDate = ''; //用户靓号到期日
  bool waitStatus = false; //发送等待
  bool loadSuccess = false;

  _init() async {
    List<Future> futures = [
      Global.syncLoginUser(),
      _getVipPrice(),
    ];
    await Future.wait(futures);
    userNumber = (Global.user?.userNumber ?? '').isNotEmpty
        ? Global.user!.userNumber!
        : '';
    DateTime nowTime = DateTime.now();
    int dayStart = (nowTime.millisecondsSinceEpoch / 1000).floor();

    String dueDate = (Global.user?.userNumberEffectiveTime ?? '').isNotEmpty
        ? Global.user!.userNumberEffectiveTime!
        : '';
    if (dayStart < toInt(dueDate)) {
      userNumberDueDate = time2date(dueDate);
    } else {
      userNumberDueDate = '已到期';
    }
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    loadSuccess = true;
    setState(() {});
  }

  //获取价格
  _getVipPrice() async {
    var api = OrderApi(apiClient());
    try {
      var res = await api.orderListProductServer(
        V1ListProductServerArgs(
          type: GOrderType.RENEW_NUMBER,
        ),
      );
      if (res == null) return;
      List<GProductServerModel> l = [];
      for (var v in res.list) {
        if (v.type == GOrderType.RENEW_NUMBER) {
          l.add(v);
        }
      }
      vipList = l;
      logger.i(vipList);
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //兑换
  _submit() async {
    if (vipIndex1 == '') return;
    if (integral < _selectPay) {
      tip('可用余额不足'.tr());
      return;
    }
    confirm(
      context,
      title: '确定购买?'.tr(),
      onEnter: () async {
        loading();
        waitStatus = true;
        setState(() {});
        try {
          await OrderApi(apiClient()).orderSubmit(V1OrderSubmitArgs(
            number: '1',
            payType: OrderSubmitArgsPayType.INTEGRAL,
            shopId: vipIndex1,
            type: GOrderType.RENEW_NUMBER,
          ));
          if (!mounted) return;
          await _init();
          tipSuccess('兑换成功'.tr());
          if (mounted) waitStatus = false;
          setState(() {});
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
          waitStatus = false;
          setState(() {});
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '续费靓号'.tr(),
          ),
        ),
        body: buyInterface());
  }

  //购买界面
  Widget buyInterface() {
    var myColors = ThemeNotifier();
    return ThemeBody(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 17),
                        child: Image.asset(
                          assetPath('images/mall/id.png'),
                          width: 70,
                          height: 70,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          '靓号ID',
                          style: TextStyle(
                            fontSize: 15,
                            color: myColors.iconThemeColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          userNumber.isEmpty && loadSuccess
                              ? '你还没有靓号'.tr()
                              : userNumber,
                          style: TextStyle(
                            fontSize: userNumber.isEmpty ? 28 : 48,
                            color: myColors.iconThemeColor,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  if (userNumber.isNotEmpty && loadSuccess)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.5,
                            color: myColors.circleBorder,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '到期时间'.tr(),
                            style: TextStyle(
                              fontSize: 17,
                              color: myColors.iconThemeColor,
                            ),
                          ),
                          Text(
                            userNumber.isEmpty ? '' : userNumberDueDate,
                            style: TextStyle(
                              fontSize: 16,
                              color: myColors.subIconThemeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (userNumber.isNotEmpty && loadSuccess)
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 25),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            margin: const EdgeInsets.only(
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: myColors.vipBuySelectedBg,
                            ),
                          ),
                          Text(
                            '续费时长',
                            style: TextStyle(
                              fontSize: 17,
                              color: myColors.iconThemeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (userNumber.isNotEmpty && loadSuccess)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: vipList.map((e) {
                          return _vipSelect(e);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (userNumber.isNotEmpty)
            BottomButton(
              title: '立即购买'.tr(),
              onTap: vipIndex1 == '' || waitStatus
                  ? null
                  : () {
                      _submit();
                    },
              disabled: vipIndex1 == '' || waitStatus,
              fontSize: 19,
              waiting: waitStatus,
            ),
        ],
      ),
    );
  }

  //购买选择组件
  Widget _vipSelect(GProductServerModel e) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        if (vipIndex1 == e.id) {
          vipIndex1 = '';
          _selectPay = 0;
          setState(() {});
          return;
        }
        vipIndex1 = e.id ?? '';
        _selectPay = toDouble(e.integral);
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.fromLTRB(
          25,
          19,
          25,
          18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 2,
            color:
                e.id == vipIndex1 ? myColors.vipBuySelectedBg : myColors.grey0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              e.name ?? '',
              style: TextStyle(
                color: e.id == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.accountTagTitle,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Text(
              e.integral ?? '',
              style: TextStyle(
                color: e.id == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.iconThemeColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '派币'.tr(),
              style: TextStyle(
                color: e.id == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.subIconThemeColor,
                fontSize: 15,
                // fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
