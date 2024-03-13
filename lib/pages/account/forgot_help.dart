import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/new_pwd.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:openapi/api.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../notifier/theme_notifier.dart';

class ForgetHelp extends StatefulWidget {
  const ForgetHelp({super.key});

  static const path = 'account/friend_help';

  @override
  State<ForgetHelp> createState() => _ForgetHelpState();
}

class _ForgetHelpState extends State<ForgetHelp> {
  bool showAccount = true; //显示输入账号
  TextEditingController accountCtr = TextEditingController();
  final double iconSize = 22;
  String loginToken = '';
  bool close = false;
  String url = '';

  getScan() async {
    final api = PassportApi(apiClient());
    try {
      var args =
          V1PassportApplyAssistLoginArgs(account: accountCtr.text.trim());
      var res = await api.passportApplyAssistLogin(args);
      if (res == null) return;
      FocusManager.instance.primaryFocus?.unfocus();
      if (mounted) {
        setState(() {
          loginToken = res.token ?? '';
          showAccount = false;
        });
      }
      if (mounted) load();
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取结果
  load() async {
    if (close) return;
    logger.i('${accountCtr.text.trim()}----$loginToken');
    final api = PassportApi(apiClient());
    try {
      var args = V1PassportAssistFriendLoginArgs(
          account: accountCtr.text.trim(), token: loginToken);
      var res = await api.passportGetAssistLogin(args);
      if (res == null || res.assistList.length < 3) {
        load();
        return;
      }
      if (res.assistList.length >= 3) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, NewPasswordPage.path, arguments: {
          'loginToken': loginToken,
          'account': accountCtr.text.trim(),
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void dispose() {
    super.dispose();
    accountCtr.dispose();
    close = true;
  }

  @override
  Widget build(BuildContext context) {
    url = createScanUrl(
        data: '$loginToken,${accountCtr.text.trim()}', type: 'helpFriend');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '找回密码'.tr(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: KeyboardBlur(
        child: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/my/scan_bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: showAccount
              ? accountWidget()
              : Center(
                  child: createBody(),
                ),
        ),
      ),
    );
  }

  //输入账号
  Widget accountWidget() {
    var myColors = ThemeNotifier();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                '请输入需要找回的账号'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: accountCtr,
            keyboardType: TextInputType.name,
            radius: 15,
            hintText: '请输入用户名'.tr(),
            hintColor: myColors.subIconThemeColor,
            fontSize: 15,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            prefixIcon: Container(
              width: iconSize,
              height: iconSize,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: Image.asset(
                assetPath('images/login/user.png'),
                color: myColors.subIconThemeColor,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
          child: CircleButton(
            theme: AppButtonTheme.blue,
            title: '确定'.tr(),
            onTap: () {
              if (accountCtr.text.trim() == '') return;
              getScan();
              setState(() {});
            },
            height: 43,
            fontSize: 17,
            radius: 10,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // 二维码
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
                          data: Uri.decodeFull(url),

                          version: QrVersions.auto,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: myColors.grey,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: myColors.grey,
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
                      '求助你账号中的好友，扫描上方二维码，辅助你找回密码'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: myColors.secondTextColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
