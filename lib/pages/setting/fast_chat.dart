import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';

class FastChat extends StatefulWidget {
  const FastChat({super.key});

  static const String path = 'setting/fast/chat';

  @override
  State<FastChat> createState() => _FastChatState();
}

class _FastChatState extends State<FastChat> {
  List<GUserPhrasesModel> _list = [];
  int limit = 40;

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = UserPhrasesApi(apiClient());
    try {
      final res = await api.userPhrasesList(
        V1ListUserPhrasesArgs(
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : _list.length.toString(),
          ),
        ),
      );
      if (!mounted) return 0;
      setState(() {
        if (init) {
          _list = (res?.list ?? []).toList(growable: true);
        } else {
          _list.addAll((res?.list ?? []).toList(growable: true));
        }
      });
      if (res == null) return 0;

      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  //保存
  Future<bool> _save({required String content, String id = ''}) async {
    if (content.isEmpty) return false;
    loading();
    var api = UserPhrasesApi(apiClient());
    try {
      var args = V1UpdateUserPhrasesArgs(
        content: V1UpdateUserPhrasesArgsValue(
          value: content,
        ),
      );
      if (id.isNotEmpty) args.id = id;
      await api.userPhrasesUpdate(args);
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
  }

  //置顶
  setTop(GUserPhrasesModel data, bool isTop) async {
    loading();
    var api = UserPhrasesApi(apiClient());
    try {
      var args = V1UpdateUserPhrasesArgs(
        id: data.id,
        sort: V1UpdateUserPhrasesArgsSort(value: isTop),
      );
      await api.userPhrasesUpdate(args);
      if (mounted) _getList(init: true);
    } on ApiException catch (e) {
      // data.sort = isTop ? '0' : '1';
      // setState(() {});
      onError(e);
    } finally {
      loadClose();
    }
  }

  //新增、编辑
  goInput(String id, String content) {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) {
          return SetNameInput(
            title: id.isNotEmpty ? '编辑快捷语'.tr() : '新增快捷语'.tr(),
            value: content,
            isAppTextarea: true,
            onEnter: (str) async {
              return await _save(content: str, id: id);
            },
          );
        },
      ),
    ).then((value) {
      _getList(init: true);
    });
  }

  //删除
  _delete(GUserPhrasesModel data) async {
    _list.remove(data);
    setState(() {});
    var id = data.id;
    var api = UserPhrasesApi(apiClient());
    try {
      await api.userPhrasesDel(GIdsArgs(ids: [id.toString()]));
      if (mounted) {
        limit = _list.length;
        _getList(init: true);
        limit = 40;
      }
    } on ApiException catch (e) {
      limit = _list.length;
      _getList(init: true);
      limit = 40;
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('快捷语'),
        actions: [
          IconButton(
            onPressed: () => goInput('', ''),
            icon: Image.asset(
              assetPath('images/talk/more.png'),
              width: 18,
              height: 18,
              color: myColors.iconThemeColor,
            ),
          ),
        ],
      ),
      body: ThemeBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
            children: _list.map((e) {
              return SwipeActionCell(
                key: ObjectKey(e.id),
                trailingActions: [
                  SwipeAction(
                    title: '删除'.tr(),
                    color: myColors.red,
                    style: TextStyle(
                      fontSize: 14,
                      color: myColors.white,
                    ),
                    onTap: (handler) async {
                      await handler(false);
                      _delete(e);
                    },
                  ),
                ],
                child: InkWell(
                  onTap: () => goInput(e.id ?? '', e.content ?? ''),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: myColors.grey1,
                          width: .5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.content ?? '-',
                            style: TextStyle(
                              color: myColors.accountTagTitle,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              setTop(e, (e.sort ?? '0') == '0' ? true : false);
                            },
                            child: Image.asset(
                              assetPath((e.sort ?? '0') == '0'
                                  ? 'images/my/xingbiao_1.png'
                                  : 'images/my/xingbiao.png'),
                              color:
                                  myColors.isDark && !((e.sort ?? '0') == '0')
                                      ? myColors.iconThemeColor
                                      : null,
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
