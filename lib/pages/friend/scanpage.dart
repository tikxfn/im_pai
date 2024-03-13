import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/url_text.dart';
import 'package:scan/scan.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);
  static const path = 'friend/scan';

  @override
  // ignore: library_private_types_in_public_api
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  //扫描结果异常状态
  bool notFound = false;

  //扫描内容
  String scResult = '';
  ScanController controller = ScanController();
  bool lightStatus = false; //灯状态

  void getResult1(String result, BuildContext context) async {
    scResult = result;
    controller.pause();
    notFound = !getResult(result, context);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫一扫'.tr()),
      ),
      body: notFound
          ? ThemeBody(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: UrlText('识别结果：$scResult'),
              ),
            )
          : Stack(
              children: [
                _scan(),
                _light(),
                _image(),
              ],
            ),
    );
  }

  Widget _scan() {
    return Column(
      children: [
        Expanded(
          child: ScanView(
            controller: controller,
            scanAreaScale: .7,
            scanLineColor: Colors.green,
            onCapture: (data) {
              getResult1(data, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _light() {
    return Positioned(
      left: 52,
      bottom: 79,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialButton(
              child: Image.asset(
                assetPath('images/lightIcon${lightStatus ? '' : '_off'}.png'),
                height: 68,
                width: 68,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                controller.toggleTorchMode();
                lightStatus = !lightStatus;
                setState(() {});
              });
        },
      ),
    );
  }

  Widget _image() {
    return Positioned(
      right: 52,
      bottom: 79,
      child: MaterialButton(
          child: Image.asset(
            assetPath('images/image.png'),
            height: 68,
            width: 68,
            fit: BoxFit.contain,
          ),
          onPressed: () async {
            controller.pause();
            final ImagePicker imagePicker = ImagePicker();
            XFile? res = await imagePicker.pickImage(
              source: ImageSource.gallery,
            );
            // List<Media>? res = await ImagesPicker.pick(count: 1, maxSize: 1024);
            if (res != null) {
              // Media image = res.first;
              XFile image = res;
              String? result = await Scan.parse(image.path);
              if (result != null && mounted) {
                getResult1(result, context);
              }
            } else {
              controller.resume();
            }
          }),
    );
  }
}
