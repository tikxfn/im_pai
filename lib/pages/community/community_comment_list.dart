import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/pop_route.dart';
import 'package:unionchat/widgets/comment_input.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/popup_menu.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

//长按菜单类型
enum MessagePopType {
  //删除
  delete,
}

extension MessagePopTypeExt on MessagePopType {
  String get toChar {
    switch (this) {
      case MessagePopType.delete:
        return '删除'.tr();
    }
  }
}

// ignore: must_be_immutable
class CommunityCommentList extends StatefulWidget {
  GUserTrendsCommentModel data;
  String commentId;

  CommunityCommentList({
    required this.data,
    required this.commentId,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CommunityCommentListState();
}

class _CommunityCommentListState extends State<CommunityCommentList> {
  // List<CommentData> commentList = [];
  List<GUserTrendsCommentModel> commentList = [];

  // String communityId = '';
  // String replyId = '';

  //获取二级评论列表
  communityList({
    String? communityId,
    String? replyId,
    bool init = false,
  }) async {
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsListUserTrendsComment(
        V1ListUserTrendsCommentArgs(
          id: communityId,
          replyId: replyId,
        ),
      );
      if (res == null) return;
      if (!mounted) return;
      List<GUserTrendsCommentModel> l = res.list.toList();

      if (init) {
        commentList = l;
      } else {
        commentList.addAll(l);
      }
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //展开评论输入框
  openCommentInput(String? commentId) {
    Navigator.push(
      context,
      PopRoute(
        child: CommentInput(
          onSend: sendComment,
          id: widget.commentId,
          commentId: commentId ?? '0',
        ),
      ),
    );
  }

  //发送评论
  sendComment(
    String str,
    String id,
    String? userCommentId,
  ) async {
    logger.i('动态id: $id 对方id:$userCommentId 评论内容: $str ');
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsAddUserTrendsComment(
        V1AddUserTrendsCommentArgs(
          id: widget.commentId,
          content: str,
          commentId: userCommentId,
        ),
      );
      communityList(
        init: true,
        communityId: widget.commentId,
        replyId: widget.data.id,
      );
      if (res == null) return;
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

//长按评论   目前只有删除评论
  deleteComment(MessagePopType type, String id) async {
    logger.i(id);
    switch (type) {
      case MessagePopType.delete:
        final api = UserTrendsApi(apiClient());
        try {
          await api.userTrendsDelUserTrendsCommentWithHttpInfo(
            GIdArgs(
              id: id,
            ),
          );
          communityList(
            init: true,
            communityId: widget.commentId,
            replyId: widget.data.id,
          );
          // communityList(init: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {}
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    communityList(
      init: true,
      communityId: widget.commentId,
      replyId: widget.data.id,
    );
  }

  //单块评论区内容
  Widget commentContainer(GUserTrendsCommentModel v) {
    var myColors = ThemeNotifier();
    return
        //回复消息代码
        Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          if (v.userId == Global.user!.id) {
            return;
          }
          // if (v.replyId != Global.user!.id && v.replyId != '0') return;
          openCommentInput(widget.data.id!);
        },
        child: Container(
          color: myColors.grey0,
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                v.avatar!,
                width: 32,
                height: 32,
                imageSpecification: ImageSpecification.w120,
                borderRadius: BorderRadius.circular(32),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          v.nickname!,
                          style: TextStyle(
                            color: (v.userNumber != null &&
                                    v.userNumber!.isNotEmpty)
                                ? myColors.vipName
                                : myColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        // if (v.userNumber != null && v.userNumber!.isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.only(left: 5),
                        //     child: Image.asset(
                        //       assetPath('images/my/sp_liang.png'),
                        //       width: 12,
                        //       height: 12,
                        //       fit: BoxFit.contain,
                        //     ),
                        //   ),
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        children: [
                          if (v.replyNickname != null &&
                              v.replyNickname!.isNotEmpty)
                            TextSpan(text: '回复 '.tr()),
                          if (v.replyNickname != null &&
                              v.replyNickname!.isNotEmpty)
                            TextSpan(
                              text: '${v.replyNickname} : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: myColors.primary,
                              ),
                            ),
                          TextSpan(
                            text: v.content,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time2date(v.createTime),
                style: TextStyle(fontSize: 11, color: myColors.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    List<MessagePopType> pops = [
      MessagePopType.delete, //删除
    ];
    GUserTrendsCommentModel data = widget.data;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: myColors.grey0,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16),
              child: Icon(
                Icons.close_outlined,
                size: 20,
                color: myColors.grey3,
              ),
            ),
          ),
          commentContainer(data),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 8,
              color: myColors.lineGrey,
            ),
          ),
          if (commentList.isNotEmpty)
            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < commentList.length; i++)
                    commentList[i].userId == Global.user!.id ||
                            widget.data.userId == Global.user!.id
                        ? WPopupMenu(
                            onValueChanged: (j) {
                              deleteComment(pops[j], commentList[i].id!);
                            },
                            menuWidth: pops.length * 50,
                            actions: pops.map((e) => e.toChar).toList(),
                            child: commentContainer(commentList[i]),
                          )
                        : commentContainer(commentList[i]),
                ],
              ),
            )
        ],
      ),
    );
  }
}
