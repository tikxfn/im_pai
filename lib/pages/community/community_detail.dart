import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/pop_route.dart';
import 'package:unionchat/widgets/comment_input.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/up_loading.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class CommunityDetail extends StatefulWidget {
  const CommunityDetail({super.key});

  static const String path = 'community/detail';

  @override
  State<StatefulWidget> createState() {
    return _CommunityDetailState();
  }
}

class _CommunityDetailState extends State<CommunityDetail> {
  final ScrollController _controller = ScrollController();
  LoadStatus _loadStatus = LoadStatus.nil; //数据加载状态
  int limit = 50;

  //动态id
  String communityId = '0';

  //是否是用户自己
  bool isMe = false;

  //朋友圈动态数据
  CommunityItemData circleData = CommunityItemData(
    userInfo: GUserModel(),
    id: '',
    avatar: '',
    userId: '',
    nickName: '',
    isLike: false,
    like: [],
    comments: [],
  );

  //评论数据
  List<GUserTrendsCommentModel> communityData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args == null) return;
      if (args['communityId'] != null) communityId = args['communityId'];
      if (communityId.isNotEmpty) {
        getList();
      }
    });
    _controller.addListener(() {
      double scroll = _controller.position.pixels;
      double maxScroll = _controller.position.maxScrollExtent;
      //当滚动到最底部的时候，加载新的数据
      if (scroll == maxScroll && _loadStatus == LoadStatus.more) {
        communityList();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //获取详情动态
  getList() async {
    final api = UserTrendsApi(apiClient());
    try {
      // circleData = CommunityItemData(
      //   id: '',
      //   avatar: '',
      //   userId: '',
      //   nickName: '',
      // );
      final res = await api.userTrendsDetailUserTrends(
        GIdArgs(id: communityId),
      );
      if (res == null) return;
      GUserTrendsModel v = res;
      if (v.userId == Global.user?.id) isMe = true;
      circleData = CommunityItemData(
        userInfo: v.userInfo ?? GUserModel(),
        id: v.id ?? '',
        userId: v.userId ?? '',
        avatar: v.userInfo?.avatar ?? '',
        nickName: v.userInfo?.nickname ?? '',
        text: v.content,
        photos: v.images,
        photosType: v.articleType,
        date: v.createTime ?? '',
        isLike: toBool(v.isLikes),
        like: v.likes,
        comments: [],
        commentsCount: v.commentsCount,
        userNumber: v.userInfo?.userExtend?.showName == GShowNameType.NUMBER
            ? v.userInfo?.userNumber
            : '',
        numberType: v.userInfo?.userNumberType,
        circleGuarantee: toBool(v.userInfo?.userExtend?.circleGuarantee),
        userVip: toInt(v.userInfo?.userExtend?.vipExpireTime) >=
            toInt(date2time(null)),
        userVipLevel: v.userInfo?.userExtend?.vipLevel ?? GVipLevel.NIL,
        vipBadge: v.userInfo?.userExtend?.vipBadge ?? GBadge.NIL,
        userOnlyName: toBool(v.userInfo?.useChangeNicknameCard),
      );
      await communityList(init: true);
      if (!mounted) return;
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取评论列表
  communityList({bool init = false, String replyId = '0'}) async {
    if (_loadStatus == LoadStatus.loading) return;
    setState(() {
      _loadStatus = LoadStatus.loading;
    });
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsListUserTrendsComment(
        V1ListUserTrendsCommentArgs(
          id: communityId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : circleData.comments?.length.toString(),
          ),
          replyId: replyId,
        ),
      );
      if (!mounted) return;
      List<GUserTrendsCommentModel> l = [];
      l.addAll(res?.list.toList() ?? []);
      if (init) {
        circleData.comments = l;
      } else {
        circleData.comments?.addAll(l);
      }
      setState(() {
        _loadStatus =
            (res?.list ?? []).length >= limit ? LoadStatus.more : LoadStatus.no;
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //点赞
  likes(String id) async {
    // logger.i(id);
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsLikesUserTrends(
        GIdArgs(
          id: id,
        ),
      );
      if (mounted) {
        circleData.isLike = !circleData.isLike!;
        if (circleData.isLike == true) {
          circleData.like = [
            ...?circleData.like,
            GUserTrendsLikesModel(
              avatar: Global.user?.avatar,
              nickname: Global.user?.nickname,
              id: Global.user?.id,
              userId: Global.user?.id,
            ),
          ];
        }
        if (circleData.isLike == false) {
          List<GUserTrendsLikesModel> newLike = [];
          if (circleData.like != null) {
            for (var a in circleData.like!) {
              if (a.nickname == Global.user!.nickname) continue;
              newLike.add(a);
            }
          }
          circleData.like = [
            ...newLike,
          ];
        }
        setState(() {});
      }
      if (res == null) return;
      logger.i(res);
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //展开评论输入框
  openCommentInput(String id, String? commentId) {
    Navigator.push(
      context,
      PopRoute(
        child: CommentInput(
          onSend: sendComment,
          id: id,
          commentId: commentId ?? '0',
        ),
      ),
    );
  }

  //发送评论
  sendComment(String str, String id, String? commentId) async {
    logger.i('动态id: $id 评论内容: $str 对方id:${commentId!}');
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsAddUserTrendsComment(
        V1AddUserTrendsCommentArgs(
          id: id,
          content: str,
          commentId: commentId,
        ),
      );
      // getList();

      // var replyNickname = '';
      // for (var a in circleData.comments!) {
      //   if (a.userId == commentId) {
      //     replyNickname = a.nickname!;
      //     break;
      //   }
      // }
      // int now = DateTime.now().millisecondsSinceEpoch;
      // String time = now.toString().substring(0, 10);
      // circleData.comments = [
      //   GUserTrendsCommentModel(
      //     avatar: Global.user!.avatar,
      //     nickname: Global.user!.nickname,
      //     userId: Global.user!.id,
      //     userNumber: Global.user!.userNumber,
      //     replyId: commentId,
      //     replyNickname: replyNickname,
      //     content: str,
      //     createTime: time,
      //   ),
      //   ...?circleData.comments,
      // ];
      // //评论数
      // circleData.commentsCount =
      //     (toInt(circleData.commentsCount) + 1).toString();
      limit = circleData.comments!.length;
      // await getList();
      if (mounted) communityList(init: true);
      limit = 50;
      if (res == null) return;
      logger.i(res);
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
          circleData.commentsCount =
              (toInt(circleData.commentsCount) - 1).toString();
          communityList(init: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {}
        break;
    }
  }

  //删除动态
  delete(String id) async {
    confirm(
      context,
      content: '是否删除此动态？'.tr(),
      onEnter: () async {
        final api = UserTrendsApi(apiClient());
        loading();
        try {
          final res = await api.userTrendsDelUserTrends(
            GIdArgs(id: id),
          );
          if (mounted) Navigator.pop(context);
          if (res == null) return;
          logger.i(res);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('动态详情'.tr()),
      ),
      body: ThemeBody(
        topPadding: 0,
        child: RefreshIndicator(
          onRefresh: () async {
            await getList();
          },
          child: ListView(
            controller: _controller,
            children: [
              //圈子动态列表
              CommunityItem(
                isMe: isMe,
                id: circleData.id,
                data: circleData,
                isFriendCircle: true,
                onLikeTap: likes,
                onCommentTap: openCommentInput,
                commentUser: openCommentInput,
                onPopTap: deleteComment,
                bottomBorder: false,
                isFriendCircleDetail: true,
                delete: () {
                  delete(circleData.id);
                },
              ),
              if (_loadStatus == LoadStatus.more)
                GestureDetector(
                  onTap: () {
                    communityList();
                  },
                  child: Container(
                    height: 20,
                    color: myColors.white,
                    alignment: Alignment.center,
                    child: Text(
                      '————————点击展开查看更多————————'.tr(),
                      style: TextStyle(
                        color: myColors.textGrey,
                        // fontSize: 15,
                      ),
                    ),
                  ),
                ),
              //显示分页信息
              if (_loadStatus == LoadStatus.no)
                SafeArea(
                  top: false,
                  child: UpLoading(_loadStatus),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentData {
  GUserTrendsCommentModel? data;
  List<GUserTrendsCommentModel>? list;

  CommentData({
    required this.data,
    this.list,
  });
}
