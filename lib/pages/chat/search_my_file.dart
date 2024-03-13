import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/file_preview.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class SearchMyFilePage extends StatefulWidget {
  const SearchMyFilePage({super.key});

  static const String path = 'SearchMyFilePage/path';

  @override
  State<SearchMyFilePage> createState() => _SearchMyFilePageState();
}

class _SearchMyFilePageState extends State<SearchMyFilePage> {
  List<Message> searchFileResults = [];
  String userId = '';
  String pairId = '';
  String roomId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    userId = args['id'] ?? '';
    pairId = args['pairId'] ?? '';
    roomId = args['roomId'] ?? '';
    requestFileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('文件'.tr()),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: ThemeBody(
        child: createBody(),
      ),
    );
  }

  Widget createBody() {
    return ListView.builder(
      itemCount: searchFileResults.length,
      itemBuilder: (context, index) {
        return createCell(searchFileResults[index]);
      },
    );
  }

  Widget createCell(Message model) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          FilePreview.path,
          arguments: {
            'file': model.fileUrl,
            'name': model.content,
            'size': model.duration,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.sizeOf(context).width - 42,
        color: myColors.white,
        child: Column(
          children: [
            Row(
              children: [
                AppNetworkImage(
                  model.senderUser?.avatar ?? '',
                  avatar: true,
                  width: 30,
                  height: 30,
                  fit: BoxFit.fitHeight,
                  borderRadius: BorderRadius.circular(15),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(model.senderUser?.nickname ?? ''),
                Expanded(child: Container()),
                Text(
                  time2formatDate(toStr(model.createTime)),
                  style: TextStyle(color: myColors.textGrey),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Image.asset(
                  assetPath('images/sp_wenjian.png'),
                  fit: BoxFit.fitWidth,
                  width: 50,
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.content ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(b2size(toDouble(model.duration ?? 0))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //搜索文件数据
  Future<void> requestFileData() async {
    searchFileResults = await MessageUtil.searchChannelMessage(
      pairId,
      '',
      type: GMessageType.FILE,
    );
    if (!mounted) return;
    setState(() {});
  }
}
