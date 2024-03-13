import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/photo_album/photo_upload.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import '../../widgets/keyboard_blur.dart';

class AlbumAdd extends StatefulWidget {
  const AlbumAdd({super.key});

  static const String path = 'photo/album_add';

  @override
  State<StatefulWidget> createState() {
    return _AlbumAddState();
  }
}

class _AlbumAddState extends State<AlbumAdd> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _describe = TextEditingController();

  create() async {
    if (_name.text.isEmpty) {
      tipError('名称不能为空'.tr());
      return;
    }
    final api = AlbumApi(apiClient());
    loading();
    try {
      final res = await api.albumEdit(V1AlbumEditArgs(
        name: _name.text,
        describe: _describe.text,
      ));
      if (!mounted || res == null) return;
      String id = res.id!;
      String name = res.name!;

      if (mounted) {
        Navigator.pushReplacementNamed(context, PhotoUpload.path, arguments: {
          'albumName': name,
          'albumId': id,
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _describe.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('新建相册'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  AppTextarea(
                    hintText: '添加相册名称'.tr(),
                    controller: _name,
                    maxLength: null,
                    minLines: 1,
                    radius: 10,
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // AppTextarea(
                  //   controller: _describe,
                  //   // color: myColors.greyBg,
                  //   // minLines: 20,
                  //   maxLines: 10,
                  //   maxLength: 200,
                  //   hintText: '相册描述'.tr(),
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppButtonBottomBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: CircleButton(
                        theme: AppButtonTheme.blue,
                        onTap: create,
                        fontSize: 16,
                        height: 45,
                        radius: 50,
                        title: '完成创建'.tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
