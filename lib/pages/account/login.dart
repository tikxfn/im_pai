import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/account/forgot_password.dart';
import 'package:unionchat/pages/account/login_scan.dart';
import 'package:unionchat/pages/account/phone_login.dart';
import 'package:unionchat/pages/account/register_all.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../setting/setting_language.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const String path = 'account/login';

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController _accountCtr = TextEditingController();
  final TextEditingController _pasCtr = TextEditingController();
  final double iconSize = 22;
  int time = 0;
  Timer? _timer;
  String accountName = '';
  bool showPassword = false;

  @override
  void dispose() {
    super.dispose();
    _pasCtr.dispose();
    _accountCtr.dispose();
    _timer?.cancel();
  }

  //登录成功
  // loginSuccess(String token, GUserModel user) async {
  //   await Global.setUser(user, setTPns: true);
  //   await Global.setToken(token);
  //   if (!mounted) return;
  //   if (toBool(Global.user!.enablePin) && toBool(Global.user!.isPin)) {
  //     Navigator.pushNamedAndRemoveUntil(
  //         context, LockEnter.path, (route) => false);
  //     return;
  //   }
  //   Navigator.pushNamedAndRemoveUntil(context, Tabs.path, (route) => false);
  // }

  // 登录确认
  loginConfirm(V1PassportLoginResp loginResp) async {
    // var result = await
    Navigator.pushNamed(context, LoginScan.path,
        arguments: {'loginResp': loginResp});
    // var res = result as V1PassportLoginResp;
    // logger.i(res);
    // // var res = await ApiRequest.loginConfirm(context, loginResp);
    // if (res == null) return;
    // if (toBool(res.isWait)) {
    //   loginConfirm(loginResp);
    // } else {
    //   loginSuccess(res.token!.accessToken!, res.user!);
    // }
  }

  //登录
  login({bool guest = false}) async {
    if (accountName == _accountCtr.text && time > 0) {
      tipError('输入3次错误密码后，请后尝试重新登陆'.tr(args: [second2minute2(time)]));
      return;
    }
    // logger.i(_pasCtr.text.trim());
    // logger.i(_pasCtr.text.length);
    final api = PassportApi(apiClient());
    loading();
    try {
      var args = V1LoginByAccountArgs(
        account: _accountCtr.text.trim(),
        password: _pasCtr.text.trim(),
      );
      V1PassportLoginResp? res;
      if (guest) {
        res = await api.passportLoginByTourist({});
      } else {
        res = await api.passportLoginByAccount(args);
      }
      if (res == null) return;
      if (toBool(res.isPwdError)) {
        accountName = _accountCtr.text;
        time = toInt(res.pwdErrorWaitTime);
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time = time - 1;
          if (time == 0) {
            _timer?.cancel();
          }
          setState(() {});
        });
        tipError('输入3次错误密码后，请后尝试重新登陆'
            .tr(args: [second2minute2(toInt(res.pwdErrorWaitTime))]));
        return;
      }
      if (toBool(res.isWait)) {
        loginConfirm(res);
      } else {
        Global.login(res.token!.accessToken!, res.user!);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    //初始化openinstall
    OpeninstallFlutterPlugin().init((Map<String, dynamic> data) async {});
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    logger.i(Global.isAddAccount);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: KeyboardBlur(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Adapter.isWideScreen ? 500 : 700,
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      // padding: const EdgeInsets.symmetric(horizontal: 40),
                      children: [
                        //密码登录
                        // _textButton(context),

                        Container(
                          padding: const EdgeInsets.fromLTRB(45, 70, 45, 42),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                assetPath('images/login/logo.png'),
                                width: 43,
                                height: 43,
                                fit: BoxFit.contain,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 19,
                                  bottom: 13,
                                ),
                                child: Text(
                                  '你好'.tr(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: myColors.iconThemeColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                '欢迎使用「派聊」'.tr(),
                                style: TextStyle(
                                  fontSize: 23,
                                  color: myColors.iconThemeColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                          child: AppInputBox(
                            controller: _accountCtr,
                            keyboardType: TextInputType.name,
                            radius: 15,
                            hintText: '请输入账号/邮箱'.tr(),
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
                                color: myColors.imTextGrey1,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 19,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                          child: AppInputBox(
                            controller: _pasCtr,
                            obscureText: !showPassword,
                            hintText: '请输入密码'.tr(),
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
                                assetPath('images/login/pwd.png'),
                                color: myColors.imTextGrey1,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                            action: GestureDetector(
                              onTap: () {
                                showPassword = !showPassword;
                                setState(() {});
                              },
                              child: Container(
                                width: iconSize,
                                height: iconSize,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  assetPath(
                                    showPassword
                                        ? 'images/my/sp_yanjing.png'
                                        : 'images/my/sp_biyan.png',
                                  ),
                                  color: myColors.imTextGrey1,
                                  width: iconSize,
                                  height: iconSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 50, right: 50, top: 15, bottom: 19),
                          child: Row(
                            mainAxisAlignment: FunctionConfig.guestLogin
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.end,
                            children: [
                              if (FunctionConfig.guestLogin)
                                GestureDetector(
                                  onTap: () {
                                    login(guest: true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      '游客登录'.tr(),
                                      style: TextStyle(
                                        color: myColors.blueTitle,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ForgotPassword.path);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    '忘记密码'.tr(),
                                    style: TextStyle(
                                      color: myColors.blueTitle,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                          child: CircleButton(
                            theme: AppButtonTheme.blue,
                            title: '登录'.tr(),
                            onTap: login,
                            height: 43,
                            fontSize: 17,
                            radius: 10,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.fromLTRB(44, 15, 44, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (FunctionConfig.phoneAccount)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      PhoneLogin.path,
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '验证码登录'.tr(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Container(
                                width: 1,
                                height: 13,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                color: const Color(0xFFEEEEEE),
                              ),
                              if (platformPhone)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RegisterAll.path,
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '新用户注册'.tr(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (Global.isAddAccount)
                          Container(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: Global.closeAddAccount,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                child: Text(
                                  '关闭'.tr(),
                                  style: TextStyle(
                                    color: myColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 47),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pushNamed(context, SettingLanguage.path);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '语言'.tr().toUpperCase(),
                            style: const TextStyle(),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
