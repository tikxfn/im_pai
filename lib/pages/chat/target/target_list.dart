import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/channel_group.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/chat/target/target_form.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/dialog_widget.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';
import '../../../widgets/button.dart';

class ChatTargetList extends StatefulWidget {
  const ChatTargetList({super.key});

  static const String path = 'chat/target/list';

  @override
  State<ChatTargetList> createState() => _ChatTargetListState();
}

class _ChatTargetListState extends State<ChatTargetList>
    with TickerProviderStateMixin {
  TextEditingController ctr = TextEditingController();
  bool showDelete = false;
  List<String> choice = [];
  String selected = '';
  List<ChatItemData> _channel = [];
  late AnimationController animationController;

  // 获取channel
  _getChannel() async {
    if (!mounted) return;
    _channel = (await MessageUtil.listAllChannel())
        .map((e) => channel2chatItem(e))
        .toList();
    setState(() {});
  }

  //删除分组
  deleteTarget(String name) async {
    confirm(
      context,
      title: '确认删除此分组'.tr(),
      onEnter: () async {
        loading();
        List<String> ids = [];
        for (var v in _channel) {
          //标签
          if (v.group != null) {
            if (v.group!.contains(name)) {
              ids.add(v.pairId!);
            }
          }
        }
        try {
          await MessageUtil.editGroup(ids, name, '');
          if (mounted) {
            choice = [];
            setState(() {});
            _getChannel();
          }
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  //删除成员
  deleteMembers({String name = '', List<String>? ids}) {
    if (ids == null || ids.isEmpty) return;
    confirm(
      context,
      title: '确认删除所选成员'.tr(),
      onEnter: () async {
        loading();
        try {
          await MessageUtil.editGroup(ids, name, '');
          if (mounted) {
            choice = [];
            setState(() {});
            _getChannel();
          }
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  List<String> systemList = ['消息', '未读', '单聊', '群聊'];
  //修改名称
  updateName({required String name}) async {
    if (name == ctr.text) {
      Navigator.pop(context);
      return;
    }
    if (ctr.text.trim().isEmpty) {
      tipError('请输入组名'.tr());
      return;
    }
    if (systemList.contains(ctr.text.trim())) {
      tipError('系统已预设该分组'.tr());
      return;
    }
    List<String> oldChoice = [];
    List<String> choice = [];
    String oldGroupName = name;
    for (var v in _channel) {
      if (v.group != null && v.group!.contains(name)) {
        //记录原来分组中的id
        choice.add(v.pairId!);
        oldChoice.add(v.pairId!);
      }
    }
    loading();
    try {
      await MessageUtil.editGroup(choice, oldGroupName, ctr.text);
      if (mounted) {
        Navigator.pop(context);
        _getChannel();
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ctr.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getChannel());
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  //旋转动画
  _changeOpacity(bool expand) {
    setState(() {
      if (expand) {
        animationController.forward(); //正向
      } else {
        animationController.reverse(); //反向
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天分组'.tr()),
        actions: [
          Container(
            alignment: Alignment.center,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDelete = !showDelete;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 17),
                    child: showDelete
                        ? Text(
                            '取消'.tr(),
                            style: TextStyle(color: myColors.blueTitle),
                          )
                        : const Icon(
                            Icons.settings,
                            size: 22,
                          ),
                  ),
                ),
                if (!showDelete)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ChatTargetForm.path,
                      ).then((value) => _getChannel());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset(
                        assetPath('images/add.png'),
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      body: ThemeBody(
        topPadding: 5,
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: ChannelGroupOperator.groups,
                builder: (context, targets, _) {
                  return ListView.builder(
                    itemCount: targets.length,
                    itemBuilder: (context, i) {
                      final controller = ExpandableController(
                          initialExpanded: selected == targets[i]);
                      return Column(
                        children: [
                          ExpandableNotifier(
                            controller: controller,
                            child: Expandable(
                              //折叠时
                              collapsed: GestureDetector(
                                onTap: () {
                                  _changeOpacity(true);
                                  setState(() {
                                    selected = targets[i];
                                    choice = [];
                                    logger.i(selected == targets[i]);
                                  });
                                },
                                child: titleWidget(
                                  titleName: targets[i],
                                ),
                              ),
                              //展开时
                              expanded: Column(
                                children: [
                                  //title
                                  GestureDetector(
                                    onTap: () {
                                      _changeOpacity(false);
                                      setState(() {
                                        selected = '';
                                        choice = [];
                                      });
                                    },
                                    child: titleWidget(
                                      titleName: targets[i],
                                    ),
                                  ),
                                  //列表
                                  Column(
                                    children: _channel.map((e) {
                                      if (e.group == null ||
                                          !e.group!.contains(targets[i])) {
                                        return Container();
                                      }
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: selected == targets[i]
                                            ? () {
                                                if (choice.contains(e.pairId)) {
                                                  choice.remove(e.pairId);
                                                } else {
                                                  choice.add(e.pairId!);
                                                }
                                                setState(() {});
                                              }
                                            : null,
                                        child: Container(
                                          color: choice.contains(e.pairId)
                                              ? myColors.listCheckedBg
                                              : null,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: ChatItem(
                                                  data: ChatItemData(
                                                    id: e.id,
                                                    pairId: e.pairId,
                                                    icons: e.icons,
                                                    title: e.title,
                                                    mark: e.mark,
                                                    vip: e.vip,
                                                    vipLevel: e.vipLevel,
                                                    vipBadge: e.vipBadge,
                                                    goodNumber: e.goodNumber,
                                                    circleGuarantee:
                                                        e.circleGuarantee,
                                                    numberType: e.numberType,
                                                    userNumber: e.userNumber,
                                                    room: e.room,
                                                  ),
                                                  avatarSize: 46,
                                                  hasSlidable: false,
                                                  titleSize: 16,
                                                  border: false,
                                                ),
                                              ),
                                              AppCheckbox(
                                                value:
                                                    choice.contains(e.pairId),
                                                paddingRight: 20,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    color: myColors.white,
                                    child: CircleButton(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ChatTargetForm.path,
                                          arguments: {
                                            'oldGroupName': targets[i],
                                          },
                                        ).then((value) => _getChannel());
                                      },
                                      title: '新增',
                                      fontSize: 16,
                                      height: 45,
                                      theme: AppButtonTheme.blue0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(height: 5, color: myColors.circleBorder),
                        ],
                      );
                    },
                  );

                  // return ListView.builder(
                  //   itemCount: targets.length,
                  //   itemBuilder: (context, i) {
                  //     return Column(
                  //       children: [
                  //         ExpansionTile(
                  //           shape: Border.all(style: BorderStyle.none),
                  //           collapsedBackgroundColor: null,
                  //           collapsedTextColor: null,
                  //           collapsedIconColor: null,
                  //           textColor: myColors.iconThemeColor,
                  //           iconColor: myColors.iconThemeColor,
                  //           controlAffinity: ListTileControlAffinity.leading,
                  //           maintainState: true,
                  //           onExpansionChanged: (value) {
                  //             setState(() {
                  //               if (value) {
                  //                 selected = targets[i];
                  //                 choice = [];
                  //               }
                  //             });
                  //           },
                  //           title: Text(
                  //             targets[i],
                  //             style: const TextStyle(
                  //               overflow: TextOverflow.ellipsis,
                  //             ),
                  //           ),
                  //           trailing: showDelete
                  //               ? Row(
                  //                   crossAxisAlignment: CrossAxisAlignment.end,
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   children: [
                  //                     GestureDetector(
                  //                       onTap: () {
                  //                         ctr.text = targets[i];
                  //                         showDialogWidget(
                  //                           context: context,
                  //                           child: updateNameWidget(
                  //                             name: targets[i],
                  //                           ),
                  //                         );
                  //                       },
                  //                       child: Container(
                  //                         padding:
                  //                             const EdgeInsets.only(right: 20),
                  //                         child: Image.asset(
                  //                           assetPath(
                  //                               'images/talk/arcoss_bianji.png'),
                  //                           color: myColors.iconThemeColor,
                  //                           width: 18,
                  //                           height: 18,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     GestureDetector(
                  //                       onTap: () {
                  //                         deleteTarget(targets[i]);
                  //                       },
                  //                       child: Container(
                  //                         padding:
                  //                             const EdgeInsets.only(right: 16),
                  //                         child: Image.asset(
                  //                           assetPath('images/delete.png'),
                  //                           color: myColors.iconThemeColor,
                  //                           width: 20,
                  //                           height: 18,
                  //                           fit: BoxFit.contain,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 )
                  //               : null,
                  //           children: [
                  //             Column(
                  //               children: _channel.map((e) {
                  //                 if (e.group == null ||
                  //                     !e.group!.contains(targets[i])) {
                  //                   return Container();
                  //                 }
                  //                 return GestureDetector(
                  //                   behavior: HitTestBehavior.opaque,
                  //                   onTap: selected == targets[i]
                  //                       ? () {
                  //                           if (choice.contains(e.pairId)) {
                  //                             choice.remove(e.pairId);
                  //                           } else {
                  //                             choice.add(e.pairId!);
                  //                           }
                  //                           setState(() {});
                  //                         }
                  //                       : null,
                  //                   child: Container(
                  //                     color: choice.contains(e.pairId)
                  //                         ? myColors.listCheckedBg
                  //                         : null,
                  //                     child: Row(
                  //                       children: [
                  //                         Expanded(
                  //                           flex: 1,
                  //                           child: ChatItem(
                  //                             data: ChatItemData(
                  //                               id: e.id,
                  //                               pairId: e.pairId,
                  //                               icons: e.icons,
                  //                               title: e.title,
                  //                               mark: e.mark,
                  //                               vip: e.vip,
                  //                               vipLevel: e.vipLevel,
                  //                               vipBadge: e.vipBadge,
                  //                               goodNumber: e.goodNumber,
                  //                               circleGuarantee:
                  //                                   e.circleGuarantee,
                  //                               numberType: e.numberType,
                  //                               userNumber: e.userNumber,
                  //                               room: e.room,
                  //                             ),
                  //                             avatarSize: 46,
                  //                             hasSlidable: false,
                  //                             titleSize: 16,
                  //                             border: false,
                  //                           ),
                  //                         ),
                  //                         if (selected == targets[i])
                  //                           AppCheckbox(
                  //                             value: choice.contains(e.pairId),
                  //                             paddingRight: 20,
                  //                             size: 22,
                  //                           ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 );
                  //               }).toList(),
                  //             ),
                  //             Container(
                  //               padding: const EdgeInsets.all(16),
                  //               color: myColors.white,
                  //               child: CircleButton(
                  //                 onTap: () {
                  //                   Navigator.pushNamed(
                  //                     context,
                  //                     ChatTargetForm.path,
                  //                     arguments: {
                  //                       'oldGroupName': targets[i],
                  //                     },
                  //                   ).then((value) => _getChannel());
                  //                 },
                  //                 title: '新增',
                  //                 fontSize: 16,
                  //                 height: 45,
                  //                 theme: AppButtonTheme.blue0,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         Container(height: 5, color: myColors.circleBorder),
                  //       ],
                  //     );
                  //   },
                  // );
                },
              ),
            ),
            //底部按钮
            if (choice.isNotEmpty) buttonWidget(),
          ],
        ),
      ),
    );
  }

  //修改名称弹窗样式
  Widget updateNameWidget({required String name}) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: myColors.themeBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //标题
          Stack(
            alignment: Alignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '分组名称:'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: myColors.iconThemeColor,
                  ),
                ),
              ]),
              Positioned(
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: myColors.iconThemeColor,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: AppTextarea(
              hintText: '请输入名称'.tr(),
              controller: ctr,
              radius: 15,
              maxLength: null,
              minLines: 1,
            ),
          ),
          //按钮
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: CircleButton(
              theme: AppButtonTheme.blue,
              title: '确定'.tr(),
              height: 40,
              fontSize: 14,
              onTap: () {
                updateName(name: name);
              },
            ),
          ),
        ],
      ),
    );
  }

  //底部按钮
  Widget buttonWidget() {
    var myColors = ThemeNotifier();
    return Container(
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        color: myColors.bottom,
        boxShadow: [
          BoxShadow(
            color: myColors.bottomShadow,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: CircleButton(
                onTap: () {
                  choice = [];
                  setState(() {});
                },
                title: '取消'.tr(),
                radius: 10,
                theme: AppButtonTheme.blue0,
                fontSize: 16,
                height: 47,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: CircleButton(
                onTap: () async {
                  deleteMembers(name: selected, ids: choice);
                },
                title: '删除'.tr(),
                radius: 10,
                theme: AppButtonTheme.red,
                fontSize: 16,
                height: 47,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleWidget({required String titleName}) {
    var myColors = context.watch<ThemeNotifier>();
    return ListTile(
      leading: selected == titleName
          ? RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25).animate(animationController),
              child: const Icon(Icons.chevron_right),
            )
          : const Icon(Icons.chevron_right),
      title: Text(titleName),
      trailing: showDelete
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    ctr.text = titleName;
                    showDialogWidget(
                      context: context,
                      child: updateNameWidget(
                        name: titleName,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Image.asset(
                      assetPath('images/talk/arcoss_bianji.png'),
                      color: myColors.iconThemeColor,
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    deleteTarget(titleName);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 16),
                    child: Image.asset(
                      assetPath('images/delete.png'),
                      color: myColors.iconThemeColor,
                      width: 20,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class ChatTargetData {
  final String title;
  final int count;
  final String id;

  ChatTargetData({
    required this.title,
    required this.id,
    this.count = 0,
  });
}
