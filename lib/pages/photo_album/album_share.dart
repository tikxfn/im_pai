import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/about_image.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../widgets/button.dart';

class AlbumShare extends StatefulWidget {
  const AlbumShare({super.key});

  static const String path = 'album/Share';

  @override
  State<AlbumShare> createState() => _AlbumShareState();
}

class _AlbumShareState extends State<AlbumShare> {
  String url = '';

  int type = 0;

  final GlobalKey _globalKey = GlobalKey();

  // 二维码
  Widget _qrCode() {
    var myColors = ThemeNotifier();
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: double.infinity,
        color: myColors.white,
        child: Column(
          children: [
            const SizedBox(height: 30),
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                size: const Size.square(100),
                painter: QrPainter(
                  data: Uri.decodeFull(url),
                  version: QrVersions.auto,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: myColors.black,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: myColors.black,
                  ),
                  // size: 320.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              // color: myColors.backGroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: 280,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ClipboardData data = ClipboardData(text: url);
                  Clipboard.setData(data);
                  tipSuccess('内容已复制到粘贴板'.tr());
                },
                child: Text(
                  url,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: myColors.imGreen2,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['url'] != null) url = args['url'];
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.imGreen2,
      appBar: AppBar(
        backgroundColor: myColors.imGreen2,
        iconTheme: IconThemeData(
          color: myColors.white,
        ),
        title: Text(
          '相册分享'.tr(),
          style: TextStyle(
            color: myColors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _qrCode(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          CircleButton(
            shadowColor: myColors.black,
            elevation: 4,
            theme: AppButtonTheme.blue,
            title: '截图分享'.tr(),
            fontSize: 16,
            height: 50,
            radius: 10,
            onTap: () {
              globSaveImageToGallery(_globalKey);
            },
          ),
        ],
      ),
    );
  }
}
