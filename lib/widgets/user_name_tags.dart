import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/marquee_text.dart';
import 'package:unionchat/widgets/vip_tag.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../common/func.dart';

class UserNameTags extends StatelessWidget {
  final String userName;
  final String mark;
  final bool vip;
  final GVipLevel vipLevel;
  final GBadge vipBadge;
  final bool vipDisabledShow;
  final bool onlyName;
  final bool goodNumber;
  final GUserNumberType numberType;
  final bool circleGuarantee;
  final bool system;
  final bool customer;
  final bool room;
  final double fontSize;
  final double iconSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool select;
  final bool needMarqueeText;

  const UserNameTags({
    this.userName = '',
    this.mark = '',
    this.vipLevel = GVipLevel.NIL,
    this.vip = false,
    this.vipDisabledShow = false,
    this.vipBadge = GBadge.NIL,
    this.onlyName = false,
    this.goodNumber = false,
    this.numberType = GUserNumberType.OTHER,
    this.circleGuarantee = false,
    this.system = false,
    this.customer = false,
    this.room = false,
    this.fontSize = 14,
    this.iconSize = 20,
    this.fontWeight,
    this.color,
    this.select = true,
    this.needMarqueeText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    // switch(vipLevel){
    //   case GVipLevel.NIL:

    //     break;
    //   case GVipLevel.n1:

    //     break;
    //   case GVipLevel.n2:

    //     break;
    //   case GVipLevel.n3:

    //     break;
    //   case GVipLevel.n4:

    //     break;
    //   case GVipLevel.n5:

    //     break;
    //   case GVipLevel.n6:

    //     break;
    // }
    var tc = vip ? myColors.vipName : color ?? textColor;

    var vipName = level2str(vipLevel);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (room) RoomTags(color: color),
        Flexible(
          child: select
              ? SelectableText(
                  mark.isNotEmpty ? mark : userName,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: tc,
                  ),
                )
              : needMarqueeText
                  ? MarqueeText(
                      text: mark.isNotEmpty ? mark : userName,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: tc,
                      ),
                    )
                  : Text(
                      mark.isNotEmpty ? mark : userName,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: tc,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
        ),
        if (system) SystemTag(size: iconSize),
        if (customer) CustomerTag(size: iconSize),

        if (goodNumber && FunctionConfig.goodNumber)
          GoodNumberTag(size: iconSize - 4, numberType: numberType),
        if (onlyName) OnlyNumberTag(size: iconSize),
        if (circleGuarantee) BaoTag(size: iconSize - 4),
        if ((vip || (!vip && vipDisabledShow)) && FunctionConfig.vip)
          VipTag(
            vip: vip,
            text: vip || (!vip && vipDisabledShow) ? vipName : '非会员'.tr(),
            vipBadge: vipBadge,
            size: iconSize - 1,
          ),
        // const VipTag(vip: true, text: '唯名卡'),
      ],
    );
  }
}
