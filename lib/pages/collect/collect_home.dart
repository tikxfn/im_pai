import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/collect/collect_detail.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/note_item_pro.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/form_widget.dart';
import '../../widgets/network_image.dart';
import '../chat/chat_forward.dart';
import '../chat/chat_management/group_card.dart';
import '../file_preview.dart';
import '../help/circle/circle_card.dart';
import '../play_video.dart';
import '../play_video_win.dart';

class CollectHome extends StatefulWidget {
  const CollectHome({super.key});

  static const String path = 'collect/home';

  @override
  State<CollectHome> createState() => _CollectHomeState();
}

class _CollectHomeState extends State<CollectHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  List<GFavoritesModel> _list = [];
  List<String> ids = [];
  List<Message> _chooseMessage = [];
  bool showAllDelete = false;
  bool share = false;
  int limit = 20;
  String receiver = '';
  String roomId = '';
  String keywords = '';
  List<GMessageType> types = [
    GMessageType.NIL,
    GMessageType.TEXT,
    GMessageType.IMAGE,
    GMessageType.VIDEO,
    GMessageType.FILE,
    GMessageType.AUDIO,
    GMessageType.LOCATION,
    GMessageType.USER_CARD,
    GMessageType.ROOM_CARD,
    GMessageType.HISTORY,
    GMessageType.FORWARD_CIRCLE,
    GMessageType.NOTES,
  ];
  GMessageType type = GMessageType.NIL;

  //全选
  bool allSelect = false;

  // 收藏转消息
  Message? _collect2message(GFavoritesModel v) {
    if (v.message == null) return null;
    var pairId = '';
    if (roomId.isNotEmpty) {
      pairId = generatePairId(0, toInt(roomId));
    } else if (receiver.isNotEmpty) {
      pairId = generatePairId(toInt(Global.user!.id), toInt(receiver));
    }

    return Message.fromFavoritesModel(v.message!)
      ..pairId = pairId
      ..senderUser = getSenderUser();
  }

  //获取收藏列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = UserFavoritesApi(apiClient());
    try {
      var args = V1ListUserFavoritesArgs(
        chatType: V1ListUserFavoritesArgsChatType(
          chatType: type == GMessageType.NIL ? [] : [type],
        ),
        keyword: keywords,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : _list.length.toString(),
        ),
      );
      final res = await api.userFavoritesListFavorites(args);
      if (!mounted) return 0;
      List<GFavoritesModel> l = res?.list.toList() ?? [];
      setState(() {
        if (init) {
          _list = l;
        } else {
          _list.addAll(l);
        }
      });
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } catch (e) {
      logger.e(e);
    } finally {
      if (load) loadClose();
    }
  }

  //删除收藏
  _delete(int i) async {
    var v = _list[i];
    var id = v.id.toString();
    // if (v.type == GUserCollectType.NOTE) {
    //   id = v.note!.id ?? '';
    // }
    // if (id.isEmpty) return;
    confirm(
      context,
      content: '确定要删除该收藏？'.tr(),
      onEnter: () async {
        loading();
        var api = UserFavoritesApi(apiClient());
        try {
          await api.userFavoritesCancelFavorites(GMgoIdsArgs(ids: [id]));
          if (mounted) {
            setState(() {
              _list.removeAt(i);
            });
          }
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  //多选删除
  allDelete() async {
    // print(ids);
    confirm(
      context,
      content: '确定要删除收藏？'.tr(),
      onEnter: () async {
        loading();
        var api = UserFavoritesApi(apiClient());
        try {
          await api.userFavoritesCancelFavorites(GMgoIdsArgs(ids: ids));
          if (mounted) {
            _chooseMessage = [];
            ids = [];
            allSelect = false;
            _getList(init: true, load: true);
          }
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  //筛选条件选择
  _conditionChoose(GMessageType chooseData) {
    // Navigator.pushNamed(context, CollectDetail.path);
    setState(() {
      type = chooseData;
    });
    Navigator.pop(context);
    _getList(init: true, load: true);
  }

  //消息点击事件
  _messageTap(Message data) async {
    if (data.type == GMessageType.TEXT) {
      Navigator.pushNamed(
        context,
        CollectDetail.path,
        arguments: data,
      );
    }
    if (data.type == GMessageType.IMAGE) {
      Navigator.pushNamed(
        context,
        CollectDetail.path,
        arguments: data,
      );
    }
    if (data.type == GMessageType.VIDEO) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            if (Platform.isWindows) {
              return WinPlayVideo(url: data.content ?? '');
            } else {
              return AppPlayVideo(url: data.content ?? '');
            }
          },
        ),
      );
    }
    if (data.type == GMessageType.AUDIO) {
      Navigator.pushNamed(
        context,
        CollectDetail.path,
        arguments: data,
      );
    }
    if (data.type == GMessageType.FILE) {
      Navigator.pushNamed(
        context,
        FilePreview.path,
        arguments: {
          'file': data.fileUrl,
          'name': data.content,
          'size': data.duration,
        },
      );
    }
    if (data.type == GMessageType.LOCATION) {
      if (!platformPhone) {
        tip('不支持的消息类型'.tr());
        return;
      }
      if (!await devicePermission([Permission.location])) return;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AppMap(
              showMap: true,
              location: MapLocation(
                location: data.location ?? '',
                title: data.title ?? '',
                desc: data.content ?? '',
              ),
            );
          },
        ),
      );
    }
    if (data.type == GMessageType.USER_CARD) {
      Navigator.pushNamed(
        context,
        FriendDetails.path,
        arguments: {
          'id': data.contentId.toString(),
          'detail': GUserModel(
            avatar: data.senderUser?.avatar,
            nickname: data.senderUser?.nickname,
          ),
        },
      );
    }
    if (data.type == GMessageType.ROOM_CARD) {
      Navigator.pushNamed(
        context,
        GroupCard.path,
        arguments: {
          'roomId': data.contentId.toString(),
          'roomFrom': 'room_card',
          'isCard': false,
        },
      );
    }
    if (data.type == GMessageType.NOTES) {
      logger.d(data.content);
      if ((data.content ?? '').contains('[{"insert"')) {
        tipError('笔记格式错误');
        return;
      }
      Navigator.pushNamed(
        context,
        NoteDetailPro.path,
        arguments: {
          // 'id': data.contentId.toString(),
          'collect': true,
          'notes': Notes.fromJson(jsonDecode(data.content ?? '')),
        },
      ).then((value) => _getList(init: true));
    }
    if (data.type == GMessageType.FORWARD_CIRCLE) {
      Navigator.pushNamed(
        context,
        CircleCard.path,
        arguments: {'circleId': data.contentId.toString(), 'isCard': true},
      );
    }
    if (data.type == GMessageType.HISTORY) {
      Navigator.pushNamed(
        context,
        ChatForward.path,
        arguments: {
          'ids': data.contentId,
          'title': data.title,
          'message': data,
        },
      );
    }
  }

  //分享收藏
  shareCollect() async {
    if (roomId.isEmpty && receiver.isEmpty) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return ShareHome(
              shareText: '[收藏转发]'.tr(),
              list: _chooseMessage,
              collect: true,
            );
          },
        ),
      );
      return;
    }
    loading();
    try {
      await ApiRequest.apiSendMessage(
        list: _chooseMessage,
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

  //置顶收藏
  _setTop(int i, bool isTop) async {
    var v = _list[i];
    loading();
    var api = UserFavoritesApi(apiClient());
    try {
      var args = V1UpdateFavoritesTopArgs(id: v.id, isTop: toSure(isTop));
      await api.userFavoritesUpdateFavoritesTop(args);
      _getList(init: true);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //备注收藏
  Future<bool> saveMeta({
    required String id,
    String? meta,
    bool load = true,
  }) async {
    if (meta == null) {
      return false;
    }
    var api = UserFavoritesApi(apiClient());
    if (load) loading();
    try {
      await api.userFavoritesUpdateFavoritesMeta(
        V1UpdateFavoritesMetaArgs(
          id: id,
          mark: meta,
        ),
      );
      if (!mounted) return false;
      limit = _list.length;
      _getList(init: true);
      limit = 20;
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      receiver = args['receiver'] ?? '';
      roomId = args['roomId'] ?? '';
      setState(() {
        share = args['share'] ?? false;
      });
    });
    _tabController = TabController(length: types.length, vsync: this);
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
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return KeyboardBlur(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: share || showAllDelete
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      _chooseMessage = [];
                      ids = [];
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
          title: Text(share ? '转发'.tr() : '我的收藏'.tr()),
          actions: [
            if (!share && !showAllDelete)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // //筛选
                  // IconButton(
                  //   onPressed: () {
                  //     _key.currentState!.openEndDrawer();
                  //   },
                  //   icon: Image.asset(
                  //     assetPath('images/help/sp_saixuan.png'),
                  //     width: 17,
                  //   ),
                  // ),
                  //删除
                  IconButton(
                    onPressed: () {
                      _chooseMessage = [];
                      ids = [];
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
                  // if (platformPhone)
                  //   IconButton(
                  //     onPressed: () {
                  //       Navigator.pushNamed(
                  //         context,
                  //         NoteCreatePro.path,
                  //         // NoteCreate.path,
                  //         arguments: {
                  //           'collect': true,
                  //         },
                  //       ).then((value) {
                  //         _getList(init: true);
                  //       });
                  //     },
                  //     icon: Image.asset(
                  //       assetPath('images/add.png'),
                  //       width: 18,
                  //       height: 18,
                  //       fit: BoxFit.contain,
                  //     ),
                  //   ),
                ],
              ),
            if (share || showAllDelete)
              TextButton(
                onPressed: share ? shareCollect : allDelete,
                child: Text(
                  share ? '发送'.tr() : '删除'.tr(),
                  style: TextStyle(
                    color: ids.isEmpty ? myColors.textGrey : myColors.primary,
                  ),
                ),
              ),
          ],
        ),
        body: ThemeBody(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchInput(
                      controller: _controller,
                      onSubmitted: (val) {
                        _getList(init: true, load: true);
                      },
                      onChanged: (val) {
                        keywords = val;
                        if (keywords == '') {
                          _getList(init: true, load: true);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  //筛选
                  // GestureDetector(
                  //   onTap: () {
                  //     _key.currentState!.openEndDrawer();
                  //   },
                  //   child: Image.asset(
                  //     assetPath('images/help/sp_saixuan.png'),
                  //     color: textColor,
                  //     width: 17,
                  //   ),
                  // ),
                  TextButton(
                    onPressed: keywords != ''
                        ? () {
                            _getList(init: true, load: true);
                          }
                        : null,
                    child: Text(
                      '搜索'.tr(),
                      style: TextStyle(
                        color: keywords != ''
                            ? myColors.primary
                            : myColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              tab(),
              // Container(
              //   margin: const EdgeInsets.only(top: 12),
              //   height: 4,
              //   color: myColors.circleBorder,
              // ),
              if (share || showAllDelete)
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        allSelect = !allSelect;
                        if (allSelect) {
                          for (var v in _list) {
                            if (ids.contains(v.id)) continue;
                            ids.add(v.id!);
                            var msg = _collect2message(v);
                            if (msg != null) _chooseMessage.add(msg);
                          }
                        } else {
                          _chooseMessage = [];
                          ids = [];
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
                    Text('全选'.tr()),
                  ],
                ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var _ in types)
                      PagerBox(
                        padding: const EdgeInsets.all(15),
                        limit: limit,
                        onInit: () async {
                          return await _getList(init: true, load: true);
                        },
                        onPullDown: () async {
                          return await _getList(init: true);
                        },
                        onPullUp: () async {
                          return await _getList();
                        },
                        children: _list.map((v) {
                          Message? e = _collect2message(v);
                          if (v.message == null || e == null) {
                            return Container();
                          }
                          var image = '';
                          var title = '';
                          var text = '';
                          var target = '';
                          var time = '';
                          var meta = v.mark ?? '';
                          Widget? imageWidget;
                          var id = v.id.toString();
                          image = '';
                          title = e.content ?? '';
                          text = '';
                          target = e.senderUser?.nickname ?? '-';
                          time = time2formatDate(e.createTime.toString());
                          switch (e.type) {
                            case GMessageType.NIL:
                              break;
                            case GMessageType.TEXT:
                              break;
                            case GMessageType.IMAGE:
                              var imageUrl = e.imageUrl ?? '';
                              e.content =
                                  imageUrl.isNotEmpty ? imageUrl : e.content;
                              image = (e.content ?? '').isNotEmpty
                                  ? (e.content ?? '').split(',')[0]
                                  : '';
                              title = '';
                              break;
                            case GMessageType.AUDIO:
                              title = '${e.duration.toString()}”';
                              imageWidget = Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: myColors.grey,
                                    ),
                                  ),
                                  Image.asset(
                                    assetPath('images/sp_yuying.png'),
                                    width: 20,
                                  ),
                                ],
                              );
                              break;
                            case GMessageType.VIDEO:
                              var fileUrl = e.fileUrl ?? '';
                              e.content =
                                  fileUrl.isNotEmpty ? fileUrl : e.content;
                              title = second2minute(e.duration ?? 0);
                              imageWidget = Stack(
                                alignment: Alignment.center,
                                children: [
                                  AppNetworkImage(
                                    getVideoCover(e.content ?? ''),
                                    width: 60,
                                    height: 60,
                                    borderRadius: BorderRadius.circular(5),
                                    fit: BoxFit.cover,
                                  ),
                                  Image.asset(
                                    assetPath('images/play2.png'),
                                    width: 20,
                                  ),
                                ],
                              );
                              break;
                            case GMessageType.FILE:
                              title = e.content ?? '';
                              text = b2size((e.duration ?? 0).toDouble());
                              var uri = Uri.parse(e.fileUrl ?? '');
                              imageWidget = Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    assetPath('images/sp_wenjian.png'),
                                    width: 60,
                                  ),
                                  Container(
                                    width: 30,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      uri.path.split('.').last.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              );
                              break;
                            case GMessageType.LOCATION:
                              title = e.title ?? '';
                              text = e.content ?? '';
                              imageWidget = Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: myColors.im2CircleIcon,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: myColors.white,
                                ),
                              );
                              break;
                            case GMessageType.USER_CARD:
                              title = e.content ?? '';
                              text = '个人名片'.tr();
                              imageWidget = AppAvatar(
                                list: [e.fileUrl ?? ''],
                                userName: title,
                                userId: (e.contentId ?? '').toString(),
                              );
                              break;
                            case GMessageType.ROOM_CARD:
                              title = e.content ?? '';
                              text = '群名片'.tr();
                              imageWidget = AppAvatar(
                                list: [e.fileUrl ?? ''],
                                userName: title,
                                userId: (e.contentId ?? '').toString(),
                              );
                              break;
                            case GMessageType.HISTORY:
                              title = messageHistory2text(e.messageHistory);
                              break;
                            case GMessageType.NOTES:
                              var note = json2note(e.content ?? '');
                              title = note.title;
                              text = note.text;
                              image = note.image;
                              target = '笔记'.tr();
                              break;
                            case GMessageType.FORWARD_CIRCLE:
                              title = e.title ?? '';
                              text = '圈子名片'.tr();
                              imageWidget = AppAvatar(
                                list: [e.fileUrl ?? ''],
                                userName: title,
                                userId: (e.contentId ?? '').toString(),
                              );
                              break;
                            case GMessageType.RED_PACKET:
                            case GMessageType.RED_INTEGRAL:
                            case GMessageType.VIDEO_CALL:
                            case GMessageType.AUDIO_CALL:
                            case GMessageType.FRIEND_APPLY_PASS:
                            case GMessageType.SHAKE:
                            case GMessageType.ROOM_NOTICE_EXIT:
                            case GMessageType.ROOM_NOTICE_JOIN:
                            case GMessageType.GIVE_RELIABLE:
                            case GMessageType.COLLECT:
                            case GMessageType.FORWARD_ONE_BY_ONE:
                              break;
                          }
                          bool top = toInt(v.topTime) > 0;
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (share || showAllDelete) {
                                      if (share &&
                                          e.type ==
                                              GMessageType.FORWARD_CIRCLE) {
                                        return;
                                      }
                                      if (ids.contains(id)) {
                                        var i = ids.indexOf(id);
                                        ids.removeAt(i);
                                        _chooseMessage.removeAt(i);
                                      } else {
                                        ids.add(id);
                                        var msg = _collect2message(v);
                                        if (msg != null) {
                                          _chooseMessage.add(msg);
                                        }
                                      }
                                      setState(() {});
                                    } else {
                                      _messageTap(e);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      if (share || showAllDelete)
                                        AppCheckbox(
                                          value: ids.contains(id),
                                          paddingRight: 10,
                                          disabled: share &&
                                              e.type ==
                                                  GMessageType.FORWARD_CIRCLE,
                                        ),
                                      Expanded(
                                        flex: 1,
                                        child: NoteItemPro(
                                          iscollect: top,
                                          isNote: false,
                                          // v.type == GUserCollectType.NOTE,
                                          collect: () {
                                            _setTop(_list.indexOf(v), !top);
                                          },
                                          edit: () {
                                            // Navigator.pushNamed(
                                            //   context,
                                            //   NoteCreatePro.path,
                                            //   // NoteCreate.path,
                                            //   arguments: {
                                            //     'id': v.note!.id,
                                            //     'collect': true
                                            //   },
                                            // ).then((_) {
                                            //   _getList(init: true);
                                            // });
                                          },
                                          delete: () {
                                            _delete(_list.indexOf(v));
                                          },
                                          NoteItemData(
                                            note: false,
                                            title: title
                                                .replaceAll('\n', '')
                                                .trim(),
                                            text: text,
                                            image: image,
                                            target: target,
                                            time: time,
                                            meta: meta,
                                          ),
                                          marginBottom: 0,
                                          imageWidget: imageWidget,
                                          canRemarks: true,
                                          saveRemarks: () {
                                            Navigator.push(
                                              context,
                                              CupertinoModalPopupRoute(
                                                  builder: (context) {
                                                return SetNameInput(
                                                  title: '设置备注'.tr(),
                                                  value: v.mark ?? '',
                                                  onEnter: (val) async {
                                                    return await saveMeta(
                                                      id: v.id!,
                                                      meta: val,
                                                    );
                                                  },
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // if (top)
                              //   const Positioned(
                              //     top: 2,
                              //     right: 2,
                              //     child: Icon(
                              //       Icons.star,
                              //       color: myColors .vipName,
                              //       size: 15,
                              //     ),
                              //   ),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: myColors.tagColor,
          width: 240,
          child: ListView(
            children: [
              for (var v in types)
                GestureDetector(
                  onTap: () {
                    _conditionChoose(v);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: myColors.lineGrey, width: .5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          v == GMessageType.NIL
                              ? '全部类型'.tr()
                              : messageType2text(v),
                        ),
                        if (type == v)
                          Icon(
                            Icons.check,
                            color: myColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //tab切换
  Widget tab() {
    var myColors = ThemeNotifier();
    return TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: myColors.circleBlueButtonBg,
        indicatorWeight: 3.0,
        labelColor: myColors.iconThemeColor,
        labelStyle: const TextStyle(
          height: 1,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        onTap: (value) {
          type = types[value];
        },
        unselectedLabelColor: myColors.textGrey,
        unselectedLabelStyle: const TextStyle(fontSize: 13, height: 1),
        tabs: types.map((e) {
          return Tab(
            height: 40,
            text: e == GMessageType.NIL ? '全部类型'.tr() : messageType2textr(e),
          );
        }).toList());
  }
}
