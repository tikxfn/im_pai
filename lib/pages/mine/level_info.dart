import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../global.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/avatar.dart';
import '../../widgets/user_name_tags.dart';

class LevelInfo extends StatefulWidget {
  const LevelInfo({super.key});

  static const String path = 'mine/level/info';

  @override
  State<LevelInfo> createState() => _LevelInfoState();
}

class _LevelInfoState extends State<LevelInfo> {
  static List<GSystemSettingVipLevelModel> _levelList = [];
  double _unit = 1;
  int _todayExp = 0;
  int _experience = 0;
  int _upExperience = 0;

  _init() async {
    List<Future> futures = [
      _getLevelInfo(),
      _getUserExp(),
    ];
    await Global.syncLoginUser();
    await Future.wait(futures);
    if (mounted) setState(() {});
  }

  //获取用户经验
  _getUserExp() async {
    var api = UserApi(apiClient());
    try {
      var res = await api.userUserExperience({});
      if (res == null) return;
      _unit = toDouble(res.magnification);
      _todayExp = toInt(res.todayExperience);
      _experience = toInt(res.experience);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //获取等级说明
  _getLevelInfo() async {
    try {
      await Global.getSystemInfo();
      var list = Global.systemInfo.settingVipLevel?.settingVipLevel ?? [];
      for (var i = 0; i < list.length; i++) {
        if (Global.user?.userExtend?.vipLevel == list[i].level) {
          if (i + 1 < list.length) {
            _upExperience = toInt(list[i + 1].growthValue);
          } else {
            _upExperience = toInt(list[i].growthValue);
          }
        }
      }
      _levelList = list.toList();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //预览图片
  goImage(url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: [url],
          index: 0,
          showSave: false,
          isImages: true,
        ),
      ),
    );
  }

  // //圆形经验列表组件
  // Widget _jyWidget({
  //   required String title,
  //   required double rate,
  //   required String text,
  //   required String unit,
  // }) {
  //   double size = 70;
  //   return Column(
  //     children: [
  //       Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           SizedBox(
  //             width: size,
  //             height: size,
  //             child: CircularProgressIndicator(
  //               strokeWidth: 8,
  //               value: rate,
  //               backgroundColor: myColors.blueOpacity,
  //             ),
  //           ),
  //           Column(
  //             children: [
  //               Text(text),
  //               Text(
  //                 unit,
  //                 style: const TextStyle(
  //                   fontSize: 9,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 10),
  //       Text(
  //         title,
  //         style: const TextStyle(
  //           fontSize: 12,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  //经验列表组件
  Widget _jyWidget2({
    required String title,
    required double rate,
    required String text,
    required String unit,
    required String image,
  }) {
    var myColors = ThemeNotifier();
    Color textColor = myColors.iconThemeColor;
    Color tagColor = myColors.tagColor;
    if (rate >= 1) rate = 1;
    double size = 60;
    double iconSize = 30;
    double pillarHeight = size * rate;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tagColor,
        boxShadow: [
          BoxShadow(
            color: myColors.readBg,
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                assetPath(image),
                height: iconSize,
                width: iconSize,
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 20,
                    height: size,
                    color: myColors.grey,
                  ),
                  Container(
                    width: 20,
                    height: pillarHeight,
                    color: myColors.vipBuyExp,
                  )
                  // SizedBox(
                  //   width: size,
                  //   height: size,
                  //   child: CircularProgressIndicator(
                  //     color: myColors.white,
                  //     strokeWidth: 8,
                  //     value: rate,
                  //     backgroundColor: myColors.red,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      //   fontSize: 9,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //柱状图组件
  Widget _pillarItem({
    required String title,
    required String image,
    required int exp,
    Color? color,
    double multiple = 1,
  }) {
    double iconSize = 30;
    double pillarMinHeight = iconSize + 10;
    double pillarHeight = pillarMinHeight * multiple;
    var myColors = ThemeNotifier();
    // logger.d(pillarHeight);
    return Container(
      // height: height,
      width: 45,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              exp.toString(),
              style: TextStyle(
                fontSize: 11,
                color: myColors.primary,
              ),
            ),
          ),
          Container(
            width: 30,
            height: pillarHeight,
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: color ?? myColors.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: myColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // //表格cell
  // TableCell _tableCell({
  //   required String text,
  // }) {
  //   var myColors = ThemeNotifier();

  //   Color textColor = myColors.iconThemeColor;
  //   return TableCell(
  //     verticalAlignment: TableCellVerticalAlignment.middle,
  //     child: Container(
  //       alignment: Alignment.center,
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       child: Text(
  //         text,
  //         style: TextStyle(
  //           color: textColor,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    double avatarFrameWidthSize = 24;
    double avatarFrameHeightSize = 30;
    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;
    String userName = (Global.user?.nickname ?? '').isNotEmpty
        ? Global.user!.nickname!
        : '未设置'.tr();
    String expireTime = time2date(
      Global.user?.userExtend?.vipExpireTime,
      format: 'yyyy-MM-dd',
    );
    logger.i(
        ' vip: ${Global.loginUser!.userVip},vipLevel: ${Global.loginUser!.userVipLevel},');
    return Scaffold(
      appBar: AppBar(
        title: Text('等级信息'.tr()),
      ),
      body: ThemeBody(
        topPadding: 0,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            // 个人信息
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(
                // vertical: 10,
                horizontal: 15,
              ),
              alignment: Alignment.center,
              constraints: const BoxConstraints(minHeight: 145),
              decoration: BoxDecoration(
                color: bgColor,
                image: DecorationImage(
                  image: ExactAssetImage(
                      assetPath('images/vip/sp_huiyuanbg2.png')),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      //用户头像
                      Container(
                        alignment: Alignment.center,
                        width: 60 + avatarFrameWidthSize + 16,
                        height: 60 + avatarFrameWidthSize + 10,
                        margin: const EdgeInsets.only(right: 2),
                        child: AppAvatar(
                          list: [Global.user?.avatar ?? ''],
                          userName: Global.user?.nickname ?? '',
                          userId: Global.user?.id ?? '',
                          size: 60,
                          avatarFrameHeightSize: avatarFrameHeightSize,
                          avatarFrameWidthSize: avatarFrameWidthSize,
                          avatarTopPadding: 10,
                          vip: Global.loginUser!.userVip,
                          vipLevel: Global.loginUser!.userVipLevel,
                        ),
                      ),

                      //昵称、靓号、vip
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserNameTags(
                              userName: userName,
                              color: !Global.loginUser!.userVip
                                  ? myColors.white
                                  : null,
                              vip: Global.loginUser!.userVip,
                              vipBadge: Global.user?.userExtend?.vipBadge ??
                                  GBadge.NIL,
                              vipLevel: Global.loginUser!.userVipLevel,
                              select: false,
                              needMarqueeText: true,
                              // onlyName: Global.userOnlyName,
                              // goodNumber: Global.userGoodNumber &&
                              //     Global.user?.userExtend?.showName ==
                              //         GShowNameType.NUMBER,
                              fontSize: 18,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              !Global.loginUser!.userVip || expireTime.isEmpty
                                  ? '开通vip会员，尊享会员权益'.tr()
                                  : '到期时间：'.tr(args: [expireTime]),
                              style: TextStyle(
                                fontSize: 11,
                                color: myColors.goldColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 2,
                      left: 5,
                    ),
                    child: Text(
                      '当前经验：'.tr(
                        args: [
                          '${_experience.toString()}/${_upExperience.toString()}'
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: myColors.white,
                      ),
                    ),
                  ),
                  // LinearProgressIndicator(
                  //   value: _upExperience > 0 ? _experience / _upExperience : 0,
                  //   color: myColors.vipName,
                  //   backgroundColor: myColors.whiteOpacity,
                  // ),
                ],
              ),
            ),

            //经验列表
            RowList(
              rowNumber: 3,
              spacing: 15,
              children: [
                _jyWidget2(
                  title: '等级加速'.tr(),
                  rate: _unit / 5,
                  text: _unit.toString(),
                  unit: '倍'.tr(),
                  image: 'images/vip/sp_dengji.png',
                ),
                _jyWidget2(
                  title: '今日成长'.tr(),
                  rate: _todayExp / 100,
                  text: _todayExp.toString(),
                  unit: '经验'.tr(),
                  image: 'images/vip/sp_jinri.png',
                ),
                _jyWidget2(
                  title: '距离升级'.tr(),
                  rate: _upExperience > 0 ? _experience / _upExperience : 0,
                  text: (_upExperience - _experience) <= 0
                      ? '已满'.tr()
                      : (_upExperience - _experience).toString(),
                  unit: '经验'.tr(),
                  image: 'images/vip/sp_juli.png',
                ),
              ],
            ),

            //等级成长柱状图
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '会员等级经验值'.tr(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  //图表

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: myColors.vipBuyExpBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _levelList.map((e) {
                        var i = _levelList.indexOf(e);
                        return _pillarItem(
                          title: level2str(e.level),
                          multiple: 1 + (i * 0.5),
                          image: '',
                          exp: toInt(e.growthValue),
                          // color: _levelColors[i],
                          color: myColors.vipBuyExp,
                        );
                      }).toList(),
                    ),
                  ),

                  // const SizedBox(height: 15),
                  // Container(
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     '活跃度：在线时长每10分钟增加1点成长值，1元等于10积分',
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: myColors.textGrey,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 25),
                  // //当前倍数
                  // GestureDetector(
                  //   behavior: HitTestBehavior.opaque,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       '当前等级：（前往续费直升VIP5）'.tr(
                  //         args: [level2str(Global.userVipLevel)],
                  //       ),
                  //       style: const TextStyle(
                  //         color: myColors.primary,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.bold,
                  //         decoration: TextDecoration.underline,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            //等级说明表格
            SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //升级天数
                    Text(
                      '等级说明'.tr(),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Table(
                    //   border: TableBorder.all(
                    //     color: textColor,
                    //     width: .5,
                    //   ),
                    //   children: [
                    //     TableRow(
                    //       children: [
                    //         _tableCell(text: '名称'.tr()),
                    //         // _tableCell(text: '价格'),
                    //         // _tableCell(text: '赠送积分'),
                    //         _tableCell(text: '升级所需经验'.tr()),
                    //       ],
                    //     ),
                    //     for (var i = 0; i < _levelList.length; i++)
                    //       TableRow(
                    //         children: [
                    //           _tableCell(text: level2str(_levelList[i].level)),
                    //           // _tableCell(text: '￥${toCny(_levelList[i].price)}'),
                    //           // _tableCell(text: _levelList[i].giftPoints ?? ''),
                    //           _tableCell(text: _levelList[i].growthValue ?? ''),
                    //         ],
                    //       ),
                    //   ],
                    // ),
                    GestureDetector(
                      onTap: () {
                        goImage(assetPath('images/vip/level_info.jpg'));
                      },
                      child: Image.asset(
                        assetPath('images/vip/level_info.jpg'),
                        width: double.infinity,
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
}
