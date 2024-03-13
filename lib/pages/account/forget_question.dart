import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/button.dart';
import '../../widgets/form_widget.dart';
import '../../widgets/keyboard_blur.dart';

class ForgetQuestionItem {
  String title;
  TextEditingController controller;
  bool error;

  ForgetQuestionItem({
    required this.title,
    required this.controller,
    this.error = false,
  });
}

class ForgetQuestion extends StatefulWidget {
  const ForgetQuestion({super.key});

  static const path = 'account/forget/question';

  @override
  State<ForgetQuestion> createState() => _ForgetQuestionState();
}

class _ForgetQuestionState extends State<ForgetQuestion> {
  String _account = '';
  final double iconSize = 22;
  String? labelTextPassword;
  Color? labelColorPassword;
  TextEditingController newPassword = TextEditingController();
  bool showPassword = false;
  bool passwordOk = false; //密码验证ok
  List<ForgetQuestionItem> _list = [];

  // 保存密保问题
  save() async {
    var ok = true;
    for (var v in _list) {
      if (v.controller.text.isEmpty) {
        v.error = true;
        ok = false;
      }
    }
    var password = newPassword.text;
    if (password.length < 8 || password.contains(' ')) {
      labelTextPassword = '密码必须包含8个字符并且不能有空格'.tr();
      labelColorPassword = Colors.red;
      passwordOk = false;
      ok = false;
    }
    if (!ok) {
      setState(() {});
      return;
    }
    loading();
    var api = PassportApi(apiClient());
    try {
      var args = V1PassportSecurityRetrievePasswordArgs(
        account: _account,
        password: newPassword.text,
        list: _list
            .map((e) => GUserSecurityModel(
                  questions: e.title,
                  answer: e.controller.text,
                ))
            .toList(),
      );
      await api.passportSecurityRetrievePassword(args);
      if (mounted) Navigator.popUntil(context, ModalRoute.withName(Login.path));
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      _account = args['account'] ?? '';
      List<String> questions = args['questions'] ?? [];
      List<ForgetQuestionItem> l = [];
      for (var v in questions) {
        l.add(ForgetQuestionItem(
          title: v,
          controller: TextEditingController(),
        ));
      }
      setState(() {
        _list = l;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      body: KeyboardBlur(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back,
                          color: myColors.iconThemeColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 40,
                    right: 40,
                  ),
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        '找回密码'.tr(),
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: myColors.iconThemeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (var v in _list)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 15),
                            constraints: const BoxConstraints(
                              minHeight: 50,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: myColors.chatInputColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Text(
                              v.title,
                              style: TextStyle(
                                color: myColors.iconThemeColor,
                              ),
                            ),
                          ),
                          AppInputBox(
                            controller: v.controller,
                            color: myColors.chatInputColor,
                            hintColor: myColors.subIconThemeColor,
                            hintText: '请输入'.tr(),
                            fontSize: 15,
                            fontColor: myColors.iconThemeColor,
                            labelText: v.error ? '不能为空' : '',
                            labelColor: Colors.red,
                            onChanged: (val) {
                              if (val.isEmpty && !v.error) {
                                setState(() {
                                  v.error = true;
                                });
                              }
                              if (val.isNotEmpty && v.error) {
                                setState(() {
                                  v.error = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    AppInputBox(
                      controller: newPassword,
                      obscureText: !showPassword,
                      hintText: '新的密码'.tr(),
                      hintColor: myColors.subIconThemeColor,
                      color: myColors.chatInputColor,
                      fontSize: 15,
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
                    const SizedBox(height: 15),
                    CircleButton(
                      theme: AppButtonTheme.primary,
                      title: '确定'.tr(),
                      onTap: save,
                      height: 43,
                      fontSize: 17,
                      radius: 10,
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
}
