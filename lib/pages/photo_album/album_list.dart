import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class AlbumList extends StatefulWidget {
  const AlbumList({super.key});

  static const String path = 'photo/album_list';

  @override
  State<StatefulWidget> createState() {
    return AlbumListState();
  }
}

class AlbumListState extends State<AlbumList> {
  String albumId = '';
  List<GAlbumModel> albumData = [];

  //获取列表
  getList() async {
    final api = AlbumApi(apiClient());
    try {
      final res = await api.albumList({});
      if (res == null) return;
      List<GAlbumModel> newAlbumData = [];
      newAlbumData = res.list;
      logger.i(res.list);
      if (!mounted) return;
      albumData = newAlbumData;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['albumId'] != null) albumId = args['albumId'];
      if (mounted) getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传到'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            if (albumData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: albumData.map((e) {
                  return ChatItem(
                    onTap: () {
                      Navigator.pop(context, e);
                    },
                    titleSize: 15,
                    avatarSize: 44,
                    data: ChatItemData(
                      icons: [e.cover ?? ''],
                      title: e.name ?? '',
                    ),
                    hasSlidable: false,
                    end: e.id == albumId
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Image.asset(
                                  assetPath('images/yixuan.png'),
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          )
                        : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
