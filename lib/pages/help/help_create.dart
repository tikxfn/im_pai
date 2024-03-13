import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/pages/application/province_list.dart';
import 'package:unionchat/pages/help/circle/my/circle_my_all.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/photo_preview.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';

class HelpCreate extends StatefulWidget {
  const HelpCreate({super.key});

  static const String path = 'help/create';

  @override
  State<StatefulWidget> createState() {
    return _HelpCreateState();
  }
}

class _HelpCreateState extends State<HelpCreate> {
  bool waitStatus = false; //发送等待
  //圈子id
  String circleId = '';
  //是否公开
  bool isOpen = false;
  //圈子名字
  String circleName = '选择圈子';
  //当前城市名
  String city = '请选择城市';
  //城市code
  String areaCode = '0';
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

  TextEditingController controller = TextEditingController();

  //获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      if (mounted) {
        setState(() {
          circleName = res.name!;
          isOpen = res.circleType == GCircleType.PUBLIC;
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

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
    // List<XFile> images = [];
    // final ImagePicker picker = ImagePicker();
    // AppStateNotifier().enablePinDialog = false;
    // if (imageType == GArticleType.IMAGE) {
    //   images = await picker.pickMultiImage();
    // } else {
    //   XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    //   if (file == null) return;
    //   images.add(file);
    // }
    // AppStateNotifier().enablePinDialog = true;
    // if (images.isEmpty) return;
    // if (selectedAssets.length + images.length > maxAssets) {
    //   final List<XFile> imagesData = [];
    //   for (var i = 0; i < maxAssets - selectedAssets.length; i++) {
    //     imagesData.add(images[i]);
    //   }
    //   selectedAssets.addAll(imagesData);
    // } else {
    //   selectedAssets.addAll(images);
    // }
    // if (mounted) setState(() {});
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
    if (controller.text.isEmpty && selectedData.isEmpty) {
      tipError('内容不能为空'.tr());
      return;
    }
    for (var v in Global.banSpeakList) {
      if (controller.text.contains(v)) {
        tipError('敏感词汇无法发送');
        return;
      }
    }
    if (circleId == '') {
      tipError('请选择发布的圈子'.tr());
      return;
    }
    if (!isOpen && areaCode == '0') {
      tipError('请选择城市'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});
    loading();
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
              V1FileUploadType.CIRCLE_IMAGE,
            ),
        ],
      ).aliOSSUpload();
    }
    if (imageType == GArticleType.VIDEO) {
      urls = await UploadFile(
        providers: [
          FileProvider.fromFilepath(
            images[0],
            V1FileUploadType.CIRCLE_VIDEO,
          ),
        ],
      ).aliOSSUpload();
    }
    List<String> images2 = [];
    if (urls.isNotEmpty) {
      images2 = urls.map((e) => e.toString()).toList();
    }
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleAddCircleArticle(
        V1AddCircleArticleArgs(
          id: AddCircleArticleArgsId(id: circleId),
          content: V1AddCircleArticleArgsValue(value: controller.text),
          images: images2,
          articleType:
              V1AddCircleArticleArgsArticleType(articleType: imageType),
          areaCode: AddCircleArticleArgsAreaCode(areaCode: areaCode),
        ),
      );
      if (res == null) return;
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['circleId'] != null) circleId = args['circleId'];
    logger.i(circleId);
    if (circleId.isNotEmpty) {
      getDetail();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('发布圈子'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    //文本
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: myColors.chatInputColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextarea(
                              controller: controller,
                              minLines: 8,
                              radius: 15,
                              hintText: '请输入详细内容'.tr(),
                              maxLength: null,
                            ),
                            //图片
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: appImages(selectedData),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MenuUl(
                      marginTop: 0,
                      children: [
                        //选择圈子
                        MenuItemData(
                          icon: assetPath('images/help/select_circle.png'),
                          title: circleName,
                          needColor: myColors.isDark,
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            var result = await Navigator.pushNamed(
                                context, CircleMyAll.path);
                            setState(() {
                              if (result == null) return;
                              GCircleModel circleData = result as GCircleModel;
                              circleId = circleData.id ?? '';
                              circleName = circleData.name ?? '';
                              getDetail();
                              logger.i(circleId);
                            });
                          },
                        ),
                        //选择城市
                        if (!isOpen)
                          MenuItemData(
                            icon: assetPath('images/help/select_city.png'),
                            title: city,
                            needColor: myColors.isDark,
                            onTap: () async {
                              var result = await Navigator.pushNamed(
                                  context, ProvinceList.path,
                                  arguments: {'city': city});
                              if (result == null) return;
                              setState(() {
                                Map citydata = result as Map;
                                city = citydata['city_name'];
                                areaCode = citydata['city_code'];
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              BottomButton(
                title: '提交'.tr(),
                onTap: () {
                  release();
                },
                waiting: waitStatus,
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
    Color bgColor = myColors.chatInputColor;
    double size = ((MediaQuery.of(context).size.width - 70) ~/ 3).toDouble();
    return Container(
      margin: const EdgeInsets.only(top: 10),
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
                    // ignore: use_build_context_synchronously
                    ? goVideo(file!.path)
                    // ignore: use_build_context_synchronously
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
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (selectedData.isEmpty) {
          openSheetMenu(
            context,
            list: ['相册'.tr(), '视频'.tr()],
            onTap: (i) {
              imageType = i == 0 ? GArticleType.IMAGE : GArticleType.VIDEO;
              if (imageType == GArticleType.VIDEO) {
                maxAssets = 1;
              }
              if (imageType == GArticleType.IMAGE) {
                maxAssets = 9;
              }
              selectImages();
            },
          );
        }
        if (selectedData.isNotEmpty) selectImages();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Opacity(
          //   opacity: 0.2,
          //   child: Container(
          //     height: size,
          //     width: size,
          //     decoration: BoxDecoration(
          //       color: myColors.shade,
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //   ),
          // ),
          Image.asset(
            assetPath('images/help/add_image.png'),
            height: size,
            width: size,
            fit: BoxFit.contain,
          ),
          Positioned(
              right: 9,
              bottom: 9,
              child: Text(
                '${selectedData.length} / $maxAssets 张',
                style: TextStyle(
                  color: myColors.textGrey,
                  fontSize: 12,
                ),
              )),
        ],
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
