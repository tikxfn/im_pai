import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../widgets/keyboard_blur.dart';

class SurveysItem {
  String id;
  String title;
  TextEditingController? controller;
  String selectedId;
  bool error;
  GSurveysQuestionsType type;
  List<GSurveysOptionsModel>? options;

  SurveysItem({
    required this.id,
    required this.title,
    required this.selectedId,
    required this.type,
    this.options,
    this.controller,
    this.error = false,
  });
}

class Surveys extends StatefulWidget {
  const Surveys({super.key});

  static const path = 'setting/surveys';

  @override
  State<Surveys> createState() => _SurveysState();
}

class _SurveysState extends State<Surveys> {
  GSurveysModel? result;
  String surverysId = '0'; //问卷id
  bool attend = false; //是否参加本次过调查
  final List<SurveysItem> _questions = [];

  //是否已经参加
  isAttend() async {
    var api = SurveysApi(apiClient());
    try {
      var res = await api.surveysIsResponses(GIdArgs(id: surverysId));
      if (res == null || !mounted) return;
      attend = res.is_ ?? false;
      logger.i(attend);
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // 获取问卷
  getSurveys() async {
    loading();
    var api = SurveysApi(apiClient());
    try {
      var res = await api.surveysNewest({});
      if (res == null || !mounted) return;
      surverysId = res.id ?? '0';
      logger.i(res);
      await isAttend();
      result = res;
      if (!attend) {
        for (var v in res.questions) {
          switch (v.type) {
            case GSurveysQuestionsType.MANY:
              _questions.add(
                SurveysItem(
                  id: v.id ?? '',
                  title: v.questions ?? '',
                  selectedId: '',
                  type: GSurveysQuestionsType.MANY,
                  options: v.options,
                ),
              );
              break;
            case GSurveysQuestionsType.NIL:
              break;
            case GSurveysQuestionsType.SINGLE:
              _questions.add(
                SurveysItem(
                  id: v.id ?? '',
                  title: v.questions ?? '',
                  selectedId: '',
                  type: GSurveysQuestionsType.SINGLE,
                  options: v.options,
                ),
              );
              break;
            case GSurveysQuestionsType.TEXT:
              _questions.add(
                SurveysItem(
                  id: v.id ?? '',
                  title: v.questions ?? '',
                  selectedId: '',
                  controller: TextEditingController(),
                  type: GSurveysQuestionsType.TEXT,
                ),
              );
              break;
          }
        }
      }
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  // 保存问卷
  save() async {
    var ok = true;
    List<String> errorList = [];
    for (var v in _questions) {
      if (v.controller != null) {
        if (v.controller!.text.trim() == '') {
          ok = false;
          errorList.add(v.id);
        }
      } else {
        if (v.selectedId == '') {
          ok = false;
          errorList.add(v.id);
        }
      }
    }
    if (!ok) {
      tip('问题${errorList.join(',')}未作答');
      setState(() {});
      return;
    }
    loading();
    var api = SurveysApi(apiClient());
    try {
      var args = V1SurveysResponsesArgs(
        surveysId: surverysId,
        responses: _questions
            .map((e) => V1SurveysResponsesItem(
                  surveysQuestionsId: e.id,
                  responses:
                      e.controller != null ? e.controller!.text : e.selectedId,
                ))
            .toList(),
      );
      await api.surveysResponses(args);
      tip('提交成功，感谢你的参与'.tr());
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    getSurveys();
  }

  @override
  void dispose() {
    super.dispose();
    for (var v in _questions) {
      if (v.controller != null) {
        v.controller!.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        title: Text(
          attend ? '暂无问卷'.tr() : result?.title ?? '',
        ),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: attend
              ? Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '你已参加本次调查'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        color: myColors.iconThemeColor,
                      ),
                    ),
                  ),
                )
              : ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var v in _questions)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    '${v.id}.${v.title}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (v.type == GSurveysQuestionsType.SINGLE)
                                  radioWidgte(v),
                                if (v.type == GSurveysQuestionsType.MANY)
                                  checkWidgte(v),
                                if (v.type == GSurveysQuestionsType.TEXT)
                                  inputWidget(v),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (_questions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(44, 20, 44, 0),
                        child: CircleButton(
                          theme: AppButtonTheme.primary,
                          title: '确定'.tr(),
                          onTap: save,
                          fontSize: 15,
                          height: 40,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  //单选框
  Widget radioWidgte(SurveysItem question) {
    var myColors = ThemeNotifier();
    return Column(
      children: [
        if (question.options != null && question.options!.isNotEmpty)
          for (var v in question.options!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  question.selectedId = v.id!;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: AppCheckbox(
                        value: question.selectedId.contains(v.id!),
                        paddingRight: 15,
                        paddingLeft: 15,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 15,
                        ),
                        child: Text(
                          v.options ?? '',
                          style: TextStyle(
                            color: myColors.iconThemeColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  //多选框
  Widget checkWidgte(SurveysItem question) {
    var myColors = ThemeNotifier();
    return Column(
      children: [
        if (question.options != null && question.options!.isNotEmpty)
          for (var v in question.options!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (question.selectedId.contains(v.id ?? '')) {
                    List<String> ids = question.selectedId.split(',');
                    ids.remove('');
                    ids.remove(v.id);
                    question.selectedId = ids.join(',');
                  } else {
                    List<String> ids = question.selectedId.split(',');
                    ids.remove('');
                    ids.add(v.id!);
                    question.selectedId = ids.join(',');
                  }
                  setState(() {});
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: AppCheckbox(
                        value: question.selectedId.contains(v.id!),
                        paddingRight: 15,
                        paddingLeft: 15,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 15,
                        ),
                        child: Text(
                          v.options ?? '',
                          style: TextStyle(
                            color: myColors.iconThemeColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  //文本输入框
  Widget inputWidget(SurveysItem question) {
    var myColors = ThemeNotifier();
    return AppInputBox(
      controller: question.controller,
      color: myColors.chatInputColor,
      hintColor: myColors.subIconThemeColor,
      hintText: '请输入'.tr(),
      fontSize: 13,
      fontColor: myColors.iconThemeColor,
    );
  }
}
