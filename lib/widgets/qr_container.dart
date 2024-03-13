import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class QrContainer extends StatelessWidget {
  String data;
  Function()? onTap;
  double width;
  double height;
  Color color1;
  Color color2;
  QrContainer({
    super.key,
    this.onTap,
    this.width = 350,
    this.height = 400,
    required this.data,
    this.color1 = const Color.fromARGB(255, 54, 158, 199),
    this.color2 = const Color.fromARGB(255, 76, 79, 226),
  });

  @override
  Widget build(BuildContext context) {
    logger.i('二维码数据$data');
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // Alignment(x,y)  (0,0) 是由 rectangle 中心点计算的
                begin: const Alignment(1.0, -1.0),
                end: const Alignment(-1.0, 1.0),
                colors: <Color>[
                  color1,
                  color2,
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
          ),
          SizedBox(
            width: width * 2 / 3,
            height: width * 2 / 3,
            child: CustomPaint(
              size: const Size.square(100),
              painter: QrPainter(
                data: data,
                version: QrVersions.auto,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.white,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Colors.white,
                ),
                // size: 320.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
