import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/photo_album/photo_home.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class AlbumEdit extends StatefulWidget {
  const AlbumEdit({super.key});

  static const path = 'photo/album_edit';

  @override
  State<StatefulWidget> createState() {
    return _AlbumEditState();
  }
}

class _AlbumEditState extends State<AlbumEdit> {
  TextEditingController nameCtr = TextEditingController();
  String albumId = '';
  String albumName = '';
  // //已选择图片列表
  // List<AssetEntity> selectedData = [];

  // //选择图片
  // selectImages() async {
  //   AppStateNotifier().enablePinDialog = false;
  //   List<AssetEntity>? result = await AssetPicker.pickAssets(context,
  //       pickerConfig: AssetPickerConfig(
  //         requestType: RequestType.image,
  //         maxAssets: 1,
  //         selectedAssets: selectedData,
  //       ));
  //   AppStateNotifier().enablePinDialog = true;
  //   if (result == null) {
  //     return;
  //   }
  //   if (mounted) {
  //     setState(() {
  //       selectedData = result;
  //     });
  //   }
  // }

  //保存相册名
  save() async {
    if (nameCtr.text.isEmpty) {
      tipError('名称不能为空'.tr());
      return;
    }
    // for (var v in selectedData) {
    //   File? file = await v.file;
    //   List<String?> urls = await UploadFile(
    //     [file!.path.toString()],
    //     type: V1FileUploadType.ALBUM_IMAGE,
    //   ).upload();
    //   String url = urls[0].toString();
    // }
    final api = AlbumApi(apiClient());
    loading();
    try {
      var res = await api.albumEdit(
        V1AlbumEditArgs(
          id: albumId,
          name: nameCtr.text,
          // cover: url,
        ),
      );
      if (res == null) return;
      logger.i(res);
      if (mounted) {
        tip('修改成功');
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //删除相册
  delete() async {
    final api = AlbumApi(apiClient());
    loading();
    try {
      await api.albumDel(
        GIdArgs(
          id: albumId,
        ),
      );
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName(PhotoHome.path));
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['albumId'] != null) albumId = args['albumId'];
      if (args['albumName'] != null) albumName = args['albumName'];
      nameCtr.text = albumName;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑相册'.tr()),
        actions: [
          TextButton(
            onPressed: save,
            child: Text(
              '完成'.tr(),
              style: TextStyle(color: myColors.primary),
            ),
          ),
        ],
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Container(
                  //   alignment: Alignment.center,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: const BoxDecoration(
                  //     color: myColors.white,
                  //   ),
                  //   child: GestureDetector(
                  //     onTap: () {},
                  //     child: Container(
                  //       width: 100,
                  //       height: 100,
                  //       decoration: const BoxDecoration(
                  //         color: myColors.grey,
                  //       ),
                  //       child: const Icon(
                  //         Icons.camera_alt_outlined,
                  //         color: myColors.lineGrey,
                  //         size: 24,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    color: myColors.greyBg,
                    child: AppTextarea(
                      controller: nameCtr,
                      maxLength: null,
                      minLines: 1,
                      radius: 10,
                    ),
                  ),
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
                        theme: AppButtonTheme.red,
                        onTap: delete,
                        fontSize: 14,
                        height: 45,
                        radius: 50,
                        title: '删除相册'.tr(),
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
