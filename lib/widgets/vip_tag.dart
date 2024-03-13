import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../common/func.dart';

//会员标签
class VipTag extends StatelessWidget {
  final bool vip;
  final String text;
  final GBadge vipBadge;
  final double marginLeft;
  final double marginRight;
  final double horizontal;
  final double vertical;
  final double borderRadius;
  final FontStyle fontStyle;
  final double size;

  const VipTag({
    this.vip = false,
    this.text = '',
    this.vipBadge = GBadge.NIL,
    this.marginLeft = 5,
    this.marginRight = 0,
    this.horizontal = 5,
    this.vertical = 1,
    this.borderRadius = 20,
    this.fontStyle = FontStyle.italic,
    this.size = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // var bgColor = vip ? myColors.vipName : myColors.textGrey;
    var tagText = text.toUpperCase();
    String leveTag = 'images/my/vip1.png';
    // String vipTag = 'images/my/vip_month.png';

    // switch (vipBadge) {
    //   case GBadge.MONTH:
    //     break;
    //   case GBadge.NIL:
    //     break;
    //   case GBadge.QUARTER:
    //     vipTag = 'images/my/vip_quarter.png';
    //     break;
    //   case GBadge.YEAR:
    //     vipTag = 'images/my/vip_year.png';
    //     break;
    // }
    switch (tagText) {
      case '':
        break;
      case 'VIP1':
        leveTag = 'images/my/vip1.png';
        break;
      case 'VIP2':
        leveTag = 'images/my/vip2.png';
        break;
      case 'VIP3':
        leveTag = 'images/my/vip3.png';
        break;
      case 'VIP4':
        leveTag = 'images/my/vip4.png';
        break;
      case 'VIP5':
        leveTag = 'images/my/vip5.png';
        break;
      case 'VIP6':
        leveTag = 'images/my/vip6.png';
        break;
    }
    // var tagText = (vip ? text : '非会员'.tr()).toUpperCase();
    return Container(
      margin: EdgeInsets.only(left: marginLeft, right: marginRight),
      // padding: EdgeInsets.symmetric(
      //      horizontal: horizontal,
      //     vertical: vertical,
      //     ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            assetPath(leveTag),
            // width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          // Image.asset(
          //   assetPath(leveTag),
          //   width: size - 3,
          //   height: size - 3,
          //   fit: BoxFit.contain,
          // ),
          // Positioned(
          //   right: 4,
          //   child: Text(
          //     tagText,
          //     style: TextStyle(
          //       color: ThemeNotifier().grey,
          //       fontSize: 10,
          //       fontWeight: FontWeight.bold,
          //       fontStyle: fontStyle,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

//靓号标签
class GoodNumberTag extends StatelessWidget {
  final double size;
  final double marginLeft;
  final double marginRight;
  final GUserNumberType numberType;

  const GoodNumberTag({
    this.size = 25,
    this.marginLeft = 5,
    this.marginRight = 0,
    this.numberType = GUserNumberType.OTHER,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return goodNumberImageString(numberType) != ''
        ? Padding(
            padding: EdgeInsets.only(left: marginLeft, right: marginRight),
            child: Image.asset(
              assetPath(goodNumberImageString(numberType)),
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          )
        : Container();
  }
}

//唯一号标签
class OnlyNumberTag extends StatelessWidget {
  final double size;
  final double marginLeft;
  final double marginRight;

  const OnlyNumberTag({
    this.size = 25,
    this.marginLeft = 5,
    this.marginRight = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: marginLeft, right: marginRight),
      child: Image.asset(
        assetPath('images/my/sp_only.png'),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

//保号标签
class BaoTag extends StatelessWidget {
  final double size;
  final double marginLeft;
  final double marginRight;

  const BaoTag({
    this.size = 25,
    this.marginLeft = 5,
    this.marginRight = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: marginLeft, right: marginRight),
      child: Image.asset(
        assetPath('images/my/bao.png'),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

//系统号标签
class SystemTag extends StatelessWidget {
  final double size;
  final double marginLeft;
  final double marginRight;

  const SystemTag({
    this.size = 25,
    this.marginLeft = 5,
    this.marginRight = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: marginLeft, right: marginRight),
      child: Image.asset(
        assetPath('images/my/sp_xitong.png'),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

//客服号标签
class CustomerTag extends StatelessWidget {
  final double size;
  final double marginLeft;
  final double marginRight;

  const CustomerTag({
    this.size = 25,
    this.marginLeft = 5,
    this.marginRight = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: marginLeft, right: marginRight),
      child: Image.asset(
        assetPath('images/my/sp_kefu.png'),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

//群聊标签
class RoomTags extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const RoomTags({
    super.key,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      margin: margin ?? const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: color ?? myColors.primary,
          width: .5,
        ),
      ),
      child: Text(
        '群聊'.tr(),
        style: TextStyle(
          color: color ?? myColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}
