import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/application/city_list.dart';
import 'package:unionchat/pages/help/circle/circle_manage.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/animation_fade_out.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/community_box.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/popup_button.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';
import '../circle/circle_my_trends.dart';
import '../help_create.dart';

class GroupHome extends StatefulWidget {
  const GroupHome({super.key});

  static const String path = 'group/home';

  @override
  State<StatefulWidget> createState() {
    return _GroupHomeState();
  }
}

class _GroupHomeState extends State<GroupHome> {
  final ScrollController _controller = ScrollController();
  int limit = 20;

  //圈子id
  String circleId = '';

  //当前城市名
  String city = '选择城市'.tr();

  //圈子详情
  GCircleModel? detail;

  //圈子列表
  List<CommunityItemData> circleData = [];

  //是否加入
  bool isJoin = false;

  //是否圈主
  bool isMaster = false;

  //是否公开
  bool isOpen = false;

  //是否有管理员权限
  bool hasPoWer = false;

  // appbar 背景色
  Color? _appBarColor;

  //圈子邀请需要邀请人的个数
  String needInviteNum = '0';

  //多选列城市id
  List<String> areaCodeList = [];

  //多选列城市名字
  List<String> areaNameList = [];
  List<GAreaModel> areaData = [];

  //初始加载后数据为空
  bool noList = false;

  //获取详情
  getDetail({bool errTip = true}) async {
    // logger.i(errTip);
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      detail = res;
      logger.i(res);
      isMaster = res.userId == (Global.user?.id ?? '');
      isOpen = detail?.circleType == GCircleType.PUBLIC;
      isJoin = toBool(res.isJoin);
      needInviteNum = res.inviteUser ?? '0';
      // logger.i(res.isJoin);
      if (res.role == GRole.ADMIN || res.role == GRole.LEADER) hasPoWer = true;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e, errTip: errTip);
    } finally {}
  }

  //获取用户筛选
  getCitySet() async {
    try {
      final api = CircleApi(apiClient());
      final res = await api.circleGetCircleMemberSet(
        V1GetCircleMemberSetArgs(circleId: circleId),
      );
      if (res == null || !mounted) return;
      areaData = [];
      List<String> newAreaCodeList = [];
      List<String> newAreaNameList = [];
      if (res.area.isNotEmpty) {
        areaData = res.area;
        for (var v in res.area) {
          newAreaCodeList.add(v.cityCode ?? '');
          newAreaNameList.add(v.cityName ?? '');
        }
      }
      areaCodeList = newAreaCodeList;
      areaNameList = newAreaNameList;
      setState(() {});
      if (mounted) await getList(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircleArticle(
        V1ListCircleArticleArgs(
          areaCode: areaCodeList,
          circleId: [circleId],
          isMe: GSure.NO,
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
        circleData = newCirlceData;
        if (circleData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleData.addAll(newCirlceData);
      }

      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    }
  }

  //加入圈子
  join() async {
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleJoinCircle(V1JoinCircleArgs(
        id: circleId,
        inviterUserId: '0',
      ));
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

//退出圈子
  exit() async {
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleExitCircle(GIdArgs(
        id: circleId,
      ));
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

//发送邀请
  invite() {
    if (toInt(needInviteNum) > 0) tip('当前圈子设置了邀请人数条件，所以只能向单个好友发送邀请');
    String content =
        '[邀请信息]收到的入群邀请，加入我们吧'.tr(args: [Global.user!.nickname ?? '']);
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) {
          var msg = Message()
            ..senderUser = getSenderUser()
            ..type = GMessageType.FORWARD_CIRCLE
            ..contentId = toInt(circleId)
            ..content = detail?.name
            ..fileUrl = detail?.image
            ..location = (Global.user?.id ?? '').isNotEmpty
                ? Global.user!.id!
                : ''; //分享人id
          return ShareHome(
            shareText: content,
            list: [msg],
            isCircleShare: toInt(needInviteNum) > 0,
          );
        },
      ),
    );
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

  //标签组件
  Widget groupTarget(String text, {Color? color}) {
    color = color ?? ThemeNotifier().textBlack;
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: .5,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  _init() async {
    await Future.wait(<Future>[
      getDetail(),
      getCitySet(),
    ]);
    if (mounted) setState(() {});
  }

  bool _firstIn = false;
  // 数据初始化
  _dataInit({bool build = false}) {
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
    if (build) {
      if (args['circleId'] != null) circleId = args['circleId'];
      if (args['detail'] != null && !_firstIn) {
        _firstIn = true;
        detail = args['detail'];
        isOpen = detail?.circleType == GCircleType.PUBLIC;
        isJoin = detail?.isJoin == GSure.YES;
        if (detail?.role == GRole.ADMIN || detail?.role == GRole.LEADER) {
          hasPoWer = true;
        }
      }
    } else {
      _init();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _dataInit());
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
    Color popupColors = myColors.popupThemeColor;
    _dataInit(build: true);
    return Scaffold(
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
        title: _appBarColor == null ? const Text('') : Text('圈子详情'.tr()),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            width: 12,
            height: 18,
            assetPath('images/friend_circle/back.png'),
            color: _appBarColor == null ? null : myColors.iconThemeColor,
            fit: BoxFit.contain,
          ),
        ),
        actions: !isJoin
            ? null
            : [
                PopupMenuButton<int>(
                  color: popupColors,
                  onSelected: (i) {
                    if (i == 0) {
                      invite();
                    }
                    if (i == 1) {
                      Navigator.pushNamed(context, CircleManage.path,
                          arguments: {
                            'circleId': circleId,
                          }).then((value) {
                        logger.i('详情');
                        getDetail(errTip: false);
                        logger.i('动态');
                        getList(init: true);
                        logger.i('退出');
                      });
                    }
                    if (i == 2) {
                      Navigator.pushNamed(context, CircleMyTrends.path,
                          arguments: {'circleId': circleId}).then((value) {
                        getList(init: true);
                      });
                    }
                    if (i == 3) {
                      confirm(
                        context,
                        content: '是否退出此圈子？'.tr(),
                        onEnter: exit,
                      );
                    }
                  },
                  // position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.more_horiz,
                      color: myColors.white,
                    ),
                  ),
                  itemBuilder: (context1) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: PopuButtonBox(
                          title: '分享圈子'.tr(),
                          icons: assetPath('images/help/fenxiangquanzi.png'),
                        ),
                      ),
                      if (hasPoWer)
                        PopupMenuItem(
                          value: 1,
                          child: PopuButtonBox(
                            title: '权限管理'.tr(),
                            icons:
                                assetPath('images/help/sp_quanxianguanli.png'),
                          ),
                        ),
                      if (isJoin)
                        PopupMenuItem(
                          value: 2,
                          child: PopuButtonBox(
                            title: '我的动态'.tr(),
                            icons: assetPath('images/help/wodefabu.png'),
                          ),
                        ),
                      if (isJoin && !isMaster)
                        PopupMenuItem(
                          value: 3,
                          child: PopuButtonBox(
                            title: '退出圈子'.tr(),
                            icons: assetPath('images/help/sp_tuichu.png'),
                          ),
                        ),
                    ];
                  },
                ),
              ],
      ),
      floatingActionButton: isJoin && platformPhone
          ? AnimatedFadeOut(
              animatedTime: 500,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, HelpCreate.path,
                      arguments: {'circleId': circleId}).then((value) {
                    getList(init: true);
                  });
                },
                child: Image.asset(
                  assetPath('images/help/btn_tianjia.png'),
                  width: 53,
                  height: 53,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : null,
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
        header: isCardContainer(),
        body: Column(
          children: [
            if (circleData.isNotEmpty)
              for (var i = 0; i < circleData.length; i++)
                CommunityItem(
                  id: circleData[i].id,
                  data: circleData[i],
                  isCircle: true,
                  isMe: hasPoWer,
                  delete: () {
                    delete(circleData[i].id);
                  },
                ),
            if (circleData.isEmpty && noList)
              AnimatedFadeOut(
                animatedTime: 500,
                child: Container(
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
          ],
        ),
      ),
    );
  }

  //头部内容
  Widget isCardContainer() {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(maxHeight: platformPhone ? 200 : 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AppAvatar(
                    list: [
                      detail?.image ?? '',
                    ],
                    userName: detail?.name ?? '',
                    userId: circleId,
                    size: 62,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (hasPoWer)
                    Text(
                      '圈人数:'.tr(args: [detail?.countUser ?? '']),
                      style: TextStyle(
                        color: myColors.white,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail?.name ?? '',
                      style: TextStyle(
                        color: myColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '简介:'.tr(args: [detail?.describe ?? '']),
                      maxLines: 3,
                      style: TextStyle(
                        color: myColors.subIconThemeColor,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    !isOpen && isJoin
                        ? GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                CityList.path,
                                arguments: {
                                  'areaData': areaData,
                                  'circleId': circleId,
                                },
                              ).then((value) {
                                getCitySet();
                                // getList(init: true);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                color: myColors.circleLocationTagBg,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                areaNameList.join(',') == ''
                                    ? city
                                    : areaNameList.join(','),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: myColors.white,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              if (!isJoin)
                CircleButton(
                  theme: AppButtonTheme.blue,
                  onTap: () {
                    confirm(
                      context,
                      content: '是否加入此圈子？'.tr(),
                      onEnter: join,
                    );
                  },
                  title: '加入'.tr(),
                  width: 44,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
