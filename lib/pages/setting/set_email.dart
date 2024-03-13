import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class SetEmail extends StatefulWidget {
  const SetEmail({super.key});

  static const path = 'setEmail/home';

  @override
  State<SetEmail> createState() => _SetEmailState();
}

class _SetEmailState extends State<SetEmail> {
  final double iconSize = 30;
  Timer? _timer;
  final TextEditingController email = TextEditingController();
  TextEditingController code = TextEditingController();
  bool getCode = false;
  late int time;
  String? labelTextEmail;
  Color? labelColorEmail;
  bool emailOK = false;
  bool waitStatus = false; //发送等待

  //绑定邮箱
  void submmitTo() async {
    if (email.text == '') {
      tip('请输入邮箱号'.tr());
      return;
    }
    if (code.text == '') {
      tip('请输入验证码'.tr());
      return;
    }
    final api = UserApi(apiClient());
    try {
      loading();
      await api.userBindEmail(V1BindEmailArgs(
        email: email.text.trim(),
        code: code.text,
      ));
      await Global.syncLoginUser();
      if (mounted) {
        tipSuccess('邮箱绑定成功'.tr());
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      tipError('保存异常'.tr());
      onError(e);
    } finally {
      loadClose();
    }
  }

  // //取消绑定
  // void cancelPhone() async {
  //   var cfm = await confirm(
  //     context,
  //     title: '解绑手机',
  //     content:
  //         '确定要解绑当前已经绑定的手机号？解绑后将无法使用${Global.user?.phone ?? '该手机号'}进行登录，请谨慎操作！',
  //   );
  //   if (cfm != true) return;
  //   final api = UserApi(apiClient());
  //   try {
  //     loading();
  //     await api.userCancelBindPhone({});
  //     await Global.loginUser();
  //     if (mounted) {
  //       tipSuccess('手机号解绑成功'.tr());
  //       Navigator.pop(context);
  //     }
  //   } on ApiException catch (e) {
  //     onError(e);
  //   } finally {
  //     loadClose();
  //   }
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
        type: GEmailType.BIND,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['email'] != null) {
        email.text = args['email'];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    code.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color inputColor = myColors.chatInputColor;
    return Scaffold(
      backgroundColor: myColors.themeBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: KeyboardBlur(
        child: Center(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 27.5, left: 43.5),
                child: Text(
                  '绑定新的邮箱'.tr(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                child: AppInputBox(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  radius: 15,
                  hintText: '请输入邮箱号'.tr(),
                  hintColor: myColors.imTextGrey1,
                  fontSize: 15,
                  color: inputColor,
                  fontColor: textColor,
                  prefixIcon: Container(
                    width: iconSize,
                    height: iconSize,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.email_outlined,
                      color: myColors.textGrey1,
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
              const SizedBox(
                height: 40,
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                child: AppInputBox(
                  controller: code,
                  color: inputColor,
                  hintColor: myColors.imTextGrey1,
                  keyboardType: TextInputType.number,
                  hintText: '请输入验证码'.tr(),
                  fontSize: 15,
                  fontColor: textColor,
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
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                child: CircleButton(
                  theme: AppButtonTheme.blue,
                  title: '完成'.tr(),
                  onTap: submmitTo,
                  fontSize: 16,
                  height: 41,
                  radius: 10,
                ),
              ),
              // if ((Global.user?.email ?? '').isNotEmpty)
              //   Container(
              //     padding: const EdgeInsets.fromLTRB(44, 10, 44, 0),
              //     child: CircleButton(
              //       theme: AppButtonTheme.red,
              //       title: '解绑当前已绑定的手机号'.tr(),
              //       onTap: cancelPhone,
              //       height: 41,
              //       radius: 15,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
