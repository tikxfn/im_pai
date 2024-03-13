import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common/func.dart';
import '../../common/media_save.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/button.dart';
import '../../widgets/form_widget.dart';
import '../../widgets/keyboard_blur.dart';

class PasswordQuestionItem {
  int title;
  TextEditingController controller;
  bool error;

  PasswordQuestionItem({
    required this.title,
    required this.controller,
    this.error = false,
  });
}

class PasswordQuestion extends StatefulWidget {
  const PasswordQuestion({super.key});

  static const path = 'password/question';

  @override
  State<PasswordQuestion> createState() => _PasswordQuestionState();
}

class _PasswordQuestionState extends State<PasswordQuestion> {
  final ScreenshotController _screenshotController = ScreenshotController();
  List<String> _questions = [];
  final List<PasswordQuestionItem> _list = [
    PasswordQuestionItem(title: -1, controller: TextEditingController()),
    PasswordQuestionItem(title: -1, controller: TextEditingController()),
    PasswordQuestionItem(title: -1, controller: TextEditingController()),
  ];

  // 保存密保问题
  save() async {
    var ok = true;
    for (var v in _list) {
      if (v.controller.text.isEmpty) {
        v.error = true;
        ok = false;
      }
    }
    if (!ok) {
      setState(() {});
      return;
    }
    var cfm = await confirm(
      context,
      content: '是否需要将密保问题 "截图保存" 到相册！',
      enter: '截图保存',
      cancel: '我能记住',
    );
    loading();
    if (cfm == true) {
      await saveImage(load: false);
    }
    var api = UserSecurityApi(apiClient());
    try {
      var args = V1UserSecuritySaveSecurityArgs(
        list: _list
            .map((e) => GUserSecurityModel(
                  questions: _questions[e.title],
                  answer: e.controller.text,
                ))
            .toList(),
      );
      await api.userSecuritySaveSecurity(args);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  // 获取密保问题
  getQuestion() async {
    var api = UserSecurityApi(apiClient());
    try {
      var res = await api.userSecurityQuestionsList({});
      if (res == null || !mounted) return;
      setState(() {
        _questions = res.questions;
        if (_questions.length >= 3) {
          _list[0].title = 0;
          _list[1].title = 1;
          _list[2].title = 2;
        }
      });
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // 问题弹窗
  questionDialog(int i) {
    List<String> ql = [];
    List<int> li = [];
    for (var v in _list) {
      if (v.title != i) li.add(v.title);
    }
    for (var v in _questions) {
      var q = _questions.indexOf(v);
      if (!li.contains(q)) ql.add(v);
    }
    openSelect(
      context,
      list: ql,
      onEnter: (q) {
        setState(() {
          _list[i].title = _questions.indexOf(ql[q]);
        });
      },
    );
  }

  // 截图保存
  Future<void> saveImage({bool load = true}) async {
    if (load) loading(text: '正在生成图片');
    try {
      Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        loadClose();
        var path = await MediaSave().saveMediaBytes(imageBytes, 'png');
        if (path.isNotEmpty) tipSuccess('已保存到相册');
      }
    } catch (e) {
      logger.e(e);
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    getQuestion();
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
          child: ListView(
            children: [
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 27.5, left: 43.5),
                child: Text(
                  '设置密保问题'.tr(),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Screenshot(
                controller: _screenshotController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    for (var v in _list)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                questionDialog(_list.indexOf(v));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 10),
                                constraints: const BoxConstraints(
                                  minHeight: 50,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: myColors.chatInputColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        v.title >= 0
                                            ? _questions[v.title]
                                            : '请选择密保问题',
                                        style: TextStyle(
                                          color: myColors.iconThemeColor,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: myColors.subIconThemeColor,
                                    )
                                  ],
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
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                child: CircleButton(
                  theme: AppButtonTheme.primary,
                  title: '确定'.tr(),
                  onTap: save,
                  fontSize: 14,
                  radius: 10,
                  height: 41,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(44, 10, 44, 0),
                child: CircleButton(
                  theme: AppButtonTheme.red,
                  title: '截图保存'.tr(),
                  onTap: saveImage,
                  fontSize: 14,
                  radius: 10,
                  height: 41,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      '请牢记或截图保存密保问题！'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: myColors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
