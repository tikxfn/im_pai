import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/pages/account/forget_question_account.dart';
import 'package:unionchat/pages/account/forgot_help.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  static const path = 'account/forgot_password';

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final double iconSize = 22;
  Timer? _timer;
  final TextEditingController phone = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  String phoneNumber = '';
  String? labelTextPassword;
  Color? labelColorPassword;
  bool passwordOk = false; //密码验证ok
  bool getEmailCode = false; //获取邮箱code状态
  bool getPhoneCode = false; //获取手机code状态
  late int time;
  bool showPassword = false;
  bool phoneOrEmail = false; //true手机类型 、 false 邮箱类型
  String? labelTextEmail;
  Color? labelColorEmail;
  bool emailOK = false;
  bool waitStatus = false; //发送等待

  //重置密码
  updatePassword() async {
    if (phone.text.isEmpty) {
      tip(phoneOrEmail ? '请输入手机号'.tr() : '请输入邮箱号'.tr());
      return;
    }
    if (code.text == '') {
      tip('请输入验证码'.tr());
      return;
    }
    if (!passwordOk) {
      tip('请输入密码'.tr());
      return;
    }
    final api = PassportApi(apiClient());
    try {
      loading();
      await api.passportForget(
        V1ForgetArgs(
          value: phoneOrEmail ? phoneNumber.trim() : phone.text.trim(),
          code: code.text.trim(),
          password: newPassword.text.trim(),
          type: phoneOrEmail ? GForgetType.PHONE : GForgetType.EMAIL,
        ),
      );
      if (mounted) {
        tipSuccess('密码重置成功'.tr());
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      tipError(e.toString());
      onError(e);
    } finally {
      loadClose();
    }
  }

  //获取验证码
  countdown() async {
    if (phone.text.isEmpty) {
      tip(phoneOrEmail ? '请输入手机号'.tr() : '请输入邮箱号'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});

    if (phoneOrEmail) {
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
        type: GEmailType.FORGET,
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
        type: GSmsType.FORGET,
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
    } finally {
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        FocusManager.instance.primaryFocus?.unfocus();
        phone.text = '';
        phoneOrEmail = true;
        _timer?.cancel();
        getEmailCode = false;
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
        phone.text = '';
        phoneOrEmail = false;
        _timer?.cancel();
        getPhoneCode = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    code.dispose();
    newPassword.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, ForgetQuestionAccount.path);
            },
            child: Text(
              '密保找回'.tr(),
              style: TextStyle(
                color: myColors.blueTitle,
              ),
            ),
          ),
        ],
      ),
      body: KeyboardBlur(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                // flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //密码登录
                    // title(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(45, 35, 45, 35),
                      alignment: Alignment.centerLeft,
                      child: TabBar(
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
                            text: '邮箱重置'.tr(),
                          ),
                          Tab(
                            text: '手机重置'.tr(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          emailWidget(),
                          phoneWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget phoneWidget() {
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
              dropdownIconPosition: IconPosition.trailing,
              initialCountryCode: 'CN',
              invalidNumberMessage: '无效的电话号码'.tr(),
              cursorColor: myColors.iconThemeColor,
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
            hintColor: myColors.subIconThemeColor,
            keyboardType: TextInputType.number,
            hintText: '请输入验证码'.tr(),
            fontSize: 15,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
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
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: newPassword,
            obscureText: !showPassword,
            hintText: '新的密码'.tr(),
            hintColor: myColors.imTextGrey1,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            fontSize: 15,
            prefixIcon: Container(
              width: iconSize,
              height: iconSize,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: Image.asset(
                assetPath('images/login/pwd.png'),
                color: myColors.subIconThemeColor,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
            labelText: labelTextPassword,
            labelColor: labelColorPassword,
            onChanged: (str) {
              if (str.length < 8 || str.contains(' ')) {
                setState(() {
                  labelTextPassword = '密码必须包含8个字符并且不能有空格'.tr();
                  labelColorPassword = Colors.red;
                  passwordOk = false;
                });
              } else {
                setState(() {
                  labelTextPassword = '密码可用'.tr();
                  labelColorPassword = Colors.green;
                  passwordOk = true;
                });
              }
            },
            action: GestureDetector(
              onTap: () {
                showPassword = !showPassword;
                setState(() {});
              },
              child: Container(
                width: iconSize,
                height: iconSize,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: Image.asset(
                  assetPath(
                    showPassword
                        ? 'images/my/sp_yanjing.png'
                        : 'images/my/sp_biyan.png',
                  ),
                  color: myColors.subIconThemeColor,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
          child: CircleButton(
            theme: AppButtonTheme.primary,
            title: '重置密码'.tr(),
            onTap: updatePassword,
            height: 43,
            fontSize: 17,
            radius: 10,
          ),
        ),
        const SizedBox(height: 50),
        if (FunctionConfig.forgetFriendHelp)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: [
                Text(
                  '如果你没有绑定过手机号，可以点击下方邀请账号中的好友帮你找回账号',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: myColors.subIconThemeColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ForgetHelp.path);
                  },
                  child: Text(
                    '求助好友',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: myColors.blueTitle,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget emailWidget() {
    var myColors = context.watch<ThemeNotifier>();
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: phone,
            keyboardType: TextInputType.emailAddress,
            radius: 15,
            hintText: '请输入邮箱账号'.tr(),
            hintColor: myColors.imTextGrey1,
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
                  emailOK = false;
                  labelTextEmail = '请输入正确的邮箱'.tr();
                  labelColorEmail = Colors.red;
                });
              } else {
                setState(() {
                  emailOK = true;
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
            hintColor: myColors.subIconThemeColor,
            keyboardType: TextInputType.number,
            hintText: '请输入验证码'.tr(),
            fontSize: 15,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
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
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          child: AppInputBox(
            controller: newPassword,
            obscureText: !showPassword,
            hintText: '新的密码'.tr(),
            hintColor: myColors.imTextGrey1,
            color: myColors.chatInputColor,
            fontColor: myColors.iconThemeColor,
            fontSize: 15,
            prefixIcon: Container(
              width: iconSize,
              height: iconSize,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: Image.asset(
                assetPath('images/login/pwd.png'),
                color: myColors.subIconThemeColor,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
            labelText: labelTextPassword,
            labelColor: labelColorPassword,
            onChanged: (str) {
              if (str.length < 8 || str.contains(' ')) {
                setState(() {
                  labelTextPassword = '密码必须包含8个字符并且不能有空格'.tr();
                  labelColorPassword = Colors.red;
                  passwordOk = false;
                });
              } else {
                setState(() {
                  labelTextPassword = '密码可用'.tr();
                  labelColorPassword = Colors.green;
                  passwordOk = true;
                });
              }
            },
            action: GestureDetector(
              onTap: () {
                showPassword = !showPassword;
                setState(() {});
              },
              child: Container(
                width: iconSize,
                height: iconSize,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: Image.asset(
                  assetPath(
                    showPassword
                        ? 'images/my/sp_yanjing.png'
                        : 'images/my/sp_biyan.png',
                  ),
                  color: myColors.subIconThemeColor,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
          child: CircleButton(
            theme: AppButtonTheme.primary,
            title: '重置密码'.tr(),
            onTap: updatePassword,
            height: 43,
            fontSize: 17,
            radius: 10,
          ),
        ),
        const SizedBox(height: 50),
        if (FunctionConfig.forgetFriendHelp)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: [
                Text(
                  '如果你没有绑定过手机号，可以点击下方邀请账号中的好友帮你找回账号',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: myColors.subIconThemeColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ForgetHelp.path);
                  },
                  child: Text(
                    '求助好友',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: myColors.blueTitle,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  //标题
  title() {
    var myColors = ThemeNotifier();
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 17.5, left: 43.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            children: [
              Text(
                phoneOrEmail ? '手机重置'.tr() : '邮箱重置'.tr(),
                style: TextStyle(
                  fontSize: 22,
                  color: myColors.im2loginTextButton,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 30,
                height: 6,
                decoration: BoxDecoration(
                    color: myColors.im2loginTextButton,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              phoneOrEmail = !phoneOrEmail;
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                !phoneOrEmail ? '手机重置'.tr() : '邮箱重置'.tr(),
                style: TextStyle(
                  color: myColors.im2loginTextButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
