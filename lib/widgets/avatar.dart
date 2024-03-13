import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

//头像组件
class AppAvatar extends StatelessWidget {
  //头像url数组
  final List<String> list;

  //间距
  final double spacing;

  //盒子大小
  final double size;

  //圆角
  final double borderRadius;

  //背景色
  final Color? backgroundColor;

  //头像显示名称
  final String userName;

  //用户id
  final String userId;

  final bool isOwner; //群主
  final bool isAdmin; //管理员

  final bool vip;
  final GVipLevel? vipLevel;
  final double avatarFrameHeightSize; //有头像框时需增加的高度大小
  final double avatarFrameWidthSize; //有头像框时需增加的宽度大小
  final double avatarTopPadding; //有头像框时，头像框不规则增加top移动到中心
  final double avatarleftPadding; //有头像框时，头像框不规则增加left移动到中心

  const AppAvatar({
    required this.list,
    required this.userName,
    required this.userId,
    this.isOwner = false,
    this.isAdmin = false,
    this.spacing = 2,
    this.size = 50,
    this.avatarFrameHeightSize = 15,
    this.avatarFrameWidthSize = 15,
    this.avatarTopPadding = 0,
    this.avatarleftPadding = 0,
    this.borderRadius = 50,
    this.backgroundColor,
    this.vip = false,
    this.vipLevel = GVipLevel.NIL,
    super.key,
  });

  //默认头像
  Widget defaultAvatar(String url) {
    return AppNetworkImage(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      imageSpecification: ImageSpecification.w120,
      avatar: true,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  Widget _avatarBuild(myColors) {
    final List<Color> colors = [
      myColors.primary,
      myColors.red,
      myColors.yellow,
      myColors.vipName,
      myColors.goldColor,
      myColors.blueGrey,
    ];
    bool zombie = list.isNotEmpty && list[0] == '@Zombie';
    if (list.length <= 1 && !zombie) {
      if (list.isNotEmpty && list[0] == '@Zombie') {}
      var noAvatar = list.isEmpty ||
          (list.length == 1 && (list[0].isEmpty || list[0] == 'null'));
      if (noAvatar && userName.isNotEmpty) {
        var i = toInt(userId) % 6;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: colors[i],
              ),
              child: Text(
                (userName.isNotEmpty ? userName[0] : '').toUpperCase(),
                style: TextStyle(
                  color: myColors.white,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
      return defaultAvatar(list[0]);
    }
    List<String> arr = list;
    if (list.length > 9) arr = list.take(9).toList();
    if (zombie) arr = [zombieAvatar(userId)];
    int num = arr.length;
    // logger.d(num);
    double itemSize = 0;
    var itemSpacing = spacing;
    if (num == 1) {
      itemSize = size;
      itemSpacing = 0;
    } else if (num <= 4) {
      itemSize = (size - itemSpacing * 3) / 2;
    } else {
      itemSize = (size - itemSpacing * 4) / 3;
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(itemSpacing),
      decoration: BoxDecoration(
        color: backgroundColor ?? myColors.avatarBackground,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: itemSpacing,
        runSpacing: itemSpacing,
        children: arr.map((e) {
          // if(zombie){
          //   // logger.d(itemSize);
          //   return ClipRRect(
          //     borderRadius: BorderRadius.circular(borderRadius),
          //     child: Image.asset(
          //       e,
          //       width: itemSize,
          //       height: itemSize,
          //       fit: BoxFit.cover,
          //     ),
          //   );
          // }
          return AppNetworkImage(
            e,
            assets: zombie,
            width: itemSize,
            height: itemSize,
            fit: BoxFit.cover,
            imageSpecification: ImageSpecification.w120,
            avatar: true,
            borderRadius: BorderRadius.circular(borderRadius),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var tagText = level2str(vipLevel).toUpperCase();
    double addAvatarSize = 0; //vip5、6增加大小
    String leveTag = 'images/my/avatar_v1.png';
    switch (tagText) {
      case '':
        break;
      case 'VIP1':
        leveTag = 'images/my/avatar_v1.png';
        break;
      case 'VIP2':
        leveTag = 'images/my/avatar_v2.png';
        break;
      case 'VIP3':
        leveTag = 'images/my/avatar_v3.png';
        break;
      case 'VIP4':
        leveTag = 'images/my/avatar_v4.png';
        break;
      case 'VIP5':
        leveTag = 'images/my/avatar_v5.png';
        addAvatarSize = 5;
        break;
      case 'VIP6':
        leveTag = 'images/my/avatar_v6.png';
        addAvatarSize = 10;
        break;
    }
    var myColors = context.watch<ThemeNotifier>();
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: avatarTopPadding,
            left: avatarleftPadding,
          ),
          child: _avatarBuild(myColors),
        ),
        if (vip)
          Image.asset(
            assetPath(leveTag),
            // height: size + avatarFrameWidthSize,
            // width: size + avatarFrameWidthSize,
            height: size + avatarFrameHeightSize,
            width: size + avatarFrameWidthSize + addAvatarSize,
            fit: BoxFit.contain,
          ),
        if (isOwner || isAdmin)
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isOwner ? myColors.owner : myColors.admin,
              ),
              child: Text(
                isOwner ? '群主'.tr() : '管理员'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: myColors.white,
                  fontSize: 8,
                ),
              ),
            ),
          )
      ],
    );
  }
}
