import 'package:flutter/material.dart';
import 'package:unionchat/common/file_open.dart';
import 'package:unionchat/common/file_save.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/widgets/button.dart';

class FilePreview extends StatefulWidget {
  const FilePreview({super.key});

  static const String path = 'file/preview';

  @override
  State<StatefulWidget> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  String fileUrl = '';
  String fileName = '';
  int size = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      setState(() {
        fileUrl = args['file'] ?? '';
        fileName = args['name'] ?? '';
        size = toInt(args['size'] ?? '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                assetPath('images/sp_wenjian.png'),
                height: 70,
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  (fileUrl.isNotEmpty ? fileUrl.split('.').last : 'unknown')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fileName,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            b2size(size.toDouble()),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleButton(
                title: '保存文件',
                width: 200,
                height: 40,
                fontSize: 14,
                radius: 7,
                onTap: () {
                  FileSave().saveFile(fileUrl, fileName: fileName);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleButton(
                title: '打开文件',
                theme: AppButtonTheme.greenWhite,
                width: 200,
                height: 40,
                fontSize: 14,
                radius: 7,
                onTap: () {
                  FileOpen.open(fileUrl);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
