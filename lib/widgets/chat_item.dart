import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/user_name_tags.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import 'avatar.dart';

//聊天列表组件
class ChatItem extends StatelessWidget {
  //列表数据
  final ChatItemData data;

  //删除点击
  final Function()? onDelete;

  //点击置顶
  final Function()? onTop;

  //点击静音
  final Function()? onMute;

  //是否显示左滑菜单
  final bool hasSlidable;

  // 是否显示置顶按钮
  final bool showTop;

  // 是否显示免打扰按钮
  final bool showMute;

  //列表点击
  final Function()? onTap;

  //头像点击
  final Function()? onAvatarTap;

  //名称点击
  final Function()? onTitleTap;

  //头像大小
  final double avatarSize;

  //有头像框时，增加头像框大小
  //............
  final double avatarFrameSizeHight;
  final double avatarFrameSizeWidth;
  final double avatarTopPadding;

  //..............

  //标题文字大小
  final double titleSize;

  //内容文字大小
  final double subtitleFontSize;

  //左边距
  final double paddingLeft;

  //上下边距
  final double paddingVertical;

  //是否显示底部border
  final bool border;

  //内容超出是否隐藏
  final bool textOverHide;

  //是否隐藏头像
  final bool hideAvatar;

  //显示在线状态
  final bool onlineStatus;

  //背景颜色
  final Color? backgroundColor;

  //内容组件
  final Widget? child;

  //右侧组件
  final Widget? end;

  //文本右侧组件
  final Widget? textEnd;

  //标题组件
  final Widget? titleWidget;

  // 是否选中
  final bool active;

  // 消息转发样式
  final bool forward;

  const ChatItem({
    required this.data,
    this.onDelete,
    this.onMute,
    this.onTop,
    this.onTap,
    this.onAvatarTap,
    this.onTitleTap,
    this.avatarSize = 53,
    this.avatarFrameSizeHight = 27,
    this.avatarFrameSizeWidth = 18,
    this.avatarTopPadding = 7,
    this.titleSize = 14,
    this.subtitleFontSize = 13,
    this.paddingLeft = 18,
    this.paddingVertical = 5,
    this.border = false,
    this.hasSlidable = true,
    this.onlineStatus = false,
    this.showTop = true,
    this.showMute = false,
    this.textOverHide = true,
    this.hideAvatar = false,
    this.backgroundColor,
    this.child,
    this.end,
    this.textEnd,
    this.titleWidget,
    this.active = false,
    this.forward = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    String onlineTime = time2onlineDate(
      data.lastOnlineTime.toString(),
      joinStr: '在线'.tr(),
      zeroStr: '在线'.tr(),
    );
    bool online = onlineTime == '在线'.tr();
    double onlinePadding = 0;
    if (data.vipLevel == GVipLevel.n5) onlinePadding = 2.5;
    if (data.vipLevel == GVipLevel.n6) onlinePadding = 5;
    return SwipeActionCell(
      key: ObjectKey(data.id),
      trailingActions: hasSlidable
          ? [
              SwipeAction(
                title: '删除'.tr(),
                color: myColors.red,
                style: TextStyle(
                  fontSize: 14,
                  color: myColors.white,
                ),
                onTap: (handler) async {
                  await handler(false);
                  onDelete?.call();
                },
              ),
              if (showTop)
                SwipeAction(
                  style: TextStyle(
                    fontSize: 14,
                    color: myColors.white,
                  ),
                  onTap: (handler) async {
                    await handler(false);
                    onTop?.call();
                  },
                  color: myColors.primary,
                  title: data.isTop ? '取消置顶'.tr() : '置顶'.tr(),
                ),
              if (showMute)
                SwipeAction(
                  style: TextStyle(
                    fontSize: 14,
                    color: myColors.white,
                  ),
                  onTap: (handler) async {
                    await handler(false);
                    onMute?.call();
                  },
                  color: myColors.yellow,
                  title: data.doNotDisturb ? '取消静音'.tr() : '静音'.tr(),
                ),
            ]
          : [],
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: active ? myColors.vipBuyExp : backgroundColor,
          child: Row(
            crossAxisAlignment:
                forward ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (hideAvatar)
                SizedBox(
                  width: avatarSize + avatarFrameSizeWidth + 16,
                  height: avatarSize + avatarFrameSizeWidth + 8, // 53 15 8
                  // width: avatarSize + avatarFrameSizeWidth + 8,
                  // height: avatarSize + avatarFrameSizeWidth + 8,
                ),
              if (!hideAvatar)
                Container(
                  width: avatarSize + avatarFrameSizeWidth + 16,
                  height: avatarSize + avatarFrameSizeWidth + 8, // 53 15 8
                  // width: avatarSize + avatarFrameSizeWidth + 8,
                  // height: avatarSize + avatarFrameSizeWidth + 8,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: onAvatarTap != null || onTap != null
                        ? () {
                            if (onAvatarTap != null) {
                              onAvatarTap!();
                            } else {
                              onTap!();
                            }
                          }
                        : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AppAvatar(
                          list: data.icons,
                          size: avatarSize,
                          userName: data.title,
                          userId: data.id ?? '',
                          vip: data.vip,
                          vipLevel: data.vipLevel,
                          avatarFrameHeightSize: avatarFrameSizeHight,
                          avatarFrameWidthSize: avatarFrameSizeWidth,
                          avatarTopPadding: data.vip ? avatarTopPadding : 0,
                        ),
                        data.room
                            ? Positioned(
                                right: 0,
                                bottom: 0,
                                child: Image.asset(
                                  assetPath('images/talk/sp_qunzu.png'),
                                  width: 21,
                                  height: 21,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : onlineStatus
                                ? Positioned(
                                    right:
                                        // data.vip ? avatarFrameSizeWidth / 2 : 0,
                                        data.vip
                                            ? avatarFrameSizeWidth / 2 +
                                                onlinePadding
                                            : 0,
                                    bottom:
                                        data.vip ? avatarFrameSizeWidth / 2 : 0,
                                    child: Image.asset(
                                      assetPath(
                                          'images/talk/${online ? 'online' : 'offline'}.png'),
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Container(),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: avatarSize + avatarFrameSizeWidth + 8, //10
                  ),
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    border: border
                        ? Border(
                            bottom: BorderSide(
                              color: myColors.lineGrey,
                              width: .5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (data.room)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Text(
                                      '[群聊]'.tr(),
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        color: myColors.blueTitle,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: onTitleTap != null ||
                                                  onTap != null
                                              ? () {
                                                  if (onTitleTap != null) {
                                                    onTitleTap!();
                                                  } else {
                                                    onTap!();
                                                  }
                                                }
                                              : null,
                                          child: titleWidget != null
                                              ? titleWidget!
                                              :
                                              // SizedBox(
                                              //     height: 25,
                                              //     child:
                                              UserNameTags(
                                                  select: false,
                                                  color: active
                                                      ? myColors.white
                                                      : null,
                                                  userName: data.title,
                                                  mark: data.mark,
                                                  system: data.userType ==
                                                      UserType.system,
                                                  customer: data.userType ==
                                                      UserType.customer,
                                                  goodNumber: data.goodNumber,
                                                  numberType: data.numberType,
                                                  circleGuarantee:
                                                      data.circleGuarantee,
                                                  vip: data.vip,
                                                  vipLevel: data.vipLevel,
                                                  vipBadge: data.vipBadge,
                                                  onlyName: data.onlyName,
                                                  fontSize: titleSize,
                                                  // room: data.room,
                                                  // ),
                                                ),
                                        ),
                                      ),
                                      if (data.isTop)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Image.asset(
                                            assetPath(
                                                'images/talk/zhiding.png'),
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (data.time.isNotEmpty)
                                  //消息时间
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      data.time,
                                      style: TextStyle(
                                        color: active
                                            ? myColors.white
                                            : myColors.subIconThemeColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (child != null) child!,
                            if (data.text.isNotEmpty)
                              //消息内容
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text.rich(
                                        overflow: textOverHide
                                            ? TextOverflow.ellipsis
                                            : null,
                                        style: TextStyle(
                                          color: active
                                              ? myColors.white
                                              : myColors.subIconThemeColor,
                                          fontSize: subtitleFontSize,
                                        ),
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: subtitleFontSize,
                                          ),
                                          children: [
                                            if (data.at && data.draft.isEmpty)
                                              TextSpan(
                                                text: '${'[有人@我]'.tr()} ',
                                                style: TextStyle(
                                                  color: myColors.redTitle,
                                                ),
                                              ),
                                            if (data.doNotDisturb &&
                                                data.notReadNumber > 0 &&
                                                data.draft.isEmpty)
                                              TextSpan(
                                                text: '[条]'.tr(
                                                  args: [
                                                    data.notReadNumber
                                                        .toString()
                                                  ],
                                                ),
                                              ),
                                            if (data.draft.isNotEmpty)
                                              TextSpan(
                                                text: '[草稿]',
                                                style: TextStyle(
                                                  color: myColors.redTitle,
                                                ),
                                              ),
                                            TextSpan(
                                              text: (data.draft.isEmpty
                                                      ? data.text
                                                      : data.draft)
                                                  .trim()
                                                  .replaceAll('\n', ''),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  textEnd != null
                                      ? textEnd!
                                      : Badge(
                                          isLabelVisible:
                                              data.notReadNumber > 0,
                                          backgroundColor: myColors.redTitle,
                                          label: Text(
                                            data.notReadNumber.toString(),
                                          ),
                                          largeSize: 14,
                                        ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (end != null) end!
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
}

//聊天列表数据modal
class ChatItemData {
  final String? id;
  final String? pairId;

  //头像
  final List<String> icons;

  //标题
  String title;

  //内容
  final String text;

  //时间
  String time;

  //未读消息数量
  final int badges;

  //是否是群
  final bool room;

  //是否置顶
  final bool isTop;

  //未读消息
  int notReadNumber;

  //新消息是否提醒
  final bool doNotDisturb;

  //备注
  final String mark;

  //是否是vip
  bool vip;

  GVipLevel vipLevel;

  //vip标志
  GBadge vipBadge;

  //是否是唯名卡
  bool onlyName;

  //是否是靓号
  bool goodNumber;

  //是否属于保圈
  bool circleGuarantee;

  //靓号类型
  GUserNumberType numberType;

  //靓号
  final String userNumber;

  //账号
  final String account;

  //手机号
  final String phone;

  //用户类型
  final UserType userType;

  //是否有@我
  final bool at;

  //草稿
  final String draft;

  //@我的消息id
  final String atMessageId;

  // 已读id
  final int readId;

  // 来源
  final dynamic origin;

  //分组的名称
  List<String>? group;

  // 最后在线时间
  final int? lastOnlineTime;

  ChatItemData({
    required this.icons,
    required this.title,
    this.id,
    this.pairId,
    this.text = '',
    this.time = '',
    this.draft = '',
    this.badges = 0,
    this.room = false,
    this.isTop = false,
    this.notReadNumber = 0,
    this.doNotDisturb = false,
    this.mark = '',
    this.userNumber = '',
    this.account = '',
    this.phone = '',
    this.numberType = GUserNumberType.NIL,
    this.circleGuarantee = false,
    this.userType = UserType.nil,
    this.vipLevel = GVipLevel.NIL,
    this.vipBadge = GBadge.NIL,
    this.vip = false,
    this.goodNumber = false,
    this.onlyName = false,
    this.at = false,
    this.atMessageId = '',
    this.readId = 0,
    this.origin,
    this.group,
    this.lastOnlineTime,
  });

  set value(bool value) {}
}
