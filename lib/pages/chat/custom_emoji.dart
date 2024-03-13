import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/file_save.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/media_picker.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/notifier/app_state_notifier.dart';
import 'package:unionchat/notifier/custom_emoji_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/image_editor_pro.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';

import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:vibration/vibration.dart';

class CustomEmoji extends StatefulWidget {
  const CustomEmoji({super.key});

  static const String path = 'chat/custom_emoji';

  @override
  State<CustomEmoji> createState() => _CustomEmojiState();
}

class _CustomEmojiState extends State<CustomEmoji> {
  ImagePicker picker = ImagePicker();
  bool showDel = false;
  int limit = 100000;
  List<String> activeIds = [];
  List<GUserExpressionModel> imageData = [];

  // //获取列表
  // Future<int> getList({bool init = false}) async {
  //   final api = UserExpressionApi(apiClient());
  //   try {
  //     final res = await api.userExpressionList(V1ListUserExpressionArgs(
  //       pager: GPagination(
  //         limit: limit.toString(),
  //         offset: init ? '0' : imageData.length.toString(),
  //       ),
  //     ));
  //     if (res == null) return 0;
  //     List<GUserExpressionModel> newData = res.list.toList();

  //     if (!mounted) return 0;
  //     if (init) {
  //       imageData = newData;
  //     } else {
  //       imageData.addAll(newData);
  //     }
  //     if (mounted) setState(() {});
  //     return res.list.length;
  //   } on ApiException catch (e) {
  //     onError(e);
  //     return limit;
  //   } finally {}
  // }

  //获取当前图片的index
  getCurrentMediaIndex(List<String> list, String url) {
    for (var i = 0; i < list.length; i++) {
      if (list[i] == url) return i;
    }
  }

  //预览图片
  goImage(url) async {
    List<String> mediaList = imageData.map((e) => e.link.toString()).toList();
    int index = getCurrentMediaIndex(mediaList, url);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: mediaList,
          index: index,
          showSave: false,
        ),
      ),
    );
  }

  //选择图片
  pickerImage() async {
    if (platformPhone) {
      openSheetMenu(context, list: [
        '相册'.tr(),
        '拍照'.tr(),
      ], onTap: (i) {
        phonePickerImage(
          i == 1 ? ImageSource.camera : ImageSource.gallery,
        );
      });
    } else if (Platform.isWindows || Platform.isMacOS) {
      pcPickerImage();
    } else {
      tip('该平台暂不支持'.tr());
    }
  }

  //手机选择图片
  phonePickerImage(ImageSource source) async {
    List<String> path = [];
    AppStateNotifier().enablePinDialog = false;
    if (source == ImageSource.camera) {
      XFile? file = await picker.pickImage(source: source);
      if (file != null) path.add(file.path);
    } else if (source == ImageSource.gallery) {
      var files = await MediaPicker.image(
        context,
        maxLength: 1,
        edit: true,
      );
      path = files.map((e) => e.path).toList();
    }
    AppStateNotifier().enablePinDialog = true;
    if (path.isEmpty) return;
    if (path.isNotEmpty) {
      phoneEditImage(path[0]);
    }
  }

  // 手机编辑图片
  Future<void> phoneEditImage(String path) async {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => ImageEditorPro(
          File(path).readAsBytesSync(),
        ),
      ),
    ).then((res) async {
      if (res == null) return;
      loading();
      var imagePath = await FileSave().pcTempSaveImage(res['result']);
      loadClose();
      uploadImage(imagePath);
    });
    return;
  }

  //pc选择图片
  pcPickerImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null ||
        result.files.isNotEmpty ||
        result.files[0].path == '') {
      return;
    }

    uploadImage(result.files[0].path!);
  }

  //上传图片
  uploadImage(String url) async {
    double sort = 0;
    if (imageData.isNotEmpty) {
      if (imageData[0].sort != null &&
          toDouble(imageData[0].sort!) < imageData.length + 1) {
        sort = imageData.length + 1;
      } else {
        sort = toDouble(imageData[0].sort) + 1;
      }
    } else {
      sort = imageData.length + 1;
    }
    logger.i(sort);
    final urls = await UploadFile(
      providers: [
        FileProvider.fromFilepath(url, V1FileUploadType.CHAT_IMAGE),
      ],
    ).aliOSSUpload();
    loading();
    final api = UserExpressionApi(apiClient());
    try {
      await api.userExpressionUpdate(V1UpdateUserExpressionArgs(
        link: V1UpdateUserExpressionArgsValue(value: urls.firstOrNull ?? ''),
        sort: V1UpdateUserExpressionArgsSort(value: sort),
      ));
      if (mounted) CustomEmojiNotifier().refresh(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //选择图片
  onChoose(String id) {
    if (activeIds.contains(id)) {
      activeIds.remove(id);
    } else {
      activeIds.add(id);
    }
    setState(() {});
  }

  //删除图片
  deleteImage() async {
    loading();
    final api = UserExpressionApi(apiClient());
    try {
      await api.userExpressionDel(GIdsArgs(
        ids: activeIds,
      ));
      if (mounted) CustomEmojiNotifier().removeById(activeIds);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //移动图片
  moveImage(
    String id, {
    int newIndex = 0,
    int oldIndex = 0,
  }) async {
    logger.i('$newIndex,$oldIndex');
    double sort = 0;
    if (imageData.isNotEmpty) {
      if (imageData[0].sort == null) {
        return;
      }
      if (newIndex == 0) {
        if (toDouble(imageData[0].sort!) < imageData.length + 1) {
          sort = imageData.length + 1;
        } else {
          sort = toDouble(imageData[newIndex].sort) + 1;
        }
      } else if (newIndex == imageData.length - 1) {
        sort = toDouble(imageData[newIndex].sort) - 1;
      } else {
        double insertLeft = toDouble(imageData[newIndex - 1].sort!);
        double insertRight = toDouble(imageData[newIndex].sort!);
        sort = (toDouble(insertLeft) + toDouble(insertRight)) / 2;
      }
    }
    logger.i(sort);
    if (sort == 0) return;
    loading();
    final api = UserExpressionApi(apiClient());
    try {
      await api.userExpressionUpdate(
        V1UpdateUserExpressionArgs(
          id: id,
          sort: V1UpdateUserExpressionArgsSort(value: sort),
        ),
      );
      if (mounted) CustomEmojiNotifier().move(newIndex, oldIndex);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    final emojiNotifier = context.watch<CustomEmojiNotifier>();
    imageData = emojiNotifier.imageData;
    double size = ((MediaQuery.of(context).size.width - 30) ~/ 5).toDouble();
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加单个表情'),
        actions: [
          TextButton(
            onPressed: () {
              showDel = !showDel;
              setState(() {});
            },
            child: Text(
              showDel ? '取消'.tr() : '编辑'.tr(),
              style: TextStyle(
                color: myColors.blueTitle,
              ),
            ),
          ),
        ],
      ),
      body: ThemeBody(
        child: Container(
          padding: const EdgeInsets.all(5),
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: PagerBox(
                  limit: limit,
                  onInit: () async {
                    if (!mounted) return 0;
                    return imageData.length > limit ? limit : imageData.length;
                  },
                  onPullDown: () async {
                    //下拉刷新

                    return await CustomEmojiNotifier().refresh(init: true);
                  },
                  onPullUp: () async {
                    //上拉加载

                    return await CustomEmojiNotifier().refresh();
                  },
                  children: [
                    //图片startVibration
                    ReorderableWrap(
                        spacing: 5,
                        runSpacing: 5,
                        onReorderStarted: (index) {
                          Vibration.vibrate(duration: 50);
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            var item = imageData[oldIndex];

                            moveImage(item.id!,
                                newIndex: newIndex, oldIndex: oldIndex);
                          });
                        },
                        header: [
                          _addCustomButton(size),
                        ],
                        children: [
                          for (var v in imageData) _customBox(v, size), //图片项
                        ]),
                  ],
                ),
              ),
              //底部管理按钮
              if (showDel) _bottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  //自定义customEmoji表情添加按钮
  Widget _addCustomButton(double size) {
    return GestureDetector(
      onTap: () {
        pickerImage();
      },
      child: Image.asset(
        assetPath('images/talk/add_image.png'),
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }

  //自定义customEmoji表情box
  Widget _customBox(GUserExpressionModel v, double size) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: showDel
            ? () async {
                onChoose(v.id!);
              }
            : () async {
                goImage(v.link);
              },
        child: Stack(
          children: [
            AppNetworkImage(
              v.link!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
            if (showDel)
              Positioned(
                right: 2,
                top: 2,
                child: AppCheckbox(
                  value: activeIds.contains(v.id),
                  size: size / 3,
                ),
              )
          ],
        ),
      ),
    );
  }

  //底部按钮
  _bottomWidget() {
    var myColors = ThemeNotifier();
    return Container(
      color: myColors.tagColor,
      child: SafeArea(
        child: Container(
          // height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleButton(
                onTap: activeIds.isNotEmpty
                    ? () {
                        deleteImage();
                      }
                    : null,
                width: 80,
                height: 41,
                radius: 8,
                fontSize: 14,
                theme: activeIds.isNotEmpty
                    ? AppButtonTheme.red
                    : AppButtonTheme.grey,
                title: '删除'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
