import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:provider/provider.dart';

class AvatarName extends StatelessWidget {
  final List<String> avatars; //头像url数组
  final String name; //用户昵称
  final String userName; //用户昵称
  final String userId; //用户id
  final String onlineTime; //最后在线时间
  final double size; //头像size
  final int maxLines; //昵称最大行数
  final Color? nameColor;
  final bool isOwner; //群主
  final bool isAdmin; //管理员

  const AvatarName({
    required this.avatars,
    required this.name,
    required this.userName,
    required this.userId,
    this.isOwner = false,
    this.isAdmin = false,
    this.onlineTime = '',
    this.size = 50,
    this.maxLines = 1,
    this.nameColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AppAvatar(
              list: avatars,
              size: size,
              userName: userName,
              userId: userId,
            ),
            if (isOwner || isAdmin)
              Container(
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
              )
          ],
        ),
        Container(
          width: size,
          margin: const EdgeInsets.only(top: 5),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name : userName,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 12,
              color: nameColor ?? myColors.textGrey,
            ),
          ),
        ),
        if (onlineTime.isNotEmpty)
          Text(
            onlineTime,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9,
              color: myColors.textGrey,
            ),
          ),
      ],
    );
  }
}
