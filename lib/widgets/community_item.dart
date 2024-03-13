import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/popup_menu.dart';
import 'package:unionchat/widgets/url_text.dart';
import 'package:unionchat/widgets/user_name_tags.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../notifier/theme_notifier.dart';
import 'nine_photo.dart';

//长按菜单类型
enum MessagePopType {
  //删除
  delete,
}

extension MessagePopTypeExt on MessagePopType {
  String get toChar {
    switch (this) {
      case MessagePopType.delete:
        return '删除';
    }
  }
}

//朋友圈内容组件
class CommunityItem extends StatefulWidget {
  final CommunityItemData data;
  final String id; //动态id
  final bool isMe; //我的动态页
  final bool isCircle; //是否已经在圈子界面 点击圈子不再跳转圈子
  final bool isFriendCircle; //是否朋友圈显示点赞数量
  final bool isFriendCircleDetail; //是否朋友圈详情可以评论
  //点赞点击
  final Function(String)? onLikeTap;

  //评论点击
  final Function(String, String?)? onCommentTap;

  //评论用户
  final Function(String, String?)? commentUser;

  //删除评论
  final Function(MessagePopType, String)? onPopTap;

  //删除动态
  final Function()? delete;

  //是否显示底部border
  final bool bottomBorder;

  const CommunityItem({
    required this.data,
    required this.id,
    this.isCircle = false,
    this.delete,
    this.onPopTap,
    this.onLikeTap,
    this.onCommentTap,
    this.commentUser,
    this.isMe = false,
    this.isFriendCircle = false,
    this.isFriendCircleDetail = false,
    this.bottomBorder = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommunityItemState();
  }
}

class _CommunityItemState extends State<CommunityItem> {
  double avatarSize = 50;
  double avatarFrameHeightSize = 25;
  double avatarFrameWidthSize = 15;
  double avatarTopPadding = 7;

  List<MessagePopType> pops = [
    MessagePopType.delete, //删除
  ];
  List<CommentData> commentList = [];

  //点赞和评论整块区域
  commentLove() {
    var myColors = ThemeNotifier();
    Color tagColor = myColors.tagColor;
    // List<GUserTrendsLikesModel> like =
    //     widget.data.like != null && widget.data.like!.isNotEmpty
    //         ? widget.data.like!
    //         : [];
    List<GUserTrendsCommentModel> comments =
        widget.data.comments != null && widget.data.comments!.isNotEmpty
            ? widget.data.comments!
            : [];
    return Container(
      width: double.infinity,
      margin: comments.isNotEmpty
          ? const EdgeInsets.only(
              top: 10,
            )
          : null,
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          comments.isNotEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < comments.length; i++)
                        comments[i].userId == Global.user!.id ||
                                widget.data.userId == Global.user!.id
                            ? WPopupMenu(
                                onValueChanged: (j) {
                                  if (widget.onPopTap != null) {
                                    widget.onPopTap!(pops[j], comments[i].id!);
                                  }
                                },
                                menuWidth: pops.length * 50,
                                actions: pops.map((e) => e.toChar).toList(),
                                child: commentContainer(comments[i]),
                              )
                            : commentContainer(comments[i]),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  //单块评论区内容
  Widget commentContainer(GUserTrendsCommentModel v) {
    var myColors = ThemeNotifier();
    return
        //回复消息代码
        GestureDetector(
      onTap: () {
        if (widget.commentUser == null) return;
        if (v.userId == Global.user!.id) {
          return;
        }
        widget.commentUser!(widget.id, v.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: v.nickname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: myColors.blueTitle,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (v.userId == Global.user!.id) {
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            FriendDetails.path,
                            arguments: {
                              'id': v.userId ?? '',
                              'detail': GUserModel(
                                nickname: v.nickname,
                                avatar: v.avatar,
                              ),
                            },
                          );
                        },
                    ),
                    if (v.replyNickname != null && v.replyNickname!.isNotEmpty)
                      TextSpan(text: ' 回复 '.tr()),
                    if (v.replyNickname != null && v.replyNickname!.isNotEmpty)
                      TextSpan(
                        text: '${v.replyNickname}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: myColors.blueTitle,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (v.replyUserId == Global.user!.id) {
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              FriendDetails.path,
                              arguments: {
                                'id': v.replyUserId ?? '',
                                'detail': GUserModel(
                                  nickname: v.replyNickname,
                                  avatar: v.replyAvatar,
                                ),
                              },
                            );
                          },
                      ),
                    const TextSpan(
                      text: ' : ',
                    ),
                    TextSpan(
                      text: v.content?.trim(),
                    ),
                  ],
                ),
              ),
            ),
            // Text(
            //   time2formatDate(v.createTime),
            //   style: TextStyle(fontSize: 11, color: myColors.textGrey),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color primary = myColors.primary;
    Color textColor = myColors.iconThemeColor;

    var data = widget.data;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: widget.bottomBorder
                ? Border(
                    bottom: BorderSide(
                      color: myColors.circleBorder,
                      width: 5,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    right: 16,
                    left: data.userVip ? 4 : avatarFrameWidthSize / 8),
                child: Row(
                  children: [
                    Container(
                      width: avatarSize + avatarFrameWidthSize + 16,
                      height: avatarSize + avatarFrameWidthSize + 10,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: data.userId == Global.user?.id
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': data.userId,
                                    'detail': GUserModel(
                                      nickname: data.nickName,
                                      avatar: data.avatar,
                                    ),
                                  },
                                );
                              },
                        child: AppAvatar(
                          list: [
                            data.avatar,
                          ],
                          userName: data.nickName,
                          userId: data.userId,
                          vip: data.userVip,
                          vipLevel: data.userVipLevel,
                          avatarFrameHeightSize: avatarFrameHeightSize,
                          avatarFrameWidthSize: avatarFrameWidthSize,
                          avatarTopPadding: avatarTopPadding,
                          size: avatarSize,
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 5,
                    // ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///////////////////////////名称 vip
                          Row(
                            children: [
                              Expanded(
                                child: UserNameTags(
                                  userName: data.nickName,
                                  vip: data.userVip,
                                  vipLevel: data.userVipLevel,
                                  vipBadge: data.vipBadge,
                                  onlyName: data.userOnlyName,
                                  goodNumber:
                                      (data.userNumber ?? '').isNotEmpty,
                                  numberType:
                                      data.numberType ?? GUserNumberType.NIL,
                                  circleGuarantee: data.circleGuarantee,
                                  fontSize: 18,
                                  iconSize: 18,
                                  fontWeight: FontWeight.normal,
                                  select: false,
                                  system: data.userInfo?.customerType ==
                                      GCustomerType.SYSTEM,
                                  customer: data.userInfo?.customerType ==
                                      GCustomerType.MERCHANT,
                                  // needMarqueeText: true,
                                ),
                              ),
                              //详情页显示删除按钮
                              if (widget.isMe)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.delete != null) {
                                        widget.delete!();
                                      }
                                    },
                                    child: Image.asset(
                                      assetPath(
                                          'images/friend_circle/sp_shanchu.png'),
                                      width: 17,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ///////////////////////时间  发布地址
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //圈子标记
                              if (data.target != null &&
                                  data.target!.isNotEmpty)
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: widget.isCircle
                                          ? null
                                          : () {
                                              Navigator.pushNamed(
                                                  context, GroupHome.path,
                                                  arguments: {
                                                    'circleId': data.targetId
                                                  });
                                            },
                                      child: Container(
                                        height: 20,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: myColors.circleTagBg,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              data.target!,
                                              style: TextStyle(
                                                color: myColors.circleTagTitle,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              if (data.areaName != null &&
                                  data.areaName!.isNotEmpty)
                                Row(
                                  children: [
                                    Image.asset(
                                      assetPath('images/help/weizhi.png'),
                                      width: 11,
                                      height: 13,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      data.areaName!,
                                      style: TextStyle(
                                        color: myColors.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              Text(
                                time2formatDate(data.date),
                                style: TextStyle(
                                  color: myColors.textGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //正文内容
                          if (data.text != null && data.text!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: UrlText(
                                data.text!,
                                select: true,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          //图片内容
                          if (data.photos != null && data.photos!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: PhotoList(
                                photos: data.photos!,
                                type: data.photosType!,
                                width: platformPhone
                                    ? MediaQuery.of(context).size.width - 32
                                    : MediaQuery.of(context).size.width - 806,
                              ),
                            ),
                          //点赞按钮列
                          if (widget.isFriendCircle)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (widget.onLikeTap == null) {
                                            return;
                                          }
                                          widget.onLikeTap!(widget.id);
                                        },
                                        child: Container(
                                          width: 18,
                                          height: 19,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            data.isLike != null && data.isLike!
                                                ? assetPath(
                                                    'images/friend_circle/sp_dianzan_0.png')
                                                : assetPath(
                                                    'images/friend_circle/sp_dianzan.png'),
                                            color: (myColors.isDark &&
                                                        data.isLike != null &&
                                                        data.isLike! ||
                                                    !myColors.isDark)
                                                ? null
                                                : myColors.textGrey,
                                            width: 18,
                                            height: 19,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      if (data.like != null)
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 6,
                                          ),
                                          width: 25,
                                          child: Text(
                                            data.like!.isNotEmpty
                                                ? data.like!.length.toString()
                                                : '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: data.isLike!
                                                  ? primary
                                                  : myColors.textGrey,
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  //评论按钮
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: widget.onCommentTap == null
                                            ? null
                                            : () {
                                                // if (widget.onCommentTap == null) return;
                                                widget.onCommentTap!(
                                                    widget.id, null);
                                              },
                                        child: Container(
                                          width: 18,
                                          height: 19,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            data.comments != null &&
                                                    data.comments!.isNotEmpty
                                                ? assetPath(
                                                    'images/friend_circle/sp_pinlun_0.png')
                                                : assetPath(
                                                    'images/friend_circle/sp_pinlun.png'),
                                            color: (myColors.isDark &&
                                                        data.comments != null &&
                                                        data.comments!
                                                            .isNotEmpty ||
                                                    !myColors.isDark)
                                                ? null
                                                : myColors.textGrey,
                                            width: 18,
                                            height: 19,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      if (data.comments != null &&
                                          data.comments!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: Text(
                                            data.commentsCount ?? '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: data.comments!.isNotEmpty
                                                  ? primary
                                                  : myColors.textGrey,
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //点赞列、评论列
              if (widget.isFriendCircleDetail)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: commentLove(),
                ),
            ],
          ),
        ),
        widget.bottomBorder
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Divider(color: myColors.im2Boder, height: .5),
              )
            : Container(),
      ],
    );
  }
}

//朋友圈内容数据modal
class CommunityItemData {
  //用户信息
  final GUserModel? userInfo;
  //动态id
  final String id;

  //用户id
  final String userId;

  //头像
  final String avatar;

  //昵称
  final String nickName;

  //是否是靓号
  final String? userNumber;

  final GUserNumberType? numberType;

  //用户是否属于保圈
  final bool circleGuarantee;

  //用户是否是vip
  final bool userVip;

  //用户是否是vip
  final GVipLevel userVipLevel;

  //用户会员标志
  final GBadge vipBadge;

  //用户是否是唯名卡
  final bool userOnlyName;

  //文本内容
  final String? text;

  //图片
  final List<String>? photos;

  //图片类型
  final GArticleType? photosType;

  //日期
  final String date;

  //圈子id
  final String? targetId;

  //圈子标签
  final String? target;

  //圈子发布地址
  final String? areaName;

  //我是否点赞
  bool? isLike;

  //点赞用户
  List<GUserTrendsLikesModel>? like;

  //评论列表
  List<GUserTrendsCommentModel>? comments;

  //评论数量
  String? commentsCount;

  CommunityItemData({
    this.userInfo,
    required this.id,
    required this.avatar,
    required this.userId,
    required this.nickName,
    this.userNumber,
    this.numberType = GUserNumberType.NIL,
    this.circleGuarantee = false,
    this.userVip = false,
    this.userVipLevel = GVipLevel.NIL,
    this.vipBadge = GBadge.NIL,
    this.userOnlyName = false,
    this.text,
    this.photos,
    this.photosType,
    this.date = '',
    this.targetId,
    this.target,
    this.areaName,
    this.isLike,
    this.like,
    this.comments,
    this.commentsCount,
  });
}

class CommentData {
  GUserTrendsCommentModel? data;
  List<GUserTrendsCommentModel>? list;

  CommentData({
    required this.data,
    this.list,
  });
}
