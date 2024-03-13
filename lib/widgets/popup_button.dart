import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/pages/chat/chat_across.dart';
import 'package:unionchat/pages/friend/friend_add.dart';
import 'package:unionchat/pages/friend/friend_add_group.dart';
import 'package:provider/provider.dart';

import '../adapter/adapter.dart';
import '../common/func.dart';
import '../notifier/theme_notifier.dart';
import '../pages/chat/target/target_list.dart';
import '../pages/friend/friend_search.dart';

class PopupButton extends StatelessWidget {
  final Function()? reload;
  final Function() scan;
  final bool target; //是否显示聊天分组

  const PopupButton(
      {this.reload, this.target = false, required this.scan, super.key});

  @override
  Widget build(BuildContext context) {
    var bgColors = context.watch<ThemeNotifier>().popupThemeColor;
    var myColors = context.watch<ThemeNotifier>();
    List<PopupMenuEntry<int>> btnList = [];
    if (UserPowerType.group.hasPower) {
      btnList.add(
        PopupMenuItem(
          value: 1,
          child: PopuButtonBox(
            title: '新建群聊'.tr(),
            icons: assetPath('images/talk/sp_xinjianqunzu.png'),
          ),
        ),
      );
    }

    if (UserPowerType.addFriend.hasPower) {
      btnList.add(
        PopupMenuItem(
          value: 2,
          child: PopuButtonBox(
            title: '添加好友'.tr(),
            icons: assetPath('images/talk/sp_tianjiahaoyou.png'),
          ),
        ),
      );
    }
    if (FunctionConfig.share) {
      btnList.add(
        PopupMenuItem(
          value: 3,
          child: PopuButtonBox(
            title: '坐席管理'.tr(),
            icons: assetPath('images/talk/sp_zuoxiguanli.png'),
          ),
        ),
      );
    }
    if (target) {
      btnList.add(
        PopupMenuItem(
          value: 4,
          child: PopuButtonBox(
            title: '聊天分组'.tr(),
            icons: assetPath('images/talk/sp_liaotianfenzu.png'),
          ),
        ),
      );
    }
    if (UserPowerType.addFriend.hasPower && (platformPhone)) {
      btnList.add(
        PopupMenuItem(
          value: 5,
          child: PopuButtonBox(
            title: '扫一扫'.tr(),
            icons: assetPath('images/talk/sp_soayisao.png'),
          ),
        ),
      );
    }

    if (btnList.isEmpty) return Container();
    return PopupMenuButton<int>(
      color: bgColors,
      onSelected: (index) {
        if (index == 0) {
          //发起聊天
        }
        if (index == 1) {
          //新建群聊
          Adapter.navigatorTo(FriendAddGroup.path);
        }
        if (index == 2) {
          //添加好友
          if (platformPhone) {
            Adapter.navigatorTo(FriendAdd.path).then((value) {
              if (reload != null) reload!();
            });
          } else {
            Adapter.navigatorTo(FriendSearch.path).then((value) {
              if (reload != null) reload!();
            });
          }
        }
        if (index == 3) {
          //坐席管理
          // ApiRequest.apiShareChat();
          Adapter.navigatorTo(ChatAcross.path);
        }
        if (index == 4) {
          Adapter.navigatorTo(ChatTargetList.path);
        }
        if (index == 5) {
          //扫一扫
          scan();
        }
      },
      itemBuilder: (context1) {
        return btnList;
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          assetPath('images/talk/more.png'),
          width: 18,
          height: 18,
          color: myColors.iconThemeColor,
        ),
      ),
    );
  }
}

class PopuButtonBox extends StatelessWidget {
  final String? icons;
  final String title;

  const PopuButtonBox({
    super.key,
    this.icons,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          if (icons!.isNotEmpty)
            SizedBox(
              width: 22,
              height: 22,
              // alignment: Alignment.center,
              child: Image.asset(
                icons ?? '',
                fit: BoxFit.contain,
              ),
            ),
          if (icons!.isNotEmpty)
            const SizedBox(
              width: 12,
            ),
          Text(title),
        ],
      ),
    );
  }
}
