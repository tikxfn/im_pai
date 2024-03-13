import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/setting/fast_chat.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../widgets/pager_box.dart';

class FastChatBottom extends StatefulWidget {
  final Function(String)? onTap;

  const FastChatBottom({
    this.onTap,
    super.key,
  });

  @override
  State<FastChatBottom> createState() => _FastChatBottomState();
}

class _FastChatBottomState extends State<FastChatBottom> {
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
      onError(e);
    } finally {
      loadClose();
    }
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: myColors.themeBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 21),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                  const Text(
                    '快捷语',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, FastChat.path);
                    },
                    child: Icon(
                      Icons.settings,
                      color: myColors.subIconThemeColor,
                    ),
                  )
                ],
              ),
            ),
            Divider(height: 1, color: myColors.lineGrey),
            Expanded(
              flex: 1,
              child: PagerBox(
                limit: limit,
                onInit: () async {
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
                      onTap: () {
                        if (e.content != null &&
                            e.content!.isNotEmpty &&
                            widget.onTap != null) {
                          widget.onTap!(e.content ?? '');
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: myColors.noticeBoder,
                              width: .5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.content ?? '-',
                                maxLines: 2,
                                style: TextStyle(
                                  color: myColors.accountTagTitle,
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () {
                                  // e.sort = e.sort == '0' ? '1' : '0';
                                  // setState(() {});
                                  setTop(
                                      e, (e.sort ?? '0') == '0' ? true : false);
                                },
                                child: Image.asset(
                                  assetPath((e.sort ?? '0') == '0'
                                      ? 'images/my/xingbiao_1.png'
                                      : 'images/my/xingbiao.png'),
                                  color: myColors.isDark &&
                                          !((e.sort ?? '0') == '0')
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
            )
          ],
        ),
      ),
    );
  }
}
