import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/note/note_create_pro.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/note_item_pro.dart';

class NoteHome extends StatefulWidget {
  const NoteHome({super.key});

  static const path = 'note/home';

  @override
  State<StatefulWidget> createState() {
    return _NoteHomeState();
  }
}

class _NoteHomeState extends State<NoteHome> {
  final TextEditingController _controller = TextEditingController();
  List<Notes> list = [];
  List<int> indexList = [];
  int limit = 20;
  bool share = false;
  bool showAllDelete = false;
  String receiver = '';
  String roomId = '';
  String keywords = '';
  late StreamSubscription<NotesUpdateArgs> _notesSubscription;

  //全选
  bool allSelect = false;

  // 获取笔记列表
  getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final notes = await NotesUtils.listNotes(
      limit,
      keywords: keywords,
      offset: init ? 0 : list.length,
    );
    if (mounted) {
      setState(() {
        if (init) {
          list = notes;
        } else {
          list.addAll(notes);
        }
      });
    }
    if (load) loadClose();
    return notes.length;
  }

  // 分享笔记
  shareNote() async {
    if (indexList.isEmpty) return;
    var pairId = '';
    if (roomId.isNotEmpty) {
      pairId = generatePairId(0, toInt(roomId));
    } else if (receiver.isNotEmpty) {
      pairId = generatePairId(toInt(Global.user!.id), toInt(receiver));
    }
    List<Message> msgList = [];
    for (var i in indexList) {
      var v = list[i];
      if (v.taskStatus != TaskStatus.success) {
        tipError('当前已选有未上传完成的笔记，请稍后重试！');
        return;
      }
      var msg = Message()
        ..pairId = pairId
        ..type = GMessageType.NOTES
        ..contentId = toInt(v.id)
        ..senderUser = getSenderUser()
        ..content = jsonEncode(v.toJson());
      msgList.add(msg);
    }
    if (roomId.isEmpty && receiver.isEmpty) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return ShareHome(
              shareText: '[笔记分享]'.tr(),
              list: msgList,
            );
          },
        ),
      );
      return;
    }
    loading();
    try {
      await ApiRequest.apiSendMessage(
        list: msgList,
        ids: receiver.isNotEmpty ? [receiver] : null,
        roomIds: roomId.isNotEmpty ? [roomId] : null,
      );
      loadClose();
      tipSuccess('分享成功'.tr());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      loadClose();
      rethrow;
    }
  }

  // 置顶笔记
  setTop(int i, bool top) async {
    loading();
    var topTime = top ? toInt(date2time(null)) : 0;
    list[i].topTime = topTime;
    await NotesUtils.save(list[i]);
    if (mounted) {
      setState(() {});
    }
    getList(init: true);
    loadClose();
  }

  // 删除笔记
  delete(int i) async {
    var v = list[i];
    confirm(
      context,
      content: '确定要删除该笔记？'.tr(),
      onEnter: () async {
        loading();
        await NotesUtils.delete([v.id]);
        if (mounted) {
          setState(() {
            list.removeAt(i);
          });
        }
        loadClose();
      },
    );
  }

  // 多选删除
  allDelete() async {
    if (indexList.isEmpty) return;
    confirm(
      context,
      content: '确定要删除笔记？'.tr(),
      onEnter: () async {
        loading();
        List<int> ids = [];
        for (var i = 0; i < list.length; i++) {
          if (indexList.contains(i)) ids.add(list[i].id);
        }
        await NotesUtils.delete(ids);
        loadClose();
        if (mounted) {
          ids = [];
          allSelect = false;
          getList(init: true, load: true);
        }
      },
    );
  }

  // 保存备注
  Future<bool> saveMeta({
    required int index,
    String? meta,
  }) async {
    list[index].mark = meta ?? '';
    await NotesUtils.save(list[index]);
    if (mounted) setState(() {});
    return true;
  }

  @override
  void initState() {
    super.initState();
    _notesSubscription = NotesUtils.updateBroadcast.stream.listen((event) {
      var update = false;
      for (var i = 0; i < list.length; i++) {
        if (list[i].id != event.id) continue;
        list[i] = event.notes;
        update = true;
      }
      if (update && mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      receiver = args['receiver'] ?? '';
      roomId = args['roomId'] ?? '';
      setState(() {
        share = args['share'] ?? false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _notesSubscription.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
    keywords = args['keywords'] ?? '';
    if (keywords.isNotEmpty) {
      _controller.text = keywords;
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return KeyboardBlur(
      child: Scaffold(
        appBar: AppBar(
          leading: share || showAllDelete
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      indexList = [];
                      share = false;
                      showAllDelete = false;
                    });
                  },
                  child: Text(
                    '取消'.tr(),
                    style: TextStyle(
                      color: myColors.red,
                    ),
                  ),
                )
              : null,
          title: Text(share ? '分享笔记'.tr() : '我的笔记'.tr()),
          actions: [
            //删除按钮
            if (!showAllDelete && !share)
              IconButton(
                onPressed: () {
                  indexList = [];
                  allSelect = false;
                  showAllDelete = true;
                  setState(() {});
                },
                icon: Image.asset(
                  assetPath('images/delete.png'),
                  color: myColors.iconThemeColor,
                  width: 20,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            //新增
            if (!share && !showAllDelete && (platformPhone))
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    NoteCreatePro.path,
                    // NoteCreate.path,
                  ).then((value) {
                    getList(init: true);
                  });
                },
                icon: Image.asset(
                  assetPath('images/add.png'),
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            if (share || showAllDelete)
              TextButton(
                onPressed: share ? shareNote : allDelete,
                child: Text(
                  share ? '发送'.tr() : '删除'.tr(),
                  style: TextStyle(
                    color: indexList.isEmpty
                        ? myColors.textGrey
                        : myColors.primary,
                  ),
                ),
              ),
          ],
        ),
        body: ThemeBody(
          child: Column(
            children: [
              // NoteTabs(
              //   const ['全部', '分组1', '分组2', '分组3'],
              //   index: 0,
              //   onTap: (i) {},
              // ),
              Row(
                children: [
                  Expanded(
                    child: SearchInput(
                      controller: _controller,
                      onSubmitted: (val) {
                        getList(init: true, load: true);
                      },
                      onChanged: (val) {
                        keywords = val;
                        if (keywords == '') {
                          getList(init: true, load: true);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: keywords != ''
                        ? () {
                            getList(init: true, load: true);
                          }
                        : null,
                    child: Text(
                      '搜索'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: keywords != ''
                            ? myColors.blueTitle
                            : myColors.textGrey,
                      ),
                    ),
                  )
                ],
              ),
              if (share || showAllDelete)
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (list.isEmpty) return;
                        allSelect = !allSelect;
                        if (allSelect) {
                          if (list.length <= 10) {
                            for (var i = 0; i < list.length; i++) {
                              if (indexList.contains(i)) continue;
                              indexList.add(i);
                            }
                          } else {
                            for (var i = 0; i < 10; i++) {
                              if (indexList.contains(i)) continue;
                              indexList.add(i);
                            }
                          }
                        } else {
                          indexList = [];
                        }
                        if (mounted) setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: AppCheckbox(
                          value: allSelect,
                          paddingRight: 15,
                          paddingLeft: 15,
                        ),
                      ),
                    ),
                    Text(
                      '选择前10个'.tr(),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  padding: const EdgeInsets.only(top: 15, bottom: 30),
                  limit: limit,
                  onInit: () async {
                    return await getList(init: true);
                  },
                  onPullDown: () async {
                    return await getList(init: true);
                  },
                  onPullUp: () async {
                    return await getList();
                  },
                  children: list.map((e) {
                    var i = list.indexOf(e);
                    var data = notes2noteItem(e);
                    data.time = time2formatDate(toStr(e.createTime));
                    data.meta = e.mark ?? '';
                    bool top = toInt(e.topTime) > 0;
                    Widget? statusWidget;
                    if (e.taskStatus == TaskStatus.sending) {
                      statusWidget = const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: CupertinoActivityIndicator(radius: 5),
                      );
                    } else if (e.taskStatus == TaskStatus.fail) {
                      statusWidget = GestureDetector(
                        onTap: () {
                          if ((e.reason ?? '').isEmpty) return;
                          tipError(e.reason ?? '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.error,
                            color: myColors.red,
                            size: 17,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              if (share || showAllDelete)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (indexList.contains(i)) {
                                      indexList.remove(i);
                                    } else {
                                      indexList.add(i);
                                    }
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: AppCheckbox(
                                      value: indexList.contains(i),
                                      paddingRight: 15,
                                      paddingLeft: 15,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: share || showAllDelete ? 0 : 15,
                                    right: 15,
                                  ),
                                  child: NoteItemPro(
                                    data,
                                    iscollect: top,
                                    collect: () {
                                      setTop(i, !top);
                                    },
                                    edit: () {
                                      Navigator.pushNamed(
                                        context,
                                        NoteCreatePro.path,
                                        arguments: {
                                          'id': e.id,
                                        },
                                      ).then((_) {
                                        getList(init: true);
                                      });
                                    },
                                    delete: () {
                                      delete(i);
                                    },
                                    marginBottom: 0,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        NoteDetailPro.path,
                                        arguments: {'id': e.id},
                                      ).then((_) {
                                        getList(init: true);
                                      });
                                    },
                                    canRemarks: true,
                                    saveRemarks: () {
                                      Navigator.push(
                                        context,
                                        CupertinoModalPopupRoute(
                                            builder: (context) {
                                          return SetNameInput(
                                            title: '设置备注'.tr(),
                                            value: e.mark ?? '',
                                            onEnter: (val) async {
                                              return await saveMeta(
                                                index: list.indexOf(e),
                                                meta: val,
                                              );
                                            },
                                          );
                                        }),
                                      );
                                    },
                                    statusWidget: statusWidget,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Positioned(
                        //   // top: 12,
                        //   right: 27,
                        //   child: Row(
                        //     // mainAxisAlignment: MainAxisAlignment.start,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       GestureDetector(
                        //         onTap: () {
                        //           setTop(list.indexOf(e), !top);
                        //         },
                        //         child: Image.asset(
                        //           assetPath(top
                        //               ? 'images/my/sp_xingxing.png'
                        //               : 'images/my/sp_xingxing2.png'),
                        //           width: 25,
                        //           height: 25,
                        //           fit: BoxFit.contain,
                        //         ),
                        //       ),
                        //       const SizedBox(
                        //         width: 30,
                        //       ),
                        //       Column(
                        //         // crossAxisAlignment: CrossAxisAlignment.end,
                        //         // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //         children: [
                        //           TextButton(
                        //             onPressed: () {
                        //               Navigator.pushNamed(
                        //                 context,
                        //                 NoteCreate.path,
                        //                 arguments: {
                        //                   'id': e.id,
                        //                 },
                        //               ).then((_) {
                        //                 getList(init: true);
                        //               });
                        //             },
                        //             child: const Text('编辑'),
                        //           ),
                        //           TextButton(
                        //             onPressed: () {
                        //               delete(list.indexOf(e));
                        //             },
                        //             child: const Text('删除'),
                        //           )
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: share && (platformPhone)
            ? GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    NoteCreatePro.path,
                    // NoteCreate.path,
                  ).then((value) {
                    getList(init: true);
                  });
                },
                child: Icon(
                  Icons.add_circle_outline,
                  color: textColor,
                  size: 40,
                ),
              )
            : null,
      ),
    );
  }
}

class NoteTabs extends StatelessWidget {
  final List<String> list;
  final int index;
  final Function(int)? onTap;

  const NoteTabs(
    this.list, {
    this.index = 0,
    this.onTap,
    super.key,
  });

  //底部弹出更多tab分组选项
  Widget moreTabBottom(BuildContext context, {required List<String> list}) {
    var myColors = ThemeNotifier();
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
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  const Text(
                    '笔记分组',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.settings,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: myColors.lineGrey),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  var active = i == index;
                  return InkWell(
                    onTap: () => onTap?.call(i),
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
                              list[index],
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: active ? 17 : 15,
                                fontWeight: active ? FontWeight.w600 : null,
                                color: active
                                    ? myColors.iconThemeColor
                                    : myColors.subIconThemeColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      constraints: const BoxConstraints(minHeight: 25),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: list.map((e) {
                  var i = list.indexOf(e);
                  var active = i == index;
                  return InkWell(
                    onTap: () => onTap?.call(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        e,
                        style: TextStyle(
                          height: 1,
                          fontSize: active ? 17 : 15,
                          fontWeight: active ? FontWeight.w600 : null,
                          color: active
                              ? myColors.iconThemeColor
                              : myColors.subIconThemeColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              //打开更多分组
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return moreTabBottom(context, list: list);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                Icons.more_horiz,
                color: myColors.subIconThemeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
