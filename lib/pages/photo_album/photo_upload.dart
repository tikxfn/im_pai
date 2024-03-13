import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/pages/photo_album/album_list.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/video_player.dart';
import 'package:unionchat/widgets/video_player_win.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';

class PhotoUpload extends StatefulWidget {
  const PhotoUpload({super.key});

  static const String path = 'photo/upload';

  @override
  State<StatefulWidget> createState() {
    return _PhotoUploadState();
  }
}

class _PhotoUploadState extends State<PhotoUpload> {
  String albumId = '';
  String albumName = '';
  bool isAll = false;

  //是否开始拖拽
  bool isDragNow = false;

  //是否将要删除
  bool isWillRemove = false;

  //app已选择图片列表
  List<AssetEntity> selectedData = [];

  //pc已选择图片列表
  List<FileModel> imagedData = [];

  List<String> videoType = ['avi', 'mp4'];
  List<String> imageType = ['bmp', 'gif', 'jpg', 'jpeg', 'png'];

  //选择图片
  selectImages() async {
    imagedData = [];
    AppStateNotifier().enablePinDialog = false;
    List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 200,
        selectedAssets: selectedData,
      ),
    );
    AppStateNotifier().enablePinDialog = true;
    if (result == null) {
      return;
    }
    selectedData = result;
    for (var v in selectedData) {
      File? file = await v.originFile;
      imagedData.add(FileModel(file: file!, type: v.type));
    }
    if (mounted) {
      setState(() {});
    }
  }

  //pc选择图片
  pcPickerImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    for (var v in result.files) {
      if (!imageType.contains(v.extension) &&
          !videoType.contains(v.extension)) {
        continue;
      }
      AssetType dataType = AssetType.image;
      if (videoType.contains(v.extension)) {
        dataType = AssetType.video;
      }
      imagedData.add(FileModel(
        file: File(v.path!),
        type: dataType,
      ));
    }
    logger.i(imagedData);
    if (mounted) {
      setState(() {});
    }
  }

  //上传
  release() async {
    if (albumId.isEmpty) {
      tipError('请选择相册'.tr());
      return;
    }
    loading();
    List<V1AlbumUploadParams> data = [];
    for (var v in imagedData) {
      final urls = await UploadFile(
        providers: [
          FileProvider.fromFile(
            v.file,
            v.type == AssetType.image
                ? V1FileUploadType.ALBUM_IMAGE
                : V1FileUploadType.ALBUM_VIDEO,
          ),
        ],
      ).aliOSSUpload();
      if (urls[0] != null && urls[0]!.isNotEmpty) {
        data.add(
          V1AlbumUploadParams(
              type: v.type == AssetType.image
                  ? GAlbumContentType.PHOTO
                  : GAlbumContentType.VIDEO,
              url: urls[0].toString()),
        );
      }
    }
    final api = AlbumApi(apiClient());
    try {
      await api.albumUpload(
        V1AlbumUploadArgs(
          albumId: albumId,
          list: data,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //获取当前图片的index
  getCurrentMediaIndex(List<String> list, String url) {
    for (var i = 0; i < list.length; i++) {
      if (list[i] == url) return i;
    }
  }

  //预览图片
  goImage(url) async {
    List<File> imgData1 = [];
    for (var v in imagedData) {
      if (v.type == AssetType.image) {
        imgData1.add(v.file);
      }
    }
    List<String> mediaList = imgData1.map((e) => e.path).toList();
    int index = getCurrentMediaIndex(mediaList, url);
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: imgData1.map((e) => e.path).toList(),
          index: index,
          showSave: false,
        ),
      ),
    );
  }

//预览视频
  goVideo(String url) {
    if (platformPhone) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return AppPlayVideo(
              url: url,
              showSave: false,
            );
          },
        ),
      );
    } else if (Platform.isWindows) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return WinPlayVideo(
              url: url,
            );
          },
        ),
      );
    } else {
      tip('该平台暂不支持'.tr());
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
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('传相册'.tr()),
        actions: [
          TextButton(
            onPressed: release,
            child: Text(
              '上传'.tr(),
              style: TextStyle(
                color: myColors.blueTitle,
              ),
            ),
          ),
        ],
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                Container(
                  color: myColors.white,
                  child: MenuUl(
                    marginTop: 0,
                    children: [
                      MenuItemData(
                        onTap: () async {
                          var result = await Navigator.pushNamed(
                              context, AlbumList.path,
                              arguments: {
                                'albumId': albumId,
                              });
                          if (result == null) return;
                          GAlbumModel album = result as GAlbumModel;
                          albumName = album.name ?? '';
                          albumId = album.id ?? '';
                          if (mounted) setState(() {});
                        },
                        title: '上传到'.tr(),
                        needColor: myColors.isDark,
                        icon: assetPath('images/help/wodefabu.png'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                albumName,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //图片
                // appImages(selectedData),
                imagesContainer(imagedData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //图片盒子
  Widget imagesContainer(List<FileModel> imagedData) {
    var myColors = ThemeNotifier();
    Color tagColor = myColors.tagColor;

    double tabSize = MediaQuery.of(context).size.width;
    int rowNumber = 3;
    if (!platformPhone) {
      rowNumber = 8;
      tabSize = tabSize - 350;
    }
    double size = (tabSize - 80 - 10 * (rowNumber - 1)) / rowNumber;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: tagColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final asset in imagedData) _imagesBox(asset, size), //图片项
              _addButton(size), //添加按钮
            ],
          ),
        ],
      ),
    );
  }

//图片项
  Widget _imagesBox(FileModel asset, double size) {
    return Draggable<FileModel>(
      //此可拖动对象将拖放的数据
      data: asset,
      //当可拖动对象开始被拖动时
      onDragStarted: () {
        setState(() {
          isDragNow = true;
        });
      },
      //当可拖动对象被放下时
      onDragEnd: (details) {
        setState(() {
          isDragNow = false;
          // isWillOrder = false;
        });
      },
      //当draggable 被放置并被[DragTarget]接受时调用
      onDragCompleted: () {
        // isWillRemove = true;
      },
      //当draggable 被放置但未被[DragTarget]接受时调用
      onDraggableCanceled: (velocity, offset) {
        isDragNow = false;
        // isWillOrder = false;
      },
      //拖动进行显示在指针下方的小部件
      feedback: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (asset.type == AssetType.image)
              Image.file(
                asset.file,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            if (asset.type == AssetType.video && platformPhone)
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: AppVideo(
                  url: asset.file.path,
                  playSize: 0.3 * size,
                  isMask: true,
                ),
              ),
            if (asset.type == AssetType.video && !platformPhone)
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: AppVideoWin(
                  url: asset.file.path,
                  autoPlay: false,
                  showContorll: false,
                ),
              ),
            // if (asset.type == AssetType.video)
            //   Positioned(
            //     child: Image.asset(
            //       assetPath('images/play2.png'),
            //       width: 30,
            //     ),
            //   )
          ],
        ),
      ),
      //当拖动时原位置显示的小组件
      childWhenDragging: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Opacity(
          opacity: 0.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (asset.type == AssetType.image)
                Image.file(
                  asset.file,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              if (asset.type == AssetType.video && platformPhone)
                Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  child: AppVideo(
                    url: asset.file.path,
                    playSize: 0.3 * size,
                    isMask: true,
                  ),
                ),
              if (asset.type == AssetType.video && !platformPhone)
                Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  child: AppVideoWin(
                    url: asset.file.path,
                    autoPlay: false,
                    showContorll: false,
                  ),
                ),
              // if (asset.type == AssetType.video)
              //   Positioned(
              //     child: Image.asset(
              //       assetPath('images/play2.png'),
              //       width: 30,
              //     ),
              //   )
            ],
          ),
        ),
      ),
      //子组件
      child: DragTarget<FileModel>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () async {
                if (asset.type == AssetType.image) goImage(asset.file.path);
                if (asset.type == AssetType.video) goVideo(asset.file.path);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (asset.type == AssetType.image)
                    Image.file(
                      asset.file,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  if (asset.type == AssetType.video && platformPhone)
                    Container(
                      width: size,
                      height: size,
                      alignment: Alignment.center,
                      child: AppVideo(
                        url: asset.file.path,
                        playSize: 0.3 * size,
                        isMask: true,
                      ),
                    ),
                  if (asset.type == AssetType.video && !platformPhone)
                    Container(
                      width: size,
                      height: size,
                      alignment: Alignment.center,
                      child: AppVideoWin(
                        url: asset.file.path,
                        autoPlay: false,
                        showContorll: false,
                      ),
                    ),
                  // if (asset.type == AssetType.video)
                  //   Positioned(
                  //     child: Image.asset(
                  //       assetPath('images/play2.png'),
                  //       width: 30,
                  //     ),
                  //   ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final int index = imagedData.indexOf(asset);
                        imagedData.removeAt(index);
                        if (platformPhone) {
                          selectedData.removeAt(index);
                        }
                        setState(() {});
                      },
                      child: Image.asset(
                        assetPath('images/btn_guanbi.png'),
                        width: 15,
                        height: 15,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        onAccept: (data) {
          //从队列中删除拖拽对象，
          final int index = imagedData.indexOf(data);
          imagedData.removeAt(index);
          //将拖拽对象插入到目标对象之前
          final int targetIndex = imagedData.indexOf(asset);
          imagedData.insert(targetIndex, data);
          setState(() {});
        },
      ),
    );
  }

//添加按钮
  GestureDetector _addButton(double size) {
    var myColors = ThemeNotifier();
    Color inputColor = myColors.chatInputColor;
    return GestureDetector(
      onTap: () {
        if (platformPhone) {
          selectImages();
        } else if (Platform.isWindows || Platform.isMacOS) {
          pcPickerImage();
        } else {
          tip('该平台暂不支持'.tr());
        }
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: inputColor,
        ),
        child: Image.asset(
          assetPath('images/help/add_image.png'),
          height: 100,
          width: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

//聊天列表数据modal
class FileModel {
  final File file;
  final AssetType type;

  FileModel({
    required this.file,
    required this.type,
  });
}
