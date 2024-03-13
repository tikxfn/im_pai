import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class GoodNumberBuy extends StatefulWidget {
  const GoodNumberBuy({super.key});

  static const String path = 'GoodNumberBuy/page';

  @override
  State<GoodNumberBuy> createState() => _GoodNumberBuyState();
}

class _GoodNumberBuyState extends State<GoodNumberBuy> {
  var currentTitle = '';
  GUserNumberModel? data;
  bool loadSuccess = false; //加载完成
  bool waitStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['currentTitle'] != null) currentTitle = args['currentTitle'];
      if (args['data'] != null) data = args['data'];

      if (mounted) setState(() {});
    });
  }

  //兑换靓号的接口
  _requestDataToExchange() async {
    loading();
    waitStatus = true;
    setState(() {});
    try {
      await UserNumberApi(apiClient()).userNumberSetUserNumber(
          V1SetUserNumberArgs(userNumberId: currentTitle));
      tipSuccess('兑换成功'.tr());
      if (mounted) {
        waitStatus = false;
        setState(() {});
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;

    return Scaffold(
        appBar: AppBar(
          title: Text('靓号详情'.tr()),
        ),
        body: buyInterface(textColor));
  }

  //购买界面
  Widget buyInterface(Color textColor) {
    var myColors = ThemeNotifier();
    return ThemeBody(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Image.asset(
                assetPath('images/mall/id.png'),
                width: 70,
                height: 70,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 19),
              child: Text(
                '靓号ID',
                style: TextStyle(
                  fontSize: 15,
                  color: myColors.iconThemeColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                data?.uid ?? '',
                style: TextStyle(
                  fontSize: 48,
                  color: myColors.iconThemeColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                    '靓号价格',
                    style: TextStyle(
                      fontSize: 17,
                      color: myColors.iconThemeColor,
                    ),
                  ),
                  Text(
                    '${data?.integral ?? ''}派币',
                    style: TextStyle(
                      fontSize: 16,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                    '靓号赠送',
                    style: TextStyle(
                      fontSize: 17,
                      color: myColors.iconThemeColor,
                    ),
                  ),
                  Text(
                    '永久靓号服务',
                    style: TextStyle(
                      fontSize: 16,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                    '靓号权限',
                    style: TextStyle(
                      fontSize: 17,
                      color: myColors.iconThemeColor,
                    ),
                  ),
                  Text(
                    '每月需续费',
                    style: TextStyle(
                      fontSize: 16,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                  Row(
                    children: [
                      Image.asset(
                        assetPath('images/mall/youhuijuan.png'),
                        width: 27,
                        height: 25,
                        fit: BoxFit.contain,
                        color: Colors.grey,
                        colorBlendMode: BlendMode.color,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '选择优惠券',
                        style: TextStyle(
                          fontSize: 17,
                          color: myColors.textGrey,
                          // color: myColors.iconThemeColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right_outlined,
                    size: 30,
                    color: myColors.textGrey,
                    // color: myColors.subIconThemeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CircleButton(
              waiting: waitStatus,
              title: '兑换靓号'.tr(),
              onTap: () {
                _requestDataToExchange();
              },
              fontSize: 19,
              height: 47,
              radius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
