import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/question/question_detail.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({super.key});

  static const path = 'question/list';

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  int limit = 20;
  List<V1QaListItem> _list = [];
  final _controller = TextEditingController();
  Timer? timer;

  // 输入改变事件
  _inputChange(String val) {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 500),
      () => _getList(init: true, load: true),
    );
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = QaApi(apiClient());
    try {
      var args = V1QaListArgs(
        keywords: _controller.text,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : _list.length.toString(),
        ),
      );
      final res = await api.qaList(args);
      if (res == null || !mounted) return 0;
      setState(() {
        if (init) {
          _list = res.list.toList();
        } else {
          _list.addAll(res.list.toList());
        }
      });
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('帮助中心'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchInput(
                controller: _controller,
                onSubmitted: (val) => _getList(init: true, load: true),
                onChanged: _inputChange,
              ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  limit: limit,
                  onInit: () async {
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: myColors.themeBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _list.map((e) {
                          var i = _list.indexOf(e);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                QuestionDetail.path,
                                arguments: {'id': e.id},
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                minHeight: 45,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 26,
                              ),
                              decoration: BoxDecoration(
                                border: i < _list.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: myColors.circleBorder,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      e.q!.isEmpty ? '-' : e.q!,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: textColor,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: myColors.lineGrey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
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
