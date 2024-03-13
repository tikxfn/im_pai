import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/forget_question.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/button.dart';
import '../../widgets/form_widget.dart';
import '../../widgets/keyboard_blur.dart';

class ForgetQuestionAccount extends StatefulWidget {
  const ForgetQuestionAccount({super.key});

  static const path = 'account/forget/question/account';

  @override
  State<ForgetQuestionAccount> createState() => _ForgetQuestionAccountState();
}

class _ForgetQuestionAccountState extends State<ForgetQuestionAccount> {
  final TextEditingController _controller = TextEditingController();

  // 获取密保问题
  getQuestion() async {
    if (_controller.text.isEmpty) {
      tipError('请输入账号/手机号'.tr());
      return;
    }
    loading();
    var api = PassportApi(apiClient());
    try {
      var args = V1PassportSecurityListArgs(
        account: _controller.text,
      );
      var res = await api.passportSecurityList(args);
      if (res == null || res.questions.isEmpty) return;
      if (mounted) {
        Navigator.pushNamed(
          context,
          ForgetQuestion.path,
          arguments: {
            'account': _controller.text,
            'questions': res.questions,
          },
        );
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: KeyboardBlur(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(
                  top: 27.5,
                  left: 43.5,
                  bottom: 20,
                ),
                child: Text(
                  '密保找回'.tr(),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 45, 15),
                child: AppInputBox(
                  controller: _controller,
                  color: myColors.chatInputColor,
                  hintColor: myColors.subIconThemeColor,
                  hintText: '请输入账号/手机号'.tr(),
                  fontSize: 15,
                  fontColor: myColors.iconThemeColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                child: CircleButton(
                  theme: AppButtonTheme.primary,
                  title: '下一步'.tr(),
                  onTap: getQuestion,
                  height: 43,
                  fontSize: 17,
                  radius: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
