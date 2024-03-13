import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/pages/friend/friend_search.dart';
import 'package:unionchat/pages/friend/scanpage.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/menu_ul.dart';
import '../../widgets/search_input.dart';

class FriendAdd extends StatefulWidget {
  const FriendAdd({super.key});

  static const String path = 'friends/addfriend';

  @override
  State<StatefulWidget> createState() {
    return _FriendAddState();
  }
}

class _FriendAddState extends State<FriendAdd> {
  bool showQr = false;

  //进入二维码扫描
  Future scanPage() async {
    var status = await Permission.camera.request();
    if (status.isGranted && mounted) {
      Navigator.pushNamed(context, ScanPage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text('添加朋友'.tr()),
        ),
        body: ThemeBody(
          child: SingleChildScrollView(
            child: Column(children: [
              SearchInput(
                disabled: true,
                onTap: () {
                  Navigator.pushNamed(context, FriendSearch.path);
                },
              ),
              const SizedBox(height: 10),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       showQr = true;
              //     });
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         '我的账号：${Global.user!.userNo!}',
              //         style:
              //             const TextStyle(fontSize: 12, color: myColors.textGrey),
              //       ),
              //       const Icon(
              //         Icons.qr_code,
              //         size: 20,
              //         color: myColors.primary,
              //       ),
              //     ],
              //   ),
              // ),
              // if (!showQr)
              if (platformPhone)
                MenuUl(
                  marginTop: 0,
                  children: [
                    MenuItemData(
                      icon: assetPath('images/talk/scan.png'),
                      iconSize: 48,
                      onTap: () {
                        scanPage();
                      },
                      title: '二维码添加'.tr(),
                    ),
                  ],
                ),
            ]),
          ),
        ),
      ),
    ]);
  }
}
