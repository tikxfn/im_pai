import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/menu_ul.dart';

import '../../common/func.dart';
import '../../function_config.dart';
import '../../global.dart';
import '../collect/collect_home.dart';
import '../mall/mall_home.dart';
import '../note/note_home.dart';
import '../photo_album/photo_home.dart';

class MineService extends StatefulWidget {
  const MineService({super.key});

  static const String path = 'mine/service';

  @override
  State<MineService> createState() => _MineServiceState();
}

class _MineServiceState extends State<MineService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('派聊服务'),
      ),
      body: ListView(
        children: [
          MenuUl(
            children: [
              if (FunctionConfig.superAlbum)
                MenuItemData(
                  title: '超级相册'.tr(),
                  icon: assetPath('images/my/sp_gerenzhongxin.png'),
                  onTap: () {
                    Navigator.pushNamed(context, PhotoHome.path);
                  },
                ),
              if (FunctionConfig.mall)
                MenuItemData(
                  title: '派聊商城'.tr(),
                  icon: assetPath('images/my/sp_shangcheng.png'),
                  onTap: () {
                    Navigator.pushNamed(context, MallHome.path).then(
                      (value) async {
                        await Global.syncLoginUser();
                        if (!mounted) return;
                        setState(() {});
                      },
                    );
                  },
                ),
              MenuItemData(
                title: '我的收藏'.tr(),
                icon: assetPath('images/my/sp_wodeshoucang.png'),
                onTap: () {
                  Navigator.pushNamed(context, CollectHome.path);
                },
              ),
              MenuItemData(
                title: '我的笔记'.tr(),
                icon: assetPath('images/my/sp_wodebiji.png'),
                onTap: () {
                  Navigator.pushNamed(context, NoteHome.path);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
