import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/register_complete.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../notifier/theme_notifier.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  static const String path = 'account/register';

  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  // final TextEditingController _phoneCtr = TextEditingController();
  final TextEditingController _pasCtr = TextEditingController();
  final TextEditingController _rePasswordCtr = TextEditingController();
  // FocusNode focusNode = FocusNode();
  // String? labelTextPhone;
  String? labelTextPassword;
  // Color? labelColorPhone;
  Color? labelColorPassword;
  String? labelTextRePassword;
  Color? labelColorRePassword;
  String? labelTextEmail;
  Color? labelColorEmail;
  V1CheckAccountResp? result;
  bool isValidation = false; //用户名不可用
  // bool nameOk = false; //用户名验证ok
  bool passwordOk = false; //密码验证ok
  bool rePasswordOk = false; //密码验证ok
  final double iconSize = 22;
  bool showPassword1 = false;
  bool showPassword2 = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController code = TextEditingController();
  Timer? _timer;
  bool getCode = false; //获取邮箱code状态
  late int time;
  bool emailOK = false;
  bool waitStatus = false; //发送等待

  // @override
  // void initState() {
  //   super.initState();
  //   focusNode.addListener(() {
  //     if (!focusNode.hasFocus) {
  //       if (isValidation == true) isName();
  //     }
  //   });
  // }

  // //名字是是否可用
  // isName() async {
  //   if (_phoneCtr.text.isEmpty) return;
  //   final api = PassportApi(apiClient());
  //   try {
  //     final res = await api.passportCheckAccount(
  //       V1CheckAccountArgs(
  //         account: _phoneCtr.text,
  //       ),
  //     );
  //     if (res == null) return;
  //     logger.i(res);
  //     result = res;
  //     // ignore: unrelated_type_equality_checks
  //     if (result!.is_ == GSure.YES) {
  //       setState(() {
  //         labelTextPhone = '账号可以注册'.tr();
  //         labelColorPhone = Colors.green;
  //         nameOk = true;
  //       });
  //     } else {
  //       setState(() {
  //         labelTextPhone = '用户名不可用/或已被注册'.tr();
  //         labelColorPhone = Colors.red;
  //         nameOk = false;
  //       });
  //     }
  //     // if (!mounted) return;
  //   } on ApiException catch (e) {
  //     onError(e);
  //   } finally {}
  // }

  //获取验证码
  countdown() async {
    if (email.text.trim() == '' || !emailOK) {
      tip('请输入邮箱'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});
    final api = PassportApi(apiClient());

    try {
      await api.passportSendMail(V1SendMailArgs(
        email: email.text.trim(),
        type: GEmailType.REGISTER,
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
    if (passwordOk && rePasswordOk && emailOK) {
      final api = PassportApi(apiClient());
      try {
        await api.passportCheckMailCode(
          V1PassportCheckMailCodeArgs(
            email: email.text.trim(),
            code: code.text.trim(),
            type: GEmailType.REGISTER,
          ),
        );
        if (!mounted) return;
        if (mounted) {
          Navigator.pushNamed(context, RegisterComplete.path, arguments: {
            // 'account': _phoneCtr.text.trim(),
            'password': _pasCtr.text.trim(),
            'emil': email.text.trim(),
            'code': code.text.trim(),
          });
        }
      } on ApiException catch (e) {
        onError(e);
      } finally {}
    } else {
      tipError('请检查填写信息'.tr());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pasCtr.dispose();
    // _phoneCtr.dispose();
    _rePasswordCtr.dispose();
    email.dispose();
    code.dispose();
    // focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: ListView(
        // padding: const EdgeInsets.symmetric(horizontal: 40),
        children: [
          //密码登录
          // _Textbutton(context),
          // title('邮箱注册'.tr()),
          // const SizedBox(height: 18),
          // Container(
          //   padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          //   child: Row(
          //     children: [
          //       // const Icon(
          //       //   Icons.person_outline,
          //       //   color: myColors.loginText,
          //       // ),
          //       const SizedBox(
          //         width: 10,
          //       ),
          //       Text(
          //         '账号'.tr(),
          //         style: TextStyle(
          //           fontSize: 16,
          //           color: myColors.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 5),
          // Container(
          //   padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
          //   child: AppInputBox(
          //     controller: _phoneCtr,
          //     focusNode: focusNode,
          //     keyboardType: TextInputType.name,
          //     radius: 15,
          //     hintText: '请输入用户名'.tr(),
          //     hintColor: myColors.imTextGrey1,
          //     fontSize: 15,
          //     color: myColors.im2inputBox,
          //     fontColor: myColors.white,
          //     prefixIcon: Container(
          //       width: iconSize,
          //       height: iconSize,
          //       margin: const EdgeInsets.symmetric(horizontal: 5),
          //       alignment: Alignment.center,
          //       child: Image.asset(
          //         assetPath('images/login/user.png'),
          //         color: myColors.imTextGrey1,
          //         width: iconSize,
          //         height: iconSize,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //     labelText: labelTextPhone,
          //     labelColor: labelColorPhone,
          //     onChanged: (str) {
          //       if (str != '' && !accountFormat(str)) {
          //         setState(() {
          //           labelTextPhone = '以字母开头，4~16位数字字母下划线'.tr();
          //           labelColorPhone = Colors.red;
          //           isValidation = false;
          //           nameOk = false;
          //         });
          //       } else {
          //         setState(() {
          //           labelTextPhone = null;
          //           labelColorPhone = null;
          //           isValidation = true;
          //         });
          //       }
          //     },
          //   ),
          // ),
          // const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
            child: AppInputBox(
              controller: email,
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
                      onTap: !getCode ? countdown : null,
                      child: Container(
                        padding: const EdgeInsets.only(right: 8.0),
                        height: 35,
                        alignment: Alignment.center,
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
              obscureText: !showPassword1,
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
                  showPassword1 = !showPassword1;
                  setState(() {});
                },
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetPath(
                      showPassword1
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
