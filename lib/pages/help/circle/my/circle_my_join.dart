import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/help/circle/circle_apply_manage.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../../notifier/theme_notifier.dart';

class CircleMyJoin extends StatefulWidget {
  const CircleMyJoin({super.key});

  static const String path = 'circle/my_join';

  @override
  State<StatefulWidget> createState() {
    return _CircleMyJoinState();
  }
}

class _CircleMyJoinState extends State<CircleMyJoin> {
  int limit = 20;
  static List<GCircleModel> circleData = [];
  //初始加载后数据为空
  bool noList = false;

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircle(V1ListCircleArgs(
        isPublic: GSure.NO,
        circleType: V1ListCircleType.JOIN,
        name: '',
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : circleData.length.toString(),
        ),
      ));

      List<GCircleModel> newCirlceData = res?.list.toList() ?? [];
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

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      body: Column(
        children: [
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
              children: [
                if (circleData.isEmpty && noList)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
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
                          '暂无加入圈子'.tr(),
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (circleData.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: circleData.map((e) {
                        String status = '';

                        switch (e.status) {
                          case GApplyStatus.APPLY:
                            status = '';
                            break;
                          case GApplyStatus.REFUSE:
                            status = '';
                            break;
                          case GApplyStatus.NIL:
                            status = '';
                            break;
                          case GApplyStatus.SUCCESS:
                            status = '';
                            break;
                          case GApplyStatus.BAN:
                            status = '已封禁'.tr();
                            break;
                        }
                        String circlyType = '公开'.tr();
                        switch (e.circleType) {
                          case GCircleType.GUARANTEE:
                            circlyType = '保圈'.tr();
                            break;
                          case GCircleType.NIL:
                            break;
                          case GCircleType.PRIVATE:
                            circlyType = '私有'.tr();
                            break;
                          case GCircleType.PUBLIC:
                            break;
                        }

                        return ChatItem(
                          onTap: () {
                            logger.i(e);
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pushNamed(context, GroupHome.path,
                                arguments: {
                                  'circleId': e.id,
                                  'detail': e,
                                }).then((value) {
                              getList(init: true);
                            });
                          },
                          avatarSize: 46,
                          titleSize: 16,
                          data: ChatItemData(
                            icons: [e.image ?? ''],
                            title: e.name ?? '',
                          ),
                          hasSlidable: false,
                          titleWidget: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  e.name ?? '',
                                  style: const TextStyle(
                                    height: 1,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (e.circleType != GCircleType.PUBLIC)
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: myColors.circlyTypePrivateBg,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    circlyType,
                                    style: TextStyle(
                                      height: 1,
                                      color: myColors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          end: status == ''
                              ? e.circleType == GCircleType.PRIVATE &&
                                      e.role == GRole.ADMIN
                                  ? toInt(e.applyCount) > 0
                                      ? badges.Badge(
                                          position: badges.BadgePosition.topEnd(
                                              end: 0),
                                          showBadge: toInt(e.unreadCount) > 0,
                                          badgeContent: Text(
                                            '',
                                            style: TextStyle(
                                              color: myColors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                          child: CircleButton(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  CircleApplyManage.path,
                                                  arguments: {
                                                    'circleId': e.id
                                                  }).then((value) {
                                                getList(init: true);
                                              });
                                            },
                                            theme: AppButtonTheme.blue,
                                            title: '申请验证'.tr(),
                                            width: 70,
                                            height: 30,
                                          ),
                                        )
                                      : null
                                  : null
                              : Text(
                                  status,
                                  style: TextStyle(
                                    color: myColors.textGrey,
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
