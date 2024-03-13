import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:openapi/api.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:unionchat/pages/account/login_scan.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../setting/setting_language.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  static const String path = 'account/phone_login';

  @override
  State<StatefulWidget> createState() {
    return _PhoneLoginState();
  }
}

class _PhoneLoginState extends State<PhoneLogin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  bool getEmailCode = false; //获取邮箱code状态
  bool getPhoneCode = false; //获取手机code状态
  late int time;
  String phoneNumber = '';
  final TextEditingController phone = TextEditingController();
  final TextEditingController code = TextEditingController();
  bool phoneLogin = false; //是否手机登录
  final double iconSize = 22;
  String? labelTextEmail;
  Color? labelColorEmail;
  bool waitStatus = false; //发送等待

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
    // var result =await
    Navigator.pushNamed(context, LoginScan.path,
        arguments: {'loginResp': loginResp});
    // var res = result as V1PassportLoginResp;
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
    final api = PassportApi(apiClient());
    loading();
    logger.i(phoneNumber);
    logger.i(code.text);
    try {
      var args = V1PassportLoginByPhoneArgs(
        phone: phoneNumber.trim(),
        code: code.text.trim(),
      );
      V1PassportLoginResp? res;
      if (guest) {
        res = await api.passportLoginByTourist({});
      } else {
        res = await api.passportLoginByPhone(args);
      }
      if (res == null) return;
      if (toBool(res.isPwdError)) {
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

  //登录
  emailLogin({bool guest = false}) async {
    final api = PassportApi(apiClient());
    loading();
    try {
      var args = V1PassportEmailLoginArgs(
        email: phone.text.trim(),
        code: code.text.trim(),
      );
      V1PassportLoginResp? res;
      if (guest) {
        res = await api.passportLoginByTourist({});
      } else {
        res = await api.passportEmailLogin(args);
      }
      if (res == null) return;
      if (toBool(res.isPwdError)) {
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

  //获取验证码
  countdown() async {
    if (phone.text.isEmpty) {
      tip('请检查填写信息'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});
    if (phoneLogin) {
      await phoneCode();
    } else {
      await emailCode();
    }
    waitStatus = false;
    setState(() {});
  }

  //邮箱验证码
  emailCode() async {
    final api = PassportApi(apiClient());
    try {
      await api.passportSendMail(V1SendMailArgs(
        email: phone.text.trim(),
        type: GEmailType.LOGIN,
      ));
      if (!mounted) return;
      if (mounted) {
        waitStatus = false;
        getEmailCode = true;
        time = 60;
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time = time - 1;
          if (time == 0) {
            getEmailCode = false;
            _timer?.cancel();
          }
          setState(() {});
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      waitStatus = false;
      setState(() {});
    }
  }

  //手机验证码
  phoneCode() async {
    final api = PassportApi(apiClient());
    try {
      await api.passportSendSms(V1SendSmsArgs(
        phone: phoneNumber,
        type: GSmsType.LOGIN,
      ));
      if (!mounted) return;
      if (mounted) {
        waitStatus = false;
        getPhoneCode = true;
        time = 60;
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time = time - 1;
          if (time == 0) {
            getPhoneCode = false;
            _timer?.cancel();
          }
          setState(() {});
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    //初始化openinstall
    OpeninstallFlutterPlugin().init((Map<String, dynamic> data) async {});
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        FocusManager.instance.primaryFocus?.unfocus();
        phone.text = '';
        _timer?.cancel();
        phoneLogin = true;
        getEmailCode = false;
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
        phone.text = '';
        _timer?.cancel();
        phoneLogin = false;
        getPhoneCode = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    code.dispose();
    _timer?.cancel();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: KeyboardBlur(
        child: Container(
          width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(45, 70, 45, 0),
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
                            '欢迎使用「派聊」'.tr(),
                            style: TextStyle(
                              fontSize: 23,
                              color: myColors.iconThemeColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        TabBar(
                            controller: _tabController,
                            indicatorColor: myColors.circleBlueButtonBg,
                            isScrollable: true,
                            // indicator:
                            //     const BoxDecoration(color: Colors.transparent),
                            indicatorWeight: 3.0,
                            labelColor: myColors.iconThemeColor,
                            labelStyle: const TextStyle(
                              height: 1,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelColor: myColors.textGrey,
                            unselectedLabelStyle:
                                const TextStyle(fontSize: 16, height: 1),
                            tabs: [
                              Tab(
                                text: '邮箱登录'.tr(),
                              ),
                              Tab(
                                text: '手机登录'.tr(),
                              ),
                            ]),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        emailLoginWidget(),
                        phoneLoginWidget(),
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

  //手机登录
  Widget phoneLoginWidget() {
    var myColors = context.watch<ThemeNotifier>();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: myColors.chatInputColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: IntlPhoneField(
              controller: phone,
              showCountryFlag: false,
              disableLengthCheck: true,
              cursorColor: myColors.iconThemeColor,
              dropdownIconPosition: IconPosition.trailing,
              initialCountryCode: 'CN',
              invalidNumberMessage: '无效的电话号码'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: myColors.iconThemeColor,
              ),
              dropdownTextStyle: TextStyle(
                color: myColors.subIconThemeColor,
              ),
              decoration: InputDecoration(
                helperStyle: const TextStyle(fontSize: 11),
                errorStyle: const TextStyle(fontSize: 11),
                hintText: '请输入手机号码'.tr(),
                hintStyle: TextStyle(
                  color: myColors.subIconThemeColor,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 10,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              languageCode: context.locale.languageCode,
              onChanged: (phone) {
                phoneNumber = phone.completeNumber;
              },
            ),
          ),
        ),
        const SizedBox(height: 19),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: code,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            hintColor: myColors.subIconThemeColor,
            keyboardType: TextInputType.number,
            hintText: '请输入验证码'.tr(),
            fontSize: 15,
            action: waitStatus
                ? const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CupertinoActivityIndicator(radius: 10),
                  )
                : GestureDetector(
                    onTap: !getPhoneCode ? countdown : null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        !getPhoneCode
                            ? '获取验证码'.tr()
                            : '秒后重新获取'.tr(args: [time.toString()]),
                        style: TextStyle(
                          color: !getPhoneCode
                              ? myColors.blueTitle
                              : myColors.subIconThemeColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
          child: CircleButton(
            theme: AppButtonTheme.blue,
            title: '登录'.tr(),
            onTap: phoneLogin ? login : emailLogin,
            height: 43,
            fontSize: 17,
            radius: 10,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 25, 44, 0),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, Login.path);
            },
            child: Text(
              '账号密码登录'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: myColors.blueTitle,
              ),
            ),
          ),
        ),
        if (Global.isAddAccount)
          Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: Global.closeAddAccount,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    color: myColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  //邮箱登录
  Widget emailLoginWidget() {
    var myColors = context.watch<ThemeNotifier>();
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: phone,
            keyboardType: TextInputType.emailAddress,
            radius: 15,
            hintText: '请输入邮箱号'.tr(),
            hintColor: myColors.subIconThemeColor,
            fontSize: 15,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            prefixIcon: Container(
              width: iconSize,
              height: iconSize,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: Icon(
                Icons.email_outlined,
                color: myColors.subIconThemeColor,
              ),
            ),
            labelText: labelTextEmail,
            labelColor: labelColorEmail,
            onChanged: (str) {
              if (str != '' && !isEmail(str)) {
                setState(() {
                  labelTextEmail = '请输入正确的邮箱'.tr();
                  labelColorEmail = Colors.red;
                });
              } else {
                setState(() {
                  labelTextEmail = null;
                  labelColorEmail = null;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 19),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: code,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            hintColor: myColors.subIconThemeColor,
            keyboardType: TextInputType.number,
            hintText: '请输入验证码'.tr(),
            fontSize: 15,
            action: waitStatus
                ? const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CupertinoActivityIndicator(radius: 10),
                  )
                : GestureDetector(
                    onTap: !getEmailCode ? countdown : null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        !getEmailCode
                            ? '获取验证码'.tr()
                            : '秒后重新获取'.tr(args: [time.toString()]),
                        style: TextStyle(
                          color: !getEmailCode
                              ? myColors.blueTitle
                              : myColors.subIconThemeColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
          child: CircleButton(
            theme: AppButtonTheme.blue,
            title: '登录'.tr(),
            onTap: phoneLogin ? login : emailLogin,
            height: 43,
            fontSize: 17,
            radius: 10,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 25, 44, 0),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, Login.path);
            },
            child: Text(
              '账号密码登录'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: myColors.blueTitle,
              ),
            ),
          ),
        ),
        if (Global.isAddAccount)
          Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: Global.closeAddAccount,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    color: myColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
