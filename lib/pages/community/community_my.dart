import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/community/community_create.dart';
import 'package:unionchat/pages/community/community_detail.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/community_box.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/user_name_tags.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';

class CommunityMy extends StatefulWidget {
  const CommunityMy({super.key});

  static const String path = 'community/my';

  @override
  State<StatefulWidget> createState() {
    return _CommunityMyState();
  }
}

class _CommunityMyState extends State<CommunityMy> {
  final ScrollController _controller = ScrollController();
  //用户id
  String userId = '0';

  //是否是用户自己
  bool isMe = false;

  //朋友圈动态数据
  List<CommunityItemData> circleDataList = [];

  int limit = 20;

  // appbar 背景色
  Color? _appBarColor;

  //用户头像
  String avatar = '';

  //用户背景图
  String trendsBackground = '';

  //用户名
  String name = '';

  //靓号
  String? userNumber;

  //靓号类型
  GUserNumberType? numberType;

  //是否属于保圈
  bool circleGuarantee = false;

  //会员
  bool userVip = false;

  //会员等级
  GVipLevel userVipLevel = GVipLevel.NIL;

  //会员标志
  GBadge vipBadge = GBadge.NIL;

  //唯一名
  bool userOnlyName = false;

  //初始加载后数据为空
  bool noList = false;
  //系统
  bool system = false;
  bool customer = false;

  //获取详情
  getDetail() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userUserDetail(GIdArgs(id: userId));
      if (res == null) return;

      avatar = res.user?.avatar ?? '';
      name = res.user?.nickname ?? '';
      userNumber = res.user?.userExtend?.showName == GShowNameType.NUMBER
          ? res.user?.userNumber ?? ''
          : '';
      numberType = res.user?.userNumberType;
      circleGuarantee = toBool(res.user?.userExtend?.circleGuarantee);
      userVip =
          toInt(res.user?.userExtend?.vipExpireTime) >= toInt(date2time(null));
      userVipLevel = res.user?.userExtend?.vipLevel ?? GVipLevel.NIL;
      vipBadge = res.user?.userExtend?.vipBadge ?? GBadge.NIL;
      userOnlyName = toBool(res.user?.useChangeNicknameCard);
      trendsBackground = res.user?.trendsBackground ?? '';
      system = res.user?.customerType == GCustomerType.SYSTEM;
      customer = res.user?.customerType == GCustomerType.MERCHANT;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取动态列表
  Future<int> getList({bool init = false}) async {
    V1UserTrendsTypes types = V1UserTrendsTypes.USER;
    if (userId == '0' || userId == Global.user?.id) {
      types = V1UserTrendsTypes.ME;
      isMe = true;
    }
    final api = UserTrendsApi(apiClient());
    try {
      final res = await api.userTrendsListUserTrends(
        V1ListUserTrendsArgs(
          types: types,
          userId: userId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : circleDataList.length.toString(),
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
            // userNumber: v.userInfo!.userNumber,
            // userVip: toInt(v.userInfo!.userExtend!.vipExpireTime) >=
            //     toInt(date2time(null)),
            // userVipLevel: v.userInfo!.userExtend?.vipLevel ?? GVipLevel.NIL,
            // userOnlyName: toBool(v.userInfo!.useChangeNicknameCard),
          ),
        );
      }
      if (!mounted) return 0;
      if (init) {
        circleDataList = l;
        if (circleDataList.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleDataList.addAll(l);
      }

      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
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
        FileProvider.fromFilepath(file.path, V1FileUploadType.CHAT_FILE),
      ],
    ).aliOSSUpload();
    String backgroundImg = urls[0].toString();
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
          trendsBackground: V1SetBasicInfoArgsValue(value: backgroundImg)));
      await Global.syncLoginUser();
      await getDetail();
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
  }

  _init() async {
    await Future.wait(<Future>[
      getDetail(),
      getList(init: true),
    ]);
    if (mounted) setState(() {});
  }

  bool _firstIn = false;
  // 数据初始化
  _dataInit({bool build = false}) {
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
    if (build) {
      if (args['userId'] != null && !_firstIn) {
        _firstIn = true;
        userId = args['userId'];
        if (args['trendsBackground'] != null) {
          trendsBackground = args['trendsBackground'];
        }
        if (args['avatar'] != null) {
          avatar = args['avatar'];
        }
        if (args['name'] != null) {
          name = args['name'];
        }
        if (args['userNumber'] != null) {
          userNumber = args['userNumber'];
        }
        if (args['numberType'] != null) {
          numberType = args['numberType'];
        }
        if (args['circleGuarantee'] != null) {
          circleGuarantee = args['circleGuarantee'];
        }
        if (args['userVip'] != null) {
          userVip = args['userVip'];
        }
        if (args['userVipLevel'] != null) {
          userVipLevel = args['userVipLevel'];
        }
        if (args['vipBadge'] != null) {
          vipBadge = args['vipBadge'];
        }
        if (args['userOnlyName'] != null) {
          userOnlyName = args['userOnlyName'];
        }
        if (args['system'] != null) {
          system = args['system'];
        }
        if (args['customer'] != null) {
          customer = args['customer'];
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
      if (_controller.position.pixels > 200) {
        // 透明度系数
        double opacity = (_controller.position.pixels - 200) / 100;
        if (opacity < 0.9) {
          setState(() {
            _appBarColor = ThemeNotifier().grey.withOpacity(opacity);
          });
        }
      } else {
        setState(() {
          _appBarColor = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;

    Color textColor = myColors.iconThemeColor;
    Color tagColor = myColors.tagColor;
    _dataInit(build: true);
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
        actions: [
          isMe && platformPhone
              ? GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, CommunityCreate.path).then(
                      (value) {
                        getList(init: true);
                      },
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 22,
                    height: 22,
                    child: Image.asset(
                      assetPath('images/friend_circle/sp_xianghji.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Container(),
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
        header: isCardContainer(avatar, name, userId, userNumber, numberType,
            circleGuarantee, userVip, userVipLevel, vipBadge, userOnlyName),
        setTrendsBackground: setTrendsBackground,
        showImg: true,
        isMe: isMe,
        backgroundImg: trendsBackground,
        body: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            //圈子动态列表
            for (var i = 0; i < circleDataList.length; i++)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, CommunityDetail.path,
                          arguments: {'communityId': circleDataList[i].id})
                      .then((value) {
                    getList(init: true);
                  });
                },
                child: Container(
                  color: bgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          time2formatDate(circleDataList[i].date),
                          style: TextStyle(
                            color: myColors.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      if (circleDataList[i].photos == null ||
                          circleDataList[i].photos!.isEmpty)
                        Container(
                          alignment: Alignment.center,
                          width: 84,
                          height: 84,
                          color: tagColor,
                          child: Image.asset(
                            assetPath('images/friend_circle/sp_xianghji.png'),
                            color: myColors.iconThemeColor,
                            width: 25,
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      if (circleDataList[i].photos != null &&
                          circleDataList[i].photos!.isNotEmpty)
                        photoWidget(circleDataList[i]),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              // width: 200,
                              child: Text(
                                circleDataList[i].text ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '共张'.tr(args: [
                                circleDataList[i].photos != null
                                    ? circleDataList[i]
                                        .photos!
                                        .length
                                        .toString()
                                    : ''
                              ]),
                              style: TextStyle(
                                color: myColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            if (circleDataList.isEmpty && noList)
              Container(
                width: 424,
                height: 581,
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

  //头部内容
  Widget isCardContainer(
    String? avatar,
    String? name,
    String userId,
    String? userNumber,
    GUserNumberType? numberType,
    bool circleGuarantee,
    bool userVip,
    GVipLevel userVipLevel,
    GBadge vipBadge,
    bool userOnlyName,
  ) {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            list: [
              avatar ?? '',
            ],
            userName: name ?? '',
            userId: userId,
            size: 62,
            avatarFrameHeightSize: 30,
            avatarFrameWidthSize: 20,
            avatarTopPadding: 10,
            vip: userVip,
            vipLevel: userVipLevel,
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
                  userName: name ?? '',
                  color: myColors.white,
                  select: false,
                  needMarqueeText: false,
                  vip: userVip,
                  vipLevel: userVipLevel,
                  vipBadge: vipBadge,
                  onlyName: userOnlyName,
                  goodNumber: userNumber != null && userNumber.isNotEmpty,
                  numberType: numberType ?? GUserNumberType.NIL,
                  system: system,
                  customer: customer,
                  circleGuarantee: circleGuarantee,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//图片组件
Widget photoWidget(CommunityItemData data) {
  String url = data.photos![0];
  if (data.photosType == GArticleType.VIDEO) {
    url = getVideoCover(data.photos![0]);
  }
  return data.photosType == GArticleType.IMAGE
      ? AppNetworkImage(
          url,
          width: 84,
          height: 84,
          imageSpecification: ImageSpecification.w230,
          fit: BoxFit.cover,
        )
      : Stack(
          alignment: Alignment.center,
          children: [
            AppNetworkImage(
              url,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
            Positioned(
              child: Image.asset(
                assetPath('images/play2.png'),
                width: 40,
              ),
            )
          ],
        );
}
