import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/chat/chat_management/group_log.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupApplyManage extends StatefulWidget {
  const GroupApplyManage({super.key});

  static const path = 'chat/chat_management/group_apply_manage';

  @override
  State<GroupApplyManage> createState() => _GroupApplyManageState();
}

class _GroupApplyManageState extends State<GroupApplyManage> {
  int limit = 20;

  //群Id
  String? roomId;

  //审核列表
  List<GRoomMemberModel> list = [];

  //已选列表
  List<String> ids = [];

  //获取列表
  Future<int> getList({bool init = false}) async {
    if (roomId == '') return 0;
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListApplyRoomJoin(
        V1ListApplyRoomJoinArgs(
          roomId: roomId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : list.length.toString(),
          ),
        ),
      );
      List<GRoomMemberModel> newList = res?.list.toList() ?? [];
      if (!mounted) return 0;
      if (init) {
        ids.clear();
        list = newList;
        UnreadValue.queryGroupApplyNotRead();
      } else {
        list.addAll(newList);
      }
      setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //审核
  manage(List<String> ids, GApplyStatus status) async {
    if (ids.isEmpty) return;
    String refuseContent = '';
    confirm(
      context,
      content: '确认审核？'
          .tr(args: [status == GApplyStatus.SUCCESS ? '通过'.tr() : '拒绝'.tr()]),
      onEnter: () async {
        if (status == GApplyStatus.REFUSE) {
          bool sure = false;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SetNameInput(
                title: '告知对方不被通过的理由'.tr(),
                isAppTextarea: true,
                onEnter: (str) async {
                  refuseContent = str;
                  sure = true;
                  return true;
                },
              );
            }),
          );
          if (sure) {
            manageSend(ids, status, refuseContent);
          }
        } else {
          manageSend(ids, status, refuseContent);
        }
      },
    );
  }

  //发送审核
  manageSend(
    List<String> ids,
    GApplyStatus status,
    String refuseContent,
  ) async {
    final api = RoomApi(apiClient());
    loading();
    try {
      await api.roomVerifyRoomJoin(
        V1VerifyRoomJoinArgs(
          roomId: roomId,
          id: ids,
          status: status,
          refuseContent: refuseContent,
        ),
      );
      if (mounted) getList(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  // 是否全选
  bool checkAll() {
    var ck = true;
    for (var v in list) {
      if (v.applyStatus != GApplyStatus.APPLY) continue;
      if (!ids.contains(v.id)) {
        ck = false;
      }
    }
    return ids.isNotEmpty && ck;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
    if (args['roomId'] == null) return;
    roomId = args['roomId'];
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('申请验证'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                GroupLog.path,
                arguments: {'roomId': roomId},
              );
            },
            child: Text(
              '日志'.tr(),
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      body: ThemeBody(
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (checkAll()) {
                  ids.clear();
                } else {
                  for (var v in list) {
                    if (v.applyStatus != GApplyStatus.APPLY) continue;
                    if (!ids.contains(v.id)) {
                      ids.add(v.id!);
                    }
                  }
                }
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    AppCheckbox(
                      value: checkAll(),
                      paddingRight: 10,
                    ),
                    Text(
                      '全选'.tr(),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: PagerBox(
                limit: limit,
                onInit: () async {
                  //初始化
                  return await getList(init: true);
                },
                onPullDown: () async {
                  //下拉刷新
                  return await getList(init: true);
                },
                onPullUp: () async {
                  //上拉加载
                  return await getList();
                },
                children: list.map((e) {
                  var id = e.id ?? '';
                  var active = ids.contains(e.id);
                  var disabled = e.applyStatus != GApplyStatus.APPLY;
                  String status = '';
                  String from = '卡片分享';
                  switch (e.applyStatus) {
                    case GApplyStatus.APPLY:
                      status = '等待审核'.tr();
                      break;
                    case GApplyStatus.SUCCESS:
                      status = '已通过'.tr();
                      break;
                    case GApplyStatus.REFUSE:
                      status = '已拒绝'.tr();
                      break;
                    case GApplyStatus.NIL:
                      break;
                    case GApplyStatus.BAN:
                      break;
                  }
                  switch (e.from) {
                    case GRoomFrom.CARD:
                      from = '群卡片邀请';
                      break;
                    case GRoomFrom.ADMIN_INVITE:
                      from = '管理员邀请';
                      break;
                    case GRoomFrom.ID:
                      break;
                    case GRoomFrom.NIL:
                      break;
                    case GRoomFrom.QR:
                      from = '二维码';
                      break;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: .5,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (disabled) return;
                        setState(() {
                          if (active) ids.remove(id);
                          if (!active) ids.add(id);
                        });
                      },
                      child: Row(
                        children: [
                          AppCheckbox(
                            disabled: disabled,
                            value: active,
                            paddingLeft: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: ChatItem(
                              onAvatarTap: () {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': e.userId ?? '',
                                    'friendFrom': 'ROOM',
                                    'roomId': roomId,
                                    'removeToTabs': true,
                                    'detail': GUserModel(
                                      avatar: e.avatar ?? '',
                                      nickname: e.nickname ?? '',
                                    ),
                                  },
                                );
                              },
                              onTitleTap: () {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': e.userId ?? '',
                                    'friendFrom': 'ROOM',
                                    'roomId': roomId,
                                    'removeToTabs': true,
                                    'detail': GUserModel(
                                      avatar: e.avatar ?? '',
                                      nickname: e.nickname ?? '',
                                    ),
                                  },
                                );
                              },
                              avatarSize: 46,
                              titleSize: 16,
                              data: ChatItemData(
                                icons: [e.avatar ?? ''],
                                title: e.nickname ?? '',
                                // text: ,
                              ),
                              hasSlidable: false,
                              end: !disabled
                                  ? Row(
                                      children: [
                                        CircleButton(
                                          onTap: () {
                                            manage(
                                                [e.id!], GApplyStatus.REFUSE);
                                          },
                                          title: '拒绝'.tr(),
                                          width: 52,
                                          height: 27,
                                          theme: AppButtonTheme.grey,
                                        ),
                                        const SizedBox(
                                          width: 11,
                                        ),
                                        CircleButton(
                                          onTap: () {
                                            manage(
                                                [e.id!], GApplyStatus.SUCCESS);
                                          },
                                          title: '通过'.tr(),
                                          width: 52,
                                          height: 27,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      status,
                                      style: TextStyle(
                                        color: myColors.textGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '通过${from != '二维码' ? '${e.inviterUserNickname}的' : '扫描'}$from进行申请',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    e.applyContent ?? '',
                                    style: TextStyle(
                                      color: myColors.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            AppButtonBottomBox(
              child: Row(
                children: [
                  Expanded(
                    child: CircleButton(
                      title: '拒绝',
                      height: 50,
                      width: 100,
                      fontSize: 14,
                      radius: 10,
                      theme: AppButtonTheme.grey,
                      onTap: () => manage(ids, GApplyStatus.REFUSE),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: CircleButton(
                      title: '通过',
                      height: 50,
                      fontSize: 14,
                      radius: 10,
                      onTap: () => manage(ids, GApplyStatus.SUCCESS),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// @override
// void dispose() {
//   super.dispose();
//   _textController.dispose();
// }

// //全选
// selectALL() {
//   setState(() {
//     activeIds = [];
//     activeIds.addAll(list1);
//   });
// }

// //清空
// clear() {
//   setState(() {
//     activeIds = [];
//   });
// }
// KeyboardBlur(
//   child:Column(
//     children: [
//       SearchInput(
//         autofocus: false,
//         controller: _textController,
//         onChanged: (value) {
//           setState(() {
//             _isInputWords = _textController.text.isNotEmpty;
//             searchList.clear();
//             for (int i = 0; i < list1.length; i++) {
//               if (list1[i].title.contains(_textController.text)) {
//                 searchList.add(list1[i]);
//               }
//             }
//           });
//         },
//       ),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 _button(selectALL, '全选'),
//                 const SizedBox(
//                   width: 5,
//                 ),
//                 _button(clear, '清空'),
//               ],
//             ),
//             Row(children: [
//               _button(refuse, '拒绝'),
//               const SizedBox(
//                 width: 5,
//               ),
//               _button(agree, '通过'),
//             ]),
//           ],
//         ),
//       ),
//       Expanded(
//         child: _isInputWords
//             ?
//             // 搜索后显示列
//             KeyboardBlur(
//                 child: Container(
//                   color: Colors.white,
//                   child: ListView.builder(
//                     itemCount: searchList.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           onChoose(searchList[index]);
//                           _textController.text = '';
//                           _isInputWords = false;
//                           FocusManager.instance.primaryFocus?.unfocus();
//                         },
//                         child: Row(
//                           children: [
//                             AppCheckbox(
//                               value: activeIds
//                                   // ignore: iterable_contains_unrelated_type
//                                   .contains(searchList[index].id!),
//                               size: 30,
//                               paddingLeft: 15,
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: ChatItem(
//                                 hasSlidable: false,
//                                 data: searchList[index],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               )
//             :
//             //未搜索显示列
//             ContactList(
//                 list: const [],
//                 orderList: list1.map((e) {
//                   return ContractData(
//                     widget: GestureDetector(
//                       onTap: () => onChoose(e),
//                       child: Row(
//                         children: [
//                           AppCheckbox(
//                             value: activeIds.contains(e),
//                             size: 30,
//                             paddingLeft: 15,
//                           ),
//                           Expanded(
//                             flex: 1,
//                             child: ChatItem(
//                               hasSlidable: false,
//                               data: e,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     name: e.title,
//                   );
//                 }).toList(),
//               ),
//       ),
//     ],
//   ),
// ),

//   Widget _button(Function() onTap, String content) {
//     return Container(
//       height: 50,
//       alignment: Alignment.topRight,
//       child: ElevatedButton(
//           onPressed: onTap,
//           child: Text(
//             content,
//             style: const TextStyle(fontSize: 12),
//           )),
//     );
//   }
