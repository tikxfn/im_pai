import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/about_image.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/mine/my_points.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../widgets/button.dart';

// class SharePage extends StatefulWidget {
//   const SharePage({super.key});

//   static const String path = 'SharePage/setting';

//   @override
//   State<SharePage> createState() => _SharePageState();
// }

// class _SharePageState extends State<SharePage> {
//   String url = '';
//   String talkUrl = '';
//   int type = 0;

//   final GlobalKey _globalKey = GlobalKey();

//   // 获取跨聊链接
//   _getWebTalkUrl() async {
//     loading();
//     var api = ChatApi(apiClient());
//     try {
//       // var res = await api.chatCasualChat({});
//       var res = await api.chatCasualRoomChat({});
//       if (res == null || !mounted) return;
//       setState(() {
//         talkUrl = res.url ?? '';
//       });
//     } on ApiException catch (e) {
//       onError(e);
//     } finally {
//       loadClose();
//     }
//   }

//   //二维码
//   Widget createBody() {
//     return RepaintBoundary(
//       key: _globalKey,
//       child: Stack(
//         children: [
//           Container(
//             width: 300,
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               // vertical: 20,
//             ),
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: ExactAssetImage(assetPath(
//                     'images/my/${type == 0 ? 'share_app_select' : 'share_zuoxi_select'}.png')),
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 80,
//                 ),
//                 //二维码
//                 Container(
//                   width: 240,
//                   height: 240,
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: myColors.white,
//                     border: Border.all(
//                       color: myColors.black,
//                       style: BorderStyle.solid,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: CustomPaint(
//                     size: const Size.square(100),
//                     painter: QrPainter(
//                       data: Uri.decodeFull(type == 0 ? url : talkUrl),
//                       version: QrVersions.auto,
//                       eyeStyle: const QrEyeStyle(
//                         eyeShape: QrEyeShape.square,
//                         color: Colors.black,
//                       ),
//                       dataModuleStyle: const QrDataModuleStyle(
//                         dataModuleShape: QrDataModuleShape.circle,
//                         color: Colors.black,
//                       ),
//                       // size: 320.0,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 50,
//                 ),
//                 GestureDetector(
//                   // behavior: HitTestBehavior.opaque,
//                   onTap: () {
//                     ClipboardData data =
//                         ClipboardData(text: type == 0 ? url : talkUrl);
//                     Clipboard.setData(data);
//                     tipSuccess('内容已复制到粘贴板'.tr());
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     decoration: const BoxDecoration(
//                       color: myColors.grey,
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                     ),
//                     child: Text(
//                       type == 0 ? url : talkUrl,
//                       style: const TextStyle(
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//               ],
//             ),
//           ),
//           //tab切换
//           Positioned(
//             right: type == 0 ? 0 : null,
//             left: type == 0 ? null : 0,
//             top: 0,
//             child: GestureDetector(
//               onTap: () {
//                 if (type == 1) {
//                   setState(() {
//                     type = 0;
//                   });
//                   return;
//                 }
//                 if (type == 0) {
//                   setState(() {
//                     type = 1;
//                   });
//                   _getWebTalkUrl();
//                   return;
//                 }
//               },
//               child: Image.asset(
//                 assetPath(
//                     'images/my/${type == 0 ? 'share_zuoxi' : 'share_app'}.png'),
//                 width: 140,
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     url =
//         '${Global.systemInfo.appVersion?.shareUrl ?? ''}?ic_code=${Global.user!.uid}';
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: ExactAssetImage(assetPath('images/my/scan_bg.png')),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: const IconThemeData(
//             color: myColors.white,
//           ),
//           title: Text(
//             '分享'.tr(),
//             style: const TextStyle(
//               color: myColors.white,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, MyPointPage.path);
//               },
//               child: const Text('分享记录'),
//             )
//           ],
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             createBody(),
//             Container(
//               margin: const EdgeInsets.symmetric(
//                 vertical: 20,
//                 horizontal: 45,
//               ),
//               child: CircleButton(
//                 shadowColor: myColors.black,
//                 elevation: 4,
//                 theme: AppButtonTheme.primary,
//                 title: '截图分享'.tr(),
//                 fontSize: 14,
//                 height: 50,
//                 radius: 25,
//                 onTap: () {
//                   globSaveImageToGallery(_globalKey);
//                 },
//               ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  static const String path = 'SharePage/setting';

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final GlobalKey _globalKey = GlobalKey();
  String url = '';

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    url = createScanUrl(data: Global.user?.id ?? '', type: 'imUser');
    // url =
    //     '${Global.systemInfo.appVersion?.shareUrl ?? ''}?${Global.shareCodeName}=${Global.user!.uid}&'
    //     'imUser=${Global.user?.id ?? ''}&target=feiou';
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage(assetPath('images/my/scan_bg.png')),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: myColors.white,
          ),
          title: Text(
            '分享'.tr(),
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
                style: TextStyle(color: myColors.primary),
              ),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createBody(),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 45,
              ),
              child: CircleButton(
                shadowColor: myColors.black,
                elevation: 4,
                theme: AppButtonTheme.primary,
                title: '截图分享'.tr(),
                fontSize: 14,
                height: 50,
                radius: 25,
                onTap: () {
                  globSaveImageToGallery(_globalKey);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createBody() {
    var myColors = ThemeNotifier();
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: 300,
        // height: 500,
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          // vertical: 20,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage(assetPath('images/my/my_sacn_bg.png')),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'APP分享',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //二维码
            Container(
              width: 230,
              height: 230,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: myColors.white,
                border: Border.all(
                  color: myColors.black,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
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
                  // size: 320.0,
                ),
              ),
            ),

            const SizedBox(
              height: 70,
            ),

            GestureDetector(
              // behavior: HitTestBehavior.opaque,
              onTap: () {
                ClipboardData data = ClipboardData(text: url);
                Clipboard.setData(data);
                tipSuccess('内容已复制到粘贴板'.tr());
              },
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
