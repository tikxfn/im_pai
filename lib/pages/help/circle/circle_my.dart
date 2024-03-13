import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/help/circle/circle_apply_manage.dart';
import 'package:unionchat/pages/help/circle/circle_create.dart';
import 'package:unionchat/pages/help/circle/my/circle_my_apply.dart';
// import 'package:unionchat/pages/help/circle/my/circle_my_create.dart';
import 'package:unionchat/pages/help/circle/my/circle_my_join.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/pages/mall/mall_home.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/dialog_widget.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../../../notifier/theme_notifier.dart';

class CircleMy extends StatefulWidget {
  const CircleMy({super.key});

  static const String path = 'circle/my';

  @override
  State<StatefulWidget> createState() {
    return _CircleMyState();
  }
}

class _CircleMyState extends State<CircleMy>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int limit = 20;
  static List<GCircleModel> circleData1 = [];
  //初始加载后数据为空
  bool noList = false;

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircle(V1ListCircleArgs(
        isPublic: GSure.NO,
        circleType: V1ListCircleType.CREATE,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : circleData1.length.toString(),
        ),
      ));

      List<GCircleModel> newCirlceData = res?.list.toList() ?? [];
      logger.i(res);
      if (!mounted) return 0;
      if (init) {
        circleData1 = newCirlceData;
        if (circleData1.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleData1.addAll(newCirlceData);
      }
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //删除圈子
  delete(String circleId) async {
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleDelCircle(GIdArgs(id: circleId));
      if (mounted) getList(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('我的圈子'.tr()),
        actions: [
          GestureDetector(
            onTap: () {
              if (Global.loginUser!.userVipLevel == GVipLevel.n5 ||
                  Global.loginUser!.userVipLevel == GVipLevel.n6) {
                Navigator.pushNamed(context, CircleCreate.path).then((value) {
                  getList(init: true);
                });
              } else {
                showDialogWidget(
                  context: context,
                  child: shareWidget(context, '只有VIP5才能创建圈子'.tr()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.only(right: 10),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                assetPath('images/help/circle_create.png'),
                color: textColor,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // : Container(),
        ],
      ),
      body: ThemeBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: UnreadValue.circleApplyNotRead,
              builder: (context, value, _) {
                return ValueListenableBuilder(
                  valueListenable: UnreadValue.circleMyApplyNotRead,
                  builder: (context, circleMyApplyNotRead, _) {
                    return TabBar(
                      controller: _tabController,
                      indicatorColor: myColors.circleBlueButtonBg,
                      isScrollable: true,
                      indicatorWeight: 3.0,
                      labelColor: myColors.iconThemeColor,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelColor: myColors.textGrey,
                      unselectedLabelStyle: const TextStyle(fontSize: 16),
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      tabs: [
                        Badge(
                          offset: const Offset(9, 13),
                          largeSize: 8,
                          isLabelVisible: value.applicationJoinNotRead > 0,
                          backgroundColor: myColors.redTitle,
                          label: const Text(
                            '',
                          ),
                          child: Tab(
                            text: '我加入的'.tr(),
                          ),
                        ),

                        Badge(
                          offset: const Offset(9, 13),
                          largeSize: 8,
                          isLabelVisible: value.applicationCreateNotRead > 0,
                          backgroundColor: myColors.redTitle,
                          label: const Text(
                            '',
                          ),
                          child: Tab(
                            text: '我创建的'.tr(),
                          ),
                        ),

                        Badge(
                          offset: const Offset(9, 13),
                          largeSize: 8,
                          isLabelVisible: circleMyApplyNotRead > 0,
                          backgroundColor: myColors.redTitle,
                          label: const Text(
                            '',
                          ),
                          child: Tab(
                            text: '我申请的'.tr(),
                          ),
                        ),

                        // Tab(
                        //   child: badges.Badge(
                        //     showBadge: circleMyApplyNotRead > 0,
                        //     badgeContent: Text(
                        //       '',
                        //       style: TextStyle(
                        //         color: myColors.red,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //     child: Text(
                        //       '我申请的'.tr(),
                        //       style: TextStyle(
                        //         fontSize: _tabController.index == 2 ? 17 : 16,
                        //         color: _tabController.index == 2
                        //             ? textColor
                        //             : myColors.subIconThemeColor,
                        //         fontWeight: _tabController.index == 2
                        //             ? FontWeight.bold
                        //             : null,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                );
              },
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: [
                  const CircleMyJoin(),
                  circleMyCreate(),
                  const CircleMyApply(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget circleMyCreate() {
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
                if (circleData1.isEmpty && noList)
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
                if (circleData1.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: circleData1.map((e) {
                        String status = '';

                        Color statusColor = myColors.textGrey;
                        Color statusBgColor = myColors.white;
                        switch (e.status) {
                          case GApplyStatus.APPLY:
                            status = '申请中'.tr();
                            statusColor = myColors.im2Apply;
                            statusBgColor = myColors.im2ApplyBg;
                            break;
                          case GApplyStatus.REFUSE:
                            status = '已拒绝'.tr();
                            statusColor = myColors.im2Refuse;
                            statusBgColor = myColors.redButtonBg;
                            break;
                          case GApplyStatus.NIL:
                            status = '未知状态'.tr();
                            break;
                          case GApplyStatus.SUCCESS:
                            status = '';
                            break;
                          case GApplyStatus.BAN:
                            status = '已封禁'.tr();
                            statusColor = myColors.im2Refuse;
                            statusBgColor = myColors.redButtonBg;
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
                          onTap: e.status == GApplyStatus.SUCCESS
                              ? () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.pushNamed(context, GroupHome.path,
                                      arguments: {
                                        'circleId': e.id,
                                        'detail': e,
                                      }).then((value) {
                                    getList(init: true);
                                  });
                                }
                              : null,
                          avatarSize: 46,
                          titleSize: 16,
                          data: ChatItemData(
                            icons: [e.image ?? ''],
                            title: e.name ?? '',
                          ),
                          hasSlidable: false,
                          titleWidget: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                              ? (e.circleType == GCircleType.PRIVATE ||
                                      e.circleType == GCircleType.GUARANTEE)
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
                              : Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 5),
                                      decoration: BoxDecoration(
                                          color: statusBgColor,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                            color: statusColor, fontSize: 13),
                                      ),
                                    ),
                                    if (status == '申请中'.tr())
                                      CircleButton(
                                        onTap: () {
                                          confirm(
                                            context,
                                            content: '确认删除这条申请记录？'.tr(),
                                            onEnter: () {
                                              delete(e.id!);
                                            },
                                          );
                                        },
                                        theme: AppButtonTheme.primary,
                                        title: '取消申请'.tr(),
                                        fontSize: 14,
                                        width: 70,
                                        height: 30,
                                      )
                                  ],
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

  //弹窗组件
  Widget shareWidget(BuildContext context1, String content) {
    var myColors = ThemeNotifier();
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(assetPath('images/my/wallet_bg.png')),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      content,
                      style: TextStyle(
                        color: myColors.iconThemeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleButton(
                    onTap: () {
                      Navigator.pop(context1);
                      Navigator.pushNamed(context, MallHome.path);
                    },
                    width: 120,
                    height: 40,
                    title: '点击前往',
                    fontSize: 15,
                    theme: AppButtonTheme.primary,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 15,
              top: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context1);
                },
                child: Image.asset(
                  assetPath('images/btn_guanbi.png'),
                  color: myColors.subIconThemeColor,
                  height: 15,
                  width: 15,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
