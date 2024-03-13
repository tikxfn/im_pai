import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/pager_box.dart';

class VipHistory extends StatefulWidget {
  const VipHistory({super.key});

  static const String path = 'vip/history';

  @override
  State<VipHistory> createState() => _VipHistoryState();
}

class _VipHistoryState extends State<VipHistory> {
  int limit = 20;
  List<GUserVipLogModel> _list = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = OrderApi(apiClient());
    try {
      final res = await api.orderVipLog(
        {},
        // V1ListUseCardArgs(
        //   pager: GPagination(
        //     limit: limit.toString(),
        //     offset: init ? '0' : _list.length.toString(),
        //   ),
        // ),
      );
      if (res == null || !mounted) return 0;
      List<GUserVipLogModel> l = res.list.toList();
      logger.i(res.list);
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
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('购买记录'.tr()),
      ),
      body: ThemeBody(
        topPadding: 0,
        child: PagerBox(
          padding: const EdgeInsets.all(15),
          limit: limit,
          onInit: () async {
            return await _getList(init: true);
          },
          onPullDown: () async {
            return await _getList(init: true);
          },
          // onPullUp: () async {
          //   return await _getList();
          // },
          children: _list.map((v) {
            logger.i(v.systemEffectiveTime);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: myColors.lineGrey,
                    width: .5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        v.shopName ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time2date(v.createTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: myColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: myColors.vipName,
                      ),
                      children: [
                        TextSpan(
                          text: '到期时间：'.tr(args: ['']),
                        ),
                        TextSpan(text: time2date(v.effectiveTime)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
