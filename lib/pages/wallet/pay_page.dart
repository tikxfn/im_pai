import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPage extends StatefulWidget {
  final String amount;
  final Function()? over;

  const PayPage({
    super.key,
    required this.amount,
    this.over,
  });

  static const String path = 'pay/page';

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> with WidgetsBindingObserver {
  int payIndex = 0;
  bool _morePay = false;
  bool _paying = false;
  List<GProductServerModel> vipList = [];
  List<VipPayType> payList = [
    VipPayType(
      title: '支付宝'.tr(),
      image: 'images/vip/sp_zhifubaozhifu.png',
      type: GPaymentChannelPayType.ALIPAY,
    ),
    VipPayType(
      title: '微信'.tr(),
      image: 'images/vip/sp_weixingzhifu.png',
      type: GPaymentChannelPayType.WE_CHAT,
    ),
    VipPayType(
      title: '卡密支付'.tr(),
      image: 'images/vip/sp_kamizhifu.png',
    ),
  ];

  // 下单
  _pay() async {
    loading();
    var api = UserBuyIntegralApi(apiClient());
    try {
      var args = V1UserBuyIntegralBuyArgs(
        amount: widget.amount,
        ptype: payList[payIndex].type,
      );
      logger.d(args);
      var res = await api.userBuyIntegralBuy(args);
      if (res == null || (res.payUrl ?? '').isEmpty) return;
      var uri = Uri.parse(res.payUrl ?? '');
      launchUrl(uri, mode: LaunchMode.externalApplication);
      _paying = true;
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.d(e);
    } finally {
      loadClose();
    }
  }

  //卡密支付跳转
  camiPay() async {
    loading();
    try {
      await Global.getSystemInfo();
      var settingUrl = Global.systemInfo.settingUrl;
      if (settingUrl?.settingUrl?.mallUrl == null || !mounted) {
        return;
      }
      var uri = Uri.parse(settingUrl?.settingUrl?.mallUrl ?? '');
      launchUrl(uri, mode: LaunchMode.externalApplication);
      _paying = true;
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.d(e);
    } finally {
      loadClose();
    }
  }

  // 支付列表组件
  Widget _payItem({
    required VipPayType data,
    bool active = false,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(assetPath(data.image), width: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            AppCheckbox(value: active),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _paying) widget.over?.call();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.white,
      appBar: AppBar(title: const Text('支付订单')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 100),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '确定支付：'.tr(),
                  ),
                  TextSpan(
                    text: '￥${api2number(widget.amount)}',
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Column(
                  children: payList.map((v) {
                    var i = payList.indexOf(v);
                    if (i > 0 && !_morePay) return Container();
                    return _payItem(
                      data: v,
                      active: v == payList[payIndex],
                      onTap: () {
                        payIndex = payList.indexOf(v);
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _morePay = !_morePay;
                    });
                  },
                  child: SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '更多支付方式',
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          _morePay
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: myColors.lineGrey,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: CircleButton(
              title: '确定支付'.tr(),
              height: 45,
              fontSize: 15,
              radius: 15,
              onTap: payIndex != 2 ? _pay : camiPay,
            ),
          ),
        ],
      ),
    );
  }
}

//支付类型
class VipPayType {
  String title;
  String image;
  GPaymentChannelPayType? type;

  VipPayType({
    required this.title,
    required this.image,
    this.type,
  });
}
