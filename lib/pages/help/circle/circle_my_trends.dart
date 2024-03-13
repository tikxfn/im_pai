import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/animation_fade_out.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleMyTrends extends StatefulWidget {
  const CircleMyTrends({super.key});

  static const String path = 'circle/my_trends';

  @override
  State<StatefulWidget> createState() {
    return _CircleMyTrendsState();
  }
}

class _CircleMyTrendsState extends State<CircleMyTrends> {
  List<CommunityItemData> circleData = [];
  String circleId = '0';
  int limit = 20;
  bool isMe = true; //我的
  bool isAll = false; //全部
  //初始加载后数据为空
  bool noList = false;

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircleArticle(
        V1ListCircleArticleArgs(
          isMe: isMe ? GSure.YES : GSure.NO,
          isAll: isAll ? GSure.YES : GSure.NO,
          areaCode: ['0'],
          circleId: [circleId],
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : circleData.length.toString(),
          ),
        ),
      );

      List<CommunityItemData> newCirlceData = [];
      for (var v in res?.list ?? []) {
        newCirlceData.add(
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
            targetId: v.circleId,
            target: v.circleName,
            areaName: v.areaName,
            userNumber: v.userInfo?.userNumber,
            numberType: v.userNumberType,
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
        circleData = newCirlceData;
        if (circleData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleData.addAll(newCirlceData);
      }
      setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //删除动态
  delete(String id) async {
    confirm(
      context,
      content: '是否删除此动态？'.tr(),
      onEnter: () async {
        final api = CircleApi(apiClient());
        loading();
        try {
          final res = await api.circleDelCircleArticle(GIdArgs(id: id));
          getList(init: true);
          if (res == null) return;
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
        title: Text('我的动态'.tr()),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: PagerBox(
                showStateText: circleData.isNotEmpty && !noList,
                onInit: () async {
                  // 初始化
                  if (!mounted) return 0;
                  dynamic args =
                      ModalRoute.of(context)!.settings.arguments ?? {};
                  if (args['circleId'] != null) circleId = args['circleId'];
                  if (args['isAll'] != null) isAll = args['isAll'];

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
                  if (circleData.isEmpty && noList)
                    AnimatedFadeOut(
                      child: Container(
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
                    ),
                  //动态
                  for (var i = 0; i < circleData.length; i++)
                    GestureDetector(
                      onTap: () {
                        // Navigator.pushNamed(context, HelpDetail.path,
                        //     arguments: {'trendsId': circleData[i].id});
                      },
                      child: CommunityItem(
                        id: circleData[i].id,
                        delete: () {
                          delete(circleData[i].id);
                        },
                        isMe: isMe,
                        data: circleData[i],
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
