import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/pop_route.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/community/community_create.dart';
import 'package:unionchat/pages/community/community_detail.dart';
import 'package:unionchat/pages/community/community_my.dart';
import 'package:unionchat/pages/community/community_trends_list.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/comment_input.dart';
import 'package:unionchat/widgets/community_box.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/user_name_tags.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';

class CommunityHome extends StatefulWidget {
  const CommunityHome({super.key});

  static const String path = 'community/home';

  @override
  State<StatefulWidget> createState() {
    return _CommunityHomeState();
  }
}

class _CommunityHomeState extends State<CommunityHome> {
  final ScrollController _controller = ScrollController();

  //朋友圈动态数据
  static List<CommunityItemData> circleData = [];

  int limit = 20;
  int commentLimit = 20;
  //初始加载后数据为空
  bool noList = false;
  //初始加载后数据为空
  bool needInit = true;
  // appbar 背景色
  Color? _appBarColor;

  //获取动态列表
  Future<int> getList({bool init = false}) async {
    final api = UserTrendsApi(apiClient());
    try {
      // circleData = [];
      final res = await api.userTrendsListUserTrends(
        V1ListUserTrendsArgs(
          types: V1UserTrendsTypes.PUBLIC,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : circleData.length.toString(),
          ),
          commentPager: GPagination(
            limit: commentLimit.toString(),
            offset: '0',
          ),
        ),
      );
      List<CommunityItemData> l = [];
      for (var v in res?.list ?? []) {
        l.add(
          CommunityItemData(
            userInfo: v.userInfo,
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
            comments: v.comments,
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
          ),
        );
      }
      if (!mounted) return 0;
      if (init) {
        circleData = l;
        if (circleData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
        if (needInit) needInit = false;
      } else {
        circleData.addAll(l);
      }
      UnreadValue.newTrendsNotRead.value = 0;
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
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
      for (var v in circleData) {
        if (v.id == id) {
          v.isLike = !v.isLike!;
          if (v.isLike == true) {
            v.like = [
              ...?v.like,
              GUserTrendsLikesModel(
                avatar: Global.user?.avatar,
                nickname: Global.user?.nickname,
                id: Global.user?.id,
                userId: Global.user?.id,
              ),
            ];
          }
          if (v.isLike == false) {
            List<GUserTrendsLikesModel> newLike = [];
            for (var a in v.like!) {
              if (a.nickname == Global.user?.nickname) continue;
              newLike.add(a);
            }
            v.like = [
              ...newLike,
            ];
          }
          setState(() {});
        }
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
    logger.i('str$str --------- id$id --------$commentId');
    logger.i(str);
    final api = UserTrendsApi(apiClient());
    try {
      await api.userTrendsAddUserTrendsComment(
        V1AddUserTrendsCommentArgs(
          id: id,
          content: str,
          commentId: commentId,
        ),
      );
      //当前页进行增加评论
      for (var v in circleData) {
        if (v.id == id) {
          var replyNickname = '';
          for (var a in v.comments!) {
            if (a.userId == commentId) {
              replyNickname = a.nickname ?? '';
              break;
            }
          }
          int now = DateTime.now().millisecondsSinceEpoch;
          String time = now.toString().substring(0, 10);
          v.comments = [
            ...?v.comments,
            GUserTrendsCommentModel(
              avatar: Global.user?.avatar,
              nickname: Global.user?.nickname,
              userId: Global.user?.id,
              userNumber: Global.user?.userNumber,
              replyId: commentId,
              replyNickname: replyNickname,
              content: str,
              createTime: time,
            ),
          ];
          v.commentsCount = (toInt(v.commentsCount) + 1).toString();
        }
      }
      // logger.i(res);
      if (mounted) setState(() {});
      limit = circleData.length;
      if (mounted) getList(init: true);
      limit = 20;
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

//长按评论   目前只有删除
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
          // circleData = [];
          //  v.commentsCount = (toInt(v.commentsCount) - 1).toString();
          getList(init: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {}
        break;
    }
  }

  //设置背景图片
  setTrendsBackground() async {
    ImagePicker picker = ImagePicker();
    AppStateNotifier().enablePinDialog = false;
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    AppStateNotifier().enablePinDialog = true;
    if (file == null) return;
    loading();
    final urls = await UploadFile(
      providers: [
        FileProvider.fromFilepath(file.path, V1FileUploadType.CIRCLE_IMAGE)
      ],
    ).aliOSSUpload();
    String backgroundImg = urls[0].toString();
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
          trendsBackground: V1SetBasicInfoArgsValue(value: backgroundImg)));
      await Global.syncLoginUser();
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
  }

  //删除动态
  delete(CommunityItemData data) async {
    confirm(
      context,
      content: '是否删除此动态？'.tr(),
      onEnter: () async {
        circleData.remove(data);
        setState(() {});
        logger.i(data);
        final api = UserTrendsApi(apiClient());
        try {
          final res = await api.userTrendsDelUserTrends(
            GIdArgs(id: data.id),
          );
          if (res == null) return;
          limit = circleData.length;
          getList(init: true);
          limit = 20;
        } on ApiException catch (e) {
          onError(e);
        } finally {}
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      // 滚动条超过 200 时，开始渐变
      if (_controller.position.pixels > 200 && _appBarColor == null) {
        setState(() {
          _appBarColor = ThemeNotifier().grey.withOpacity(1);
        });
      }
      if (_controller.position.pixels <= 200 && _appBarColor != null) {
        setState(() {
          _appBarColor = null;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF000000),
          systemNavigationBarDividerColor: null,
          statusBarColor: null,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: _appBarColor ?? Colors.transparent,
        title: _appBarColor == null
            ? const Text('')
            : Text(
                '朋友圈'.tr(),
                style: TextStyle(
                  color: myColors.textBlack,
                ),
              ),
        actions: [
          platformPhone
              ? GestureDetector(
                  onTap: () {
                    Adapter.navigatorTo(CommunityCreate.path).then(
                      (value) {
                        getList(init: true);
                      },
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      width: 22,
                      height: 20,
                      assetPath('images/friend_circle/sp_xianghji.png'),
                      color:
                          _appBarColor == null ? null : myColors.iconThemeColor,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Container(),
          const SizedBox(
            width: 24,
          ),
          GestureDetector(
            onTap: () {
              Adapter.navigatorTo(CommunityMy.path, arguments: {
                'userId': Global.user?.id,
                'trendsBackground': Global.user?.trendsBackground ?? '',
                'avatar': Global.user?.avatar ?? '',
                'name': (Global.user?.nickname ?? '').isNotEmpty
                    ? Global.user?.nickname ?? ''
                    : '未设置'.tr(),
                'userNumber': Global.user?.userNumber,
                'numberType':
                    Global.user?.userNumberType ?? GUserNumberType.NIL,
                'circleGuarantee':
                    toBool(Global.user?.userExtend?.circleGuarantee),
                'userVip': Global.loginUser!.userVip,
                'userVipLevel': Global.loginUser!.userVipLevel,
                'vipBadge': Global.user?.userExtend?.vipBadge ?? GBadge.NIL,
                'userOnlyName': Global.loginUser!.userOnlyName,
                'system': Global.user?.customerType == GCustomerType.SYSTEM,
                'customer': Global.user?.customerType == GCustomerType.MERCHANT,
              }).then(
                (value) {
                  getList(init: true);
                },
              );
            },
            child: Container(
              alignment: Alignment.center,
              width: 18,
              height: 22,
              child: Image.asset(
                width: 18,
                height: 22,
                assetPath('images/friend_circle/sp_wode_1.png'),
                color: _appBarColor == null ? null : myColors.iconThemeColor,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      body: CommunityBox(
        limit: limit,
        onInit: () async {
          return getList(init: true);
        },
        onPullDown: () async {
          return getList(init: true);
        },
        onPullUp: () async {
          return getList(init: true);
        },
        showInitLoadStatus: needInit,
        showStateText: !needInit && !noList,
        header: isCardContainer(),
        setTrendsBackground: setTrendsBackground,
        showImg: true,
        isMe: true,
        backgroundImg: Global.user?.trendsBackground,
        body: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: UnreadValue.communityNotRead,
              builder: (context, communityNotRead, _) {
                if (communityNotRead > 0) {
                  return Container(
                    height: 60,
                    color: bgColor,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: myColors.circleLocationTagBg,
                          borderRadius: BorderRadius.circular(10)),
                      child: GestureDetector(
                        onTap: () {
                          Adapter.navigatorTo(CommunityTrendsList.path);
                        },
                        child: Text(
                          '有$communityNotRead条新的评论',
                          style: TextStyle(
                            fontSize: 13,
                            color: myColors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),

            //圈子动态列表
            for (var i = 0; i < circleData.length; i++)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, CommunityDetail.path,
                      //         arguments: {'communityId': circleData[i].id})
                      //     .then((value) {
                      //   // circleData = [];
                      //   getList(init: true);
                      // });
                    },
                    child: CommunityItem(
                      isMe: circleData[i].userId == Global.user?.id,
                      id: circleData[i].id,
                      data: circleData[i],
                      isFriendCircle: true,
                      onLikeTap: likes,
                      onCommentTap: openCommentInput,
                      commentUser: openCommentInput,
                      onPopTap: deleteComment,
                      isFriendCircleDetail: true,
                      bottomBorder: false,
                      delete: () {
                        delete(circleData[i]);
                      },
                      // circleData[i].comments!.length < 10,
                    ),
                  ),
                  if (circleData[i].comments != null &&
                      circleData[i].commentsCount != null &&
                      circleData[i].commentsCount !=
                          circleData[i].comments!.length.toString())
                    GestureDetector(
                      onTap: () {
                        Adapter.navigatorTo(CommunityDetail.path,
                                arguments: {'communityId': circleData[i].id})
                            .then((value) {
                          // circleData = [];
                          getList(init: true);
                        });
                      },
                      child: Container(
                        height: 30,
                        color: bgColor,
                        alignment: Alignment.center,
                        child: Text(
                          '—————点击进入详情查看更多评论—————',
                          style: TextStyle(
                            color: myColors.textGrey,
                            // fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  if (circleData[i].commentsCount ==
                          circleData[i].comments?.length.toString() ||
                      circleData[i].commentsCount == null)
                    Container(
                      color: myColors.circleBorder,
                      height: 5,
                    ),
                ],
              ),
            //动态为空
            if (circleData.isEmpty && noList)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      assetPath('images/help/sp_zanwuneirong2.png'),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '暂无动态'.tr(),
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 15,
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

//头部内容
Widget isCardContainer() {
  var myColors = ThemeNotifier();
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          list: [
            Global.user?.avatar ?? '',
          ],
          userName: Global.user?.nickname ?? '',
          userId: Global.user?.id ?? '',
          size: 62,
          avatarFrameHeightSize: 30,
          avatarFrameWidthSize: 20,
          avatarTopPadding: 10,
          vip: Global.loginUser!.userVip,
          vipLevel: Global.loginUser!.userVipLevel,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserNameTags(
                userName: (Global.user?.nickname ?? '').isNotEmpty
                    ? Global.user?.nickname ?? ''
                    : '未设置'.tr(),
                color: myColors.white,
                select: false,
                needMarqueeText: false,
                vip: Global.loginUser!.userVip,
                vipLevel: Global.loginUser!.userVipLevel,
                vipBadge: Global.user?.userExtend?.vipBadge ?? GBadge.NIL,
                onlyName: Global.loginUser!.userOnlyName,
                goodNumber: Global.loginUser!.userGoodNumber &&
                    Global.user?.userExtend?.showName == GShowNameType.NUMBER,
                numberType: Global.user?.userNumberType ?? GUserNumberType.NIL,
                circleGuarantee:
                    toBool(Global.user?.userExtend?.circleGuarantee),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                system: Global.user?.customerType == GCustomerType.SYSTEM,
                customer: Global.user?.customerType == GCustomerType.MERCHANT,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
