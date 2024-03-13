import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});
  static const path = 'account/new_password';

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final double iconSize = 22;
  final TextEditingController _pasCtr = TextEditingController();
  final TextEditingController _rePasswordCtr = TextEditingController();
  bool showPassword1 = false;
  bool showPassword2 = false;
  String? labelTextPassword;
  Color? labelColorPassword;
  String? labelTextRePassword;
  Color? labelColorRePassword;
  bool passwordOk = false; //密码验证ok
  bool rePasswordOk = false; //密码验证ok
  String loginToken = '';
  String account = '';

  //重置密码
  setPassword() async {
    if (!passwordOk || !rePasswordOk) {
      tipError('请检查填写信息'.tr());
      return;
    }
    final api = PassportApi(apiClient());
    loading();
    try {
      var args = V1PassportAssistLoginSetPasswordArgs(
        account: account,
        token: loginToken,
        password: _pasCtr.text.trim(),
      );
      await api.passportAssistLoginSetPassword(args);
      if (!mounted) return;
      if (mounted) {
        tip('密码重置成功');
        Adapter.navigatorTo(Login.path, removeUntil: true);
      }
    } on ApiException catch (e) {
      tipError('重置失败'.tr());
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['loginToken'] != null) loginToken = args['loginToken'];
      if (args['account'] != null) account = args['account'];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage(assetPath('images/my/scan_bg.png')),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: myColors.white,
            ),
            backgroundColor: Colors.transparent,
            title: Text(
              '设置新密码'.tr(),
              style: TextStyle(
                color: myColors.white,
              ),
            ),
          ),
          body: KeyboardBlur(
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        child: Row(
                          children: [
                            // const Icon(
                            //   Icons.lock_outline,
                            //   color: myColors.loginText,
                            // ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '密码'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: myColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        child: AppInputBox(
                          controller: _pasCtr,
                          obscureText: !showPassword1,
                          hintText: '请输入密码'.tr(),
                          hintColor: myColors.imTextGrey1,
                          fontSize: 15,
                          color: myColors.im2inputBox,
                          fontColor: myColors.white,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              child: Image.asset(
                                assetPath(
                                  showPassword1
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
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '确认密码'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: myColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        child: AppInputBox(
                          controller: _rePasswordCtr,
                          obscureText: !showPassword2,
                          hintText: '请输入密码'.tr(),
                          hintColor: myColors.imTextGrey1,
                          fontSize: 15,
                          color: myColors.im2inputBox,
                          fontColor: myColors.white,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              child: Image.asset(
                                assetPath(
                                  showPassword2
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
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                        child: CircleButton(
                          theme: AppButtonTheme.primary,
                          title: '确定'.tr(),
                          onTap: setPassword,
                          fontSize: 15,
                          height: 41,
                          radius: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
