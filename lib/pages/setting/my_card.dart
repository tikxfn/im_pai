import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/about_image.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/mine/my_points.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({super.key});

  static const path = 'MyCardPage/home';

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  final GlobalKey _globalKey = GlobalKey();
  String url = '';

  @override
  Widget build(BuildContext context) {
    url = createScanUrl(data: Global.user?.id ?? '', type: 'imUser');
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
        // extendBodyBehindAppBar: true,
        backgroundColor: myColors.circleBlueButtonBg,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: myColors.white,
          ),
          title: Text(
            '我的二维码'.tr(),
            style: TextStyle(
              color: myColors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, MyPointPage.path);
              },
              child: Text(
                '分享记录',
                style: TextStyle(color: myColors.white),
              ),
            )
          ],
        ),
        body: RepaintBoundary(
          key: _globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createBody(),
              // Container(
              //   margin: const EdgeInsets.only(
              //     top: 20,
              //     left: 30,
              //     right: 30,
              //   ),
              //   child: Row(
              //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       if (isMobile())
              //         Expanded(
              //           child: CircleButton(
              //             title: '  保存二维码  '.tr(),
              //             height: 40,
              //             radius: 15,
              //             theme: AppButtonTheme.greenWhite,
              //             onTap: () {
              //               globSaveImageToGallery(_globalKey);
              //             },
              //           ),
              //         ),
              //       if (isMobile())
              //         const SizedBox(
              //           width: 20,
              //         ),
              //       Expanded(
              //         child: CircleButton(
              //           title: '  分享给好友  '.tr(),
              //           height: 40,
              //           radius: 15,
              //           theme: AppButtonTheme.primary,
              //           onTap: () {
              //             Navigator.push(
              //               context,
              //               CupertinoModalPopupRoute(
              //                 builder: (context) {
              //                   return ShareHome(
              //                     shareText: '[个人名片]'
              //                         .tr(args: [Global.user?.nickname ?? '']),
              //                     contentIds: [Global.user?.id ?? ''],
              //                     type: MessageType.userCard,
              //                   );
              //                 },
              //               ),
              //             );
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            color: myColors.bottom,
            boxShadow: [
              BoxShadow(
                color: myColors.bottomShadow,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: CircleButton(
                    onTap: () async {
                      var msg = Message()
                        ..senderUser = getSenderUser()
                        ..type = GMessageType.USER_CARD
                        ..content = Global.user?.nickname
                        ..fileUrl = Global.user?.avatar
                        ..contentId = toInt(Global.user?.id);
                      Navigator.push(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) {
                            return ShareHome(
                              list: [msg],
                              shareText: '[个人名片]'
                                  .tr(args: [Global.user?.nickname ?? '']),
                            );
                          },
                        ),
                      );
                    },
                    title: '分享给好友'.tr(),
                    icon: 'images/my/scan_share.png',
                    radius: 10,
                    theme: AppButtonTheme.blue0,
                    fontSize: 16,
                    height: 47,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: CircleButton(
                    onTap: () {
                      globSaveImageToGallery(_globalKey);
                    },
                    icon: 'images/my/scan_save.png',
                    title: '保存二维码'.tr(),
                    radius: 10,
                    theme: AppButtonTheme.blue,
                    fontSize: 16,
                    height: 47,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget createBody() {
    var myColors = ThemeNotifier();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(31, 41, 31, 0),
          padding: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: myColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  Global.user?.nickname ?? '',
                  style: TextStyle(
                      color: myColors.textBlack,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
              ),

              //二维码
              Container(
                width: 230,
                height: 230,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: myColors.white,
                ),
                child: CustomPaint(
                  size: const Size.square(100),
                  painter: QrPainter(
                    data: Uri.decodeFull(url),
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '扫一扫上面的二维码图案，加我为朋友'.tr(),
                  style: TextStyle(
                    color: myColors.accountTagTitle,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ClipboardData data =
                      ClipboardData(text: Global.user?.uid ?? '');
                  Clipboard.setData(data);
                  tipSuccess('邀请码已复制到粘贴板'.tr());
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    // color: myColors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '邀请码：',
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        Global.user?.uid ?? '',
                        style: TextStyle(
                          color: myColors.blueTitle,
                          fontSize: 19,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ClipboardData data = ClipboardData(text: url);
                  Clipboard.setData(data);
                  tipSuccess('邀请链接已复制到粘贴板'.tr());
                },
                child: Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: myColors.grey,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    url,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              // Expanded(child: Container()),
              // //底部三个按钮
              // createBottom(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            border: Border.all(
              width: 2,
              color: myColors.white,
            ),
          ),
          child: AppAvatar(
            list: [
              Global.user != null && Global.user!.avatar != null
                  ? Global.user!.avatar!
                  : ''
            ],
            size: 80,
            userName: Global.user!.nickname!,
            userId: Global.user!.id ?? '',
          ),
        ),
      ],
    );
  }

// Widget createBottom() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         '扫一扫'.tr(),
//         style: const TextStyle(
//             color: Color.fromRGBO(97, 115, 150, 1.0),
//             fontSize: 15,
//             fontWeight: FontWeight.w600),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(left: 15, right: 15),
//         child: Container(
//           color: const Color.fromRGBO(97, 115, 150, 1.0),
//           height: 10,
//           width: 0.5,
//         ),
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             // if (backColor == myColors.white) {
//             //   backColor = myColors.backGroundColor;
//             // } else if (backColor == myColors.backGroundColor) {
//             //   backColor = myColors.white;
//             // }
//           });
//         },
//         child: Text(
//           '换一换'.tr(),
//           style: const TextStyle(
//               color: Color.fromRGBO(97, 115, 150, 1.0),
//               fontSize: 15,
//               fontWeight: FontWeight.w600),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(left: 15, right: 15),
//         child: Container(
//           color: const Color.fromRGBO(97, 115, 150, 1.0),
//           height: 10,
//           width: 0.5,
//         ),
//       ),
//       Text(
//         '保存图片'.tr(),
//         style: const TextStyle(
//             color: Color.fromRGBO(97, 115, 150, 1.0),
//             fontSize: 15,
//             fontWeight: FontWeight.w600),
//       ),
//     ],
//   );
// }
}
