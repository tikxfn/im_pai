import 'package:easy_localization/easy_localization.dart';
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

class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({super.key});
  static const path = 'SetNewPasswordPage/home';

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final double iconSize = 22;
  // TextEditingController controllerOld = TextEditingController();
  TextEditingController controllerNew = TextEditingController();
  String? labelTextPassword;
  Color? labelColorPassword;
  bool passwordOk = false; //密码验证ok
  // bool isSetPassword = false; //用户是否设置过密码
  bool showPassword1 = false;
  bool showPassword2 = false;
  bool loadSuccess = false; //加载完成

  _init() async {
    List<Future> futures = [
      Global.syncLoginUser(),
    ];
    await Future.wait(futures);
    if (!mounted) return;
    // isSetPassword = Global.user!.isSetPassword ?? false;
    loadSuccess = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    controllerNew.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color inputColor = myColors.chatInputColor;
    return Scaffold(
      backgroundColor: myColors.themeBackgroundColor,
      appBar: AppBar(),
      body: loadSuccess
          ? KeyboardBlur(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 27.5, left: 43.5),
                          child: Text(
                            '设置新密码'.tr(),
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
                        // if (isSetPassword)
                        //   Container(
                        //     padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        //     child: AppInputBox(
                        //       controller: controllerOld,
                        //       obscureText: !showPassword1,
                        //       hintText: '请输入旧密码'.tr(),
                        //       hintColor: myColors.imTextGrey1,
                        //       fontSize: 15,
                        //       fontColor: textColor,
                        //       color: inputColor,
                        //       prefixIcon: Container(
                        //         width: iconSize,
                        //         height: iconSize,
                        //         margin:
                        //             const EdgeInsets.symmetric(horizontal: 5),
                        //         alignment: Alignment.center,
                        //         child: Image.asset(
                        //           assetPath('images/login/pwd.png'),
                        //           color: textColor,
                        //           width: iconSize,
                        //           height: iconSize,
                        //           fit: BoxFit.contain,
                        //         ),
                        //       ),
                        //       action: GestureDetector(
                        //         onTap: () {
                        //           showPassword1 = !showPassword1;
                        //           setState(() {});
                        //         },
                        //         child: Container(
                        //           width: iconSize,
                        //           height: iconSize,
                        //           margin: const EdgeInsets.symmetric(
                        //               horizontal: 15),
                        //           alignment: Alignment.center,
                        //           child: Image.asset(
                        //             assetPath(
                        //               showPassword1
                        //                   ? 'images/my/sp_yanjing.png'
                        //                   : 'images/my/sp_biyan.png',
                        //             ),
                        //             color: textColor,
                        //             width: iconSize,
                        //             height: iconSize,
                        //             fit: BoxFit.contain,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                          child: AppInputBox(
                            controller: controllerNew,
                            obscureText: !showPassword2,
                            hintText: '新的密码'.tr(),
                            hintColor: myColors.subIconThemeColor,
                            fontSize: 15,
                            fontColor: textColor,
                            color: inputColor,
                            prefixIcon: Container(
                              width: iconSize,
                              height: iconSize,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              child: Image.asset(
                                assetPath('images/login/pwd.png'),
                                color: textColor,
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
                                showPassword2 = !showPassword2;
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
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                          child: CircleButton(
                            theme: AppButtonTheme.blue,
                            title: '确认'.tr(),
                            onTap: submmitTo,
                            height: 41,
                            radius: 10,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }

  void submmitTo() async {
    if (controllerNew.text.trim() == '') {
      tip('请输入账户的密码'.tr());
      return;
    }
    if (!passwordOk) {
      tip('请输入密码'.tr());
      return;
    }
    try {
      loading();
      await PassportApi(apiClient()).passportRevisePassword(
        V1PassportSetPasswordArgs(
          password: controllerNew.text.trim(),
        ),
      );
      tipSuccess('密码重置成功'.tr());
      Future.delayed(const Duration(seconds: 1)).then((value) {
        Navigator.pop(context);
      });
    } on ApiException catch (e) {
      tipError('密码重置异常'.tr());
      onError(e);
    } finally {
      loadClose();
    }
  }

  // void submmitTo() async {
  //   if (controllerOld.text == controllerNew.text && isSetPassword) {
  //     tip('新密码不能和旧密码相同'.tr());
  //     return;
  //   }
  //   if (controllerOld.text.trim() == '' && isSetPassword) {
  //     tip('请输入账户的密码'.tr());
  //     return;
  //   }
  //   if (!passwordOk) {
  //     tip('请输入密码'.tr());
  //     return;
  //   }
  //   if (isSetPassword) {
  //     try {
  //       loading();
  //       await PassportApi(apiClient()).passportChangePwd(V1ChangePwdArgs(
  //         newPassword: controllerNew.text.trim(),
  //         oldPassword: controllerOld.text.trim(),
  //       ));
  //       tipSuccess('密码重置成功'.tr());

  //       Future.delayed(const Duration(seconds: 1)).then((value) {
  //         Navigator.pop(context);
  //       });
  //     } on ApiException catch (e) {
  //       tipError('密码重置异常'.tr());
  //       onError(e);
  //     } finally {
  //       loadClose();
  //     }
  //   } else {
  //     try {
  //       loading();
  //       await PassportApi(apiClient())
  //           .passportSetPassword(V1PassportSetPasswordArgs(
  //         password: controllerNew.text.trim(),
  //       ));
  //       tipSuccess('密码重置成功'.tr());
  //       Future.delayed(const Duration(seconds: 1)).then((value) {
  //         Navigator.pop(context);
  //       });
  //     } on ApiException catch (e) {
  //       tipError('密码重置异常'.tr());
  //       onError(e);
  //     } finally {
  //       loadClose();
  //     }
  //   }
  // }
}
