import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/community/community_detail.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class CommunityTrendsList extends StatefulWidget {
  const CommunityTrendsList({super.key});

  static const String path = 'community/trends_list';

  @override
  State<StatefulWidget> createState() {
    return _CommunityTrendsListState();
  }
}

class _CommunityTrendsListState extends State<CommunityTrendsList> {
  //朋友圈动态数据
  static List<CommunityItemData> circleData = [];

  int limit = 20;
  int commentLimit = 20;

  //获取动态列表
  Future<int> getList({bool init = false}) async {
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsGetUnreadComment(
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
            userNumber: v.userInfo?.userNumber,
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
      } else {
        circleData.addAll(l);
      }
      UnreadValue.communityNotRead.value = 0;
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('新的消息'.tr()),
      ),
      body: ThemeBody(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // color: myColors.grey0,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: PagerBox(
                  showStateText: false,
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
                  children: [
                    for (var i = 0; i < circleData.length; i++)
                      if (circleData[i].comments != null)
                        for (var j in circleData[i].comments!)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, CommunityDetail.path,
                                  arguments: {
                                    'communityId': circleData[i].id
                                  }).then((value) {
                                getList(init: true);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: commentContainer(j)),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      alignment: Alignment.center,
                                      color: myColors.tagColor,
                                      child: circleData[i].photos != null &&
                                              circleData[i].photos!.isNotEmpty
                                          ? circleData[i].photosType !=
                                                  GArticleType.VIDEO
                                              ? AppNetworkImage(
                                                  circleData[i].photos?[0] ??
                                                      '',
                                                  width: 55,
                                                  height: 55,
                                                  imageSpecification:
                                                      ImageSpecification.w230,
                                                  fit: BoxFit.cover,
                                                )
                                              : Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    AppNetworkImage(
                                                      circleData[i]
                                                              .photos?[0] ??
                                                          '',
                                                      width: 55,
                                                      height: 55,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Positioned(
                                                      child: Image.asset(
                                                        assetPath(
                                                            'images/play2.png'),
                                                        width: 20,
                                                      ),
                                                    )
                                                  ],
                                                )
                                          : Text(
                                              circleData[i].text ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                    if (circleData.isEmpty)
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
            ],
          ),
        ),
      ),
    );
  }

  //单块评论区内容
  Widget commentContainer(GUserTrendsCommentModel v) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            list: [
              v.avatar ?? '',
            ],
            userName: v.nickname ?? '',
            userId: v.userId ?? '',
            size: 50,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.nickname!,
                        style: TextStyle(
                          color:
                              (v.userNumber != null && v.userNumber!.isNotEmpty)
                                  ? myColors.vipName
                                  : myColors.primary,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
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
                        text: v.content?.trim(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time2formatDate(v.createTime),
            style: TextStyle(fontSize: 11, color: myColors.textGrey),
          ),
        ],
      ),
    );
  }
}
