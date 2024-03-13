import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';

class Complain extends StatefulWidget {
  const Complain({super.key});

  static const String path = 'mine/complain';

  @override
  State<StatefulWidget> createState() {
    return _ComplainState();
  }
}

class _ComplainState extends State<Complain> {
  //图片最大选取数量
  int maxAssets = 9;
  //资源类型
  GArticleType imageType = GArticleType.IMAGE;
  //是否开始拖拽
  bool isDragNow = false;
  //是否将要删除
  bool isWillRemove = false;
  //已选择图片列表
  List<AssetEntity> selectedData = [];
  TextEditingController titleCtr = TextEditingController();
  TextEditingController controller = TextEditingController();

  //选择图片
  selectImages() async {
    RequestType requestType;
    if (imageType == GArticleType.IMAGE) {
      requestType = RequestType.image;
    } else {
      requestType = RequestType.video;
    }
    AppStateNotifier().enablePinDialog = false;
    List<AssetEntity>? result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          selectedAssets: selectedData,
          maxAssets: maxAssets,
          requestType: requestType,
        ));
    AppStateNotifier().enablePinDialog = true;
    if (result == null) {
      return;
    }
    if (mounted) {
      setState(() {
        selectedData = result;
      });
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
    List<File> imageData = [];
    for (var v in selectedData) {
      File? file = await v.file;
      imageData.add(file!);
    }
    List<String> mediaList = imageData.map((e) => e.path).toList();
    int index = getCurrentMediaIndex(mediaList, url);
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(
          list: imageData.map((e) => e.path).toList(),
          index: index,
          showSave: false,
        ),
      ),
    );
  }

//预览视频
  goVideo(String url) {
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
  }

  //发布
  release() async {
    if (controller.text.isEmpty || titleCtr.text.isEmpty) {
      tipError('内容不能为空'.tr());
      return;
    }
    for (var v in Global.banSpeakList) {
      if (controller.text.contains(v)) {
        tipError('敏感词汇无法发送'.tr());
        return;
      }
    }
    List<File> imageData = [];
    for (var v in selectedData) {
      File? file = await v.originFile;
      imageData.add(file!);
    }
    List<String> images = imageData.map((e) => e.path.toString()).toList();
    List<String?> urls = [];
    if (imageType == GArticleType.IMAGE) {
      urls = await UploadFile(
        providers: [
          for (var i = 0; i < images.length; i++)
            FileProvider.fromFilepath(
              images[i],
              V1FileUploadType.CHAT_IMAGE,
            ),
        ],
      ).aliOSSUpload();
    }
    if (imageType == GArticleType.VIDEO) {
      urls = await UploadFile(
        providers: [
          FileProvider.fromFilepath(
            images[0],
            V1FileUploadType.CHAT_VIDEO,
          ),
        ],
      ).aliOSSUpload();
    }
    List<String> images2 = [];
    if (urls.isNotEmpty) {
      images2 = urls.map((e) => e.toString()).toList();
    }

    final api = ComplaintApi(apiClient());
    try {
      await api.complaintAdd(
        V1ComplaintAddArgs(
          title: titleCtr.text,
          description: controller.text,
          images: images2,
        ),
      );

      if (mounted) {
        tip('提交成功'.tr());
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void dispose() {
    super.dispose();
    titleCtr.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('投诉'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            margin: const EdgeInsets.only(right: 10, left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: myColors.vipBuySelectedBg,
                            ),
                          ),
                          Text(
                            '投诉标题'.tr(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppTextarea(
                        controller: titleCtr,
                        minLines: 1,
                        radius: 15,
                        hintText: '请输入投诉信息'.tr(),
                        maxLength: null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            margin: const EdgeInsets.only(right: 10, left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: myColors.vipBuySelectedBg,
                            ),
                          ),
                          Text(
                            '详细内容'.tr(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //文本
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppTextarea(
                        controller: controller,
                        minLines: 10,
                        radius: 15,
                        hintText: '请输入详细内容'.tr(),
                        maxLength: null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            margin: const EdgeInsets.only(right: 10, left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: myColors.vipBuySelectedBg,
                            ),
                          ),
                          Text(
                            '上传照片'.tr(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //图片
                    appImages(selectedData),
                  ],
                ),
              ),
              if (!isDragNow)
                BottomButton(
                  title: '提交'.tr(),
                  onTap: release,
                ),
            ],
          ),
        ),
      ),
      bottomSheet: isDragNow ? _buildRemoverBar() : null,
    );
  }

  //图片盒子

  Widget appImages(List<AssetEntity> selectedAssets) {
    var myColors = ThemeNotifier();
    Color bgColor = myColors.themeBackgroundColor;
    double size = (MediaQuery.of(context).size.width - 60) / 4;
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final asset in selectedAssets) _imagesBox(asset, size), //图片项
              if (selectedAssets.length < maxAssets) _addButton(size), //添加按钮
            ],
          ),
        ],
      ),
    );
  }

//图片项
  Widget _imagesBox(AssetEntity asset, double size) {
    return Draggable<AssetEntity>(
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
            AssetEntityImage(
              asset,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
            if (imageType == GArticleType.VIDEO)
              Positioned(
                child: Image.asset(
                  assetPath('images/play2.png'),
                  width: 20,
                ),
              )
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
              AssetEntityImage(
                asset,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
              if (imageType == GArticleType.VIDEO)
                Positioned(
                  child: Image.asset(
                    assetPath('images/play2.png'),
                    width: 20,
                  ),
                )
            ],
          ),
        ),
      ),
      //子组件
      child: DragTarget<AssetEntity>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () async {
                File? file = await asset.file;
                imageType == GArticleType.VIDEO
                    ? goVideo(file!.path)
                    : goImage(file!.path);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AssetEntityImage(
                    asset,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                  if (imageType == GArticleType.VIDEO)
                    Positioned(
                      child: Image.asset(
                        assetPath('images/play2.png'),
                        width: 30,
                      ),
                    )
                ],
              ),
            ),
          );
        },
        onAccept: (data) {
          //从队列中删除拖拽对象，
          final int index = selectedData.indexOf(data);
          selectedData.removeAt(index);
          //将拖拽对象插入到目标对象之前
          final int targetIndex = selectedData.indexOf(asset);
          selectedData.insert(targetIndex, data);
          setState(() {});
        },
      ),
    );
  }

//添加按钮
  GestureDetector _addButton(double size) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        // if (selectedData.isEmpty) {
        //   openSheetMenu(
        //     context,
        //     list: ['相册'.tr(), '视频'.tr()],
        //     onTap: (i) {
        //       imageType = i == 0 ? GArticleType.IMAGE : GArticleType.VIDEO;
        //       if (imageType == GArticleType.VIDEO) {
        //         maxAssets = 1;
        //       }
        //       if (imageType == GArticleType.IMAGE) {
        //         maxAssets = 9;
        //       }
        selectImages();
        //     },
        //   );
        // }
        // if (selectedData.isNotEmpty) selectImages();
      },
      child: Image.asset(
        assetPath('images/talk/add_image.png'),
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }

//删除Bar
  Widget _buildRemoverBar() {
    return DragTarget<AssetEntity>(
      //调用以构建小部件的内容
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 120,
          width: double.infinity,
          color: isWillRemove ? Colors.red[300] : Colors.red[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //图标
              Icon(
                Icons.delete,
                size: 32,
                color: isWillRemove ? Colors.white : Colors.white70,
              ),
              //文字
              Text(
                '拖拽到这删除'.tr(),
                style: TextStyle(
                    color: isWillRemove ? Colors.white : Colors.white70),
              )
            ],
          ),
        );
      },

      //调用以确定小部件是否有兴趣接收给定的 被拖到这个拖动目标上的数据片段
      onWillAccept: (data) {
        setState(() {
          isWillRemove = true;
        });
        return true;
      },
      //当一条可接收的数据被拖到这个拖动目标上时调用
      onAccept: (data) {
        selectedData.remove(data);
        isWillRemove = false;
        if (mounted) setState(() {});
      },
      //当被拖动到该目标上的给定数据离开时调用 目标
      onLeave: (data) {
        setState(() {
          isWillRemove = false;
        });
      },
    );
  }
}
