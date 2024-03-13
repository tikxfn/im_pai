import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class SearchImagePae extends StatefulWidget {
  const SearchImagePae({super.key});

  static const String path = 'SearchImagePae/path';

  @override
  State<SearchImagePae> createState() => _SearchImagePaeState();
}

class _SearchImagePaeState extends State<SearchImagePae> {
  List<Message> searchImageResults = [];
  String userId = '';
  String pairId = '';
  String roomId = '';
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      userId = args['id'] ?? '';
      pairId = args['pairId'] ?? '';
      roomId = args['roomId'] ?? '';
      requestImageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图片'.tr()),
      ),
      body: ThemeBody(
        child: createBody(),
      ),
    );
  }

  Widget createBody() {
    return GridView.count(
      padding: const EdgeInsets.all(10),
      scrollDirection: Axis.vertical,
      crossAxisSpacing: 3,
      crossAxisCount: 4,
      mainAxisSpacing: 3,
      childAspectRatio: 1.0,
      children: _getListData(),
    );
  }

  List<Widget> _getListData() {
    var tempList = _imageUrls.map((v) {
      return GestureDetector(
        onTap: () {
          int index = _imageUrls.indexOf(v);
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) {
                return PhotoPreview(
                  list: _imageUrls,
                  index: index,
                );
              },
            ),
          );
        },
        child: AppNetworkImage(
          v,
          imageSpecification: ImageSpecification.w120,
          fit: BoxFit.cover,
          // borderRadius: BorderRadius.circular(30),
        ),
      );
    });
    // ('124124','124214')
    return tempList.toList();
  }

  //搜索图片数据
  Future<void> requestImageData() async {
    searchImageResults = await MessageUtil.searchChannelMessage(
      pairId,
      '',
      type: GMessageType.IMAGE,
    );
    List<String> list = [];
    for (var v in searchImageResults) {
      if (v.content == null || v.content!.isEmpty) continue;
      list.addAll(v.content!.split(','));
    }
    _imageUrls = list;

    setState(() {});
  }
}
