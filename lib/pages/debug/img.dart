import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:unionchat/widgets/network_image.dart';

class Img extends StatefulWidget {
  const Img({super.key});

  @override
  State<Img> createState() => _ImgState();
}

class _ImgState extends State<Img> {
  final url =
      'https://imstore.oss-accelerate.aliyuncs.com/c0/d5/c0d5d08057d153757c352f08f5a7efce-size-4224x5632.jpg';

  File? file;
  List<int>? bodyBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppNetworkImage(
        url,
        width: 200,
      ),
    );
  }
}
