import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:openapi/api.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../notifier/theme_notifier.dart';

class LoginScan extends StatefulWidget {
  const LoginScan({super.key});

  static const path = 'account/login_scan';

  @override
  State<LoginScan> createState() => _LoginScanState();
}

class _LoginScanState extends State<LoginScan> {
  V1PassportLoginResp loginResp = V1PassportLoginResp();
  bool close = false;
  String url = '';

  load() async {
    final api = PassportApi(apiClient());
    try {
      var args = GUserLoginResp(authorization: loginResp.authorization);
      var res = await api.passportGetInfo(args);
      // if (res == null) load();
      if (res == null || toBool(res.isWait)) {
        load();
        return;
      }
      // if (!toBool(res.isWait)) Navigator.pop(context, res);
      if (!toBool(res.isWait)) Global.login(res.token!.accessToken!, res.user!);
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //登录成功
  // loginSuccess(String token, GUserModel user) async {
  //   await Global.setUser(user, setTPns: true);
  //   await Global.setToken(token);
  //   if (!mounted) return;
  //   Navigator.pushNamedAndRemoveUntil(context, Tabs.path, (route) => false);
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['loginResp'] != null) loginResp = args['loginResp'];
      if (mounted) {
        setState(() {
          load();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    close = true;
  }

  @override
  Widget build(BuildContext context) {
    url = createScanUrl(
        data: loginResp.authorization ?? '', type: 'authorization');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('扫码确认'.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage(assetPath('images/my/bg0.png')),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: createBody(),
        ),
      ),
    );
  }

  // 97 115 150
  Widget createBody() {
    var myColors = ThemeNotifier();
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 350,
            padding: const EdgeInsets.only(bottom: 50),
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //二维码
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: CustomPaint(
                        size: const Size.square(100),
                        painter: QrPainter(
                          //               data: json.encode({'imRoom': searchRoomId}),
                          data: Uri.decodeFull(url),
                          version: QrVersions.auto,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: Colors.black,
                          ),
                          // size: 320.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 15, right: 15),
                    child: Text(
                      '你正在不常用的ip地址/设备登陆，请用原设备或邀请好友扫描上方二维码确认登陆该设备'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: myColors.secondTextColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 80),
                  //   child: CircleButton(
                  //     width: 230,
                  //     height: 40,
                  //     title: '已授权',
                  //     onTap: load,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
