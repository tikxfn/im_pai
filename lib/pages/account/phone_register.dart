import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/phone_register_complete.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../notifier/theme_notifier.dart';

class PhoneRegister extends StatefulWidget {
  const PhoneRegister({super.key});

  static const String path = 'account/phone_register';

  @override
  State<StatefulWidget> createState() {
    return _PhoneRegisterState();
  }
}

class _PhoneRegisterState extends State<PhoneRegister> {
  Timer? _timer;
  bool getCode = false; //获取邮箱code状态
  late int time;
  String phoneNumber = '';
  TextEditingController phone = TextEditingController();
  TextEditingController code = TextEditingController();
  final TextEditingController _pasCtr = TextEditingController();
  final TextEditingController _rePasswordCtr = TextEditingController();
  V1CheckAccountResp? result;
  final double iconSize = 22;
  String? labelTextPassword;
  Color? labelColorPassword;
  bool passwordOk = false; //密码验证ok
  bool rePasswordOk = false; //密码验证ok
  bool showPassword = false;
  bool showPassword2 = false;
  String? labelTextRePassword;
  Color? labelColorRePassword;
  bool waitStatus = false; //发送等待

  //获取验证码
  countdown() async {
    if (phone.text == '') {
      tip('请输入手机号'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});
    final api = PassportApi(apiClient());

    try {
      await api.passportSendSms(V1SendSmsArgs(
        phone: phoneNumber,
        type: GSmsType.REGISTER,
      ));
      if (!mounted) return;
      if (mounted) {
        getCode = true;
        time = 60;
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time = time - 1;
          if (time == 0) {
            getCode = false;
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

  //下一步
  nextPage() async {
    if (!passwordOk || !rePasswordOk) {
      tipError('请检查填写信息'.tr());
      return;
    }
    final api = PassportApi(apiClient());
    try {
      await api.passportCheckSms(
        V1CheckSmsArgs(
          phone: phoneNumber.trim(),
          code: code.text.trim(),
          type: GSmsType.REGISTER,
        ),
      );
      if (!mounted) return;
      if (mounted) {
        Navigator.pushNamed(context, PhoneRegisterComplete.path, arguments: {
          'phoneNumber': phoneNumber.trim(),
          'code': code.text.trim(),
          'password': _pasCtr.text.trim(),
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    code.dispose();
    _pasCtr.dispose();
    _rePasswordCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: [
          //密码登录
          // _Textbutton(context),
          // title('手机注册'.tr()),
          // const SizedBox(height: 18),
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
              hintColor: myColors.imTextGrey1,
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
                      onTap: !getCode ? countdown : null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          !getCode
                              ? '获取验证码'.tr()
                              : '秒后重新获取'.tr(args: [time.toString()]),
                          style: TextStyle(
                            color: !getCode
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
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
            child: AppInputBox(
              controller: _rePasswordCtr,
              obscureText: !showPassword2,
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
                  color: myColors.subIconThemeColor,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
              labelText: labelTextRePassword,
              labelColor: labelColorRePassword,
              onChanged: (str) {
                if (str.length < 8 || str.contains(' ')) {
                  setState(() {
                    labelTextRePassword = '密码必须包含8个字符并且不能有空格'.tr();
                    labelColorRePassword = Colors.red;
                    rePasswordOk = false;
                  });
                } else if (str != _pasCtr.text) {
                  setState(() {
                    labelTextRePassword = '两次输入的密码不一致'.tr();
                    labelColorRePassword = Colors.red;
                    rePasswordOk = false;
                  });
                } else {
                  setState(() {
                    labelTextRePassword = '密码可用'.tr();
                    labelColorRePassword = Colors.green;
                    rePasswordOk = true;
                  });
                }
              },
              action: GestureDetector(
                onTap: () {
                  showPassword2 = !showPassword2;
                  setState(() {});
                },
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetPath(
                      showPassword2
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
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
            child: CircleButton(
              theme: AppButtonTheme.blue,
              title: '下一步'.tr(),
              onTap: nextPage,
              height: 43,
              fontSize: 17,
              radius: 10,
            ),
          ),
          if (platformPhone)
            Container(
              padding: const EdgeInsets.fromLTRB(44, 15, 44, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已有账号？'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: myColors.subIconThemeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '立即登陆'.tr(),
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
        ],
      ),
    );
  }
}
