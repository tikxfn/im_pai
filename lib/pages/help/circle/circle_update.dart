import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleUpdate extends StatefulWidget {
  const CircleUpdate({super.key});

  static const path = 'help/circle_update';

  @override
  State<StatefulWidget> createState() {
    return _CircleUpdateState();
  }
}

class _CircleUpdateState extends State<CircleUpdate> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String avatar = '';
  double avatarSize = 150;
  GCircleType circleType = GCircleType.NIL;
  bool isPrivate = false;
  String circleId = ''; //圈子id
  GCircleModel? detail;

  //选择头像
  pickerAvatar() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return;
    photoCrop(file.path);
  }

  //图片裁剪
  photoCrop(String path) async {
    logger.d(path);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      // aspectRatioPresets: [],
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '图片裁剪'.tr(),
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: '图片裁剪'.tr(),
          doneButtonTitle: '完成'.tr(),
          cancelButtonTitle: '取消'.tr(),
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(context: context),
      ],
    );
    if (croppedFile == null) return;
    final urls = await UploadFile(
      providers: [
        FileProvider.fromFilepath(
          croppedFile.path,
          V1FileUploadType.USER_AVATAR,
        ),
      ],
    ).aliOSSUpload();
    avatar = urls.firstOrNull ?? '';
    setState(() {});
  }

  //更新圈子
  save() async {
    if (controller1.text.isEmpty) {
      tipError('名称不能为空'.tr());
      return;
    }
    if (avatar.isEmpty) {
      tipError('请选择头像'.tr());
      return;
    }
    if (circleType != GCircleType.GUARANTEE && circleType != GCircleType.NIL) {
      circleType = isPrivate ? GCircleType.PRIVATE : GCircleType.PUBLIC;
    }
    final api = CircleApi(apiClient());
    loading();
    try {
      final res = await api.circleUpdateCircle(V1CircleUpdateArgs(
          id: circleId,
          circleType: V1CircleUpdateArgsCircleType(circleType: circleType),
          name: V1CircleUpdateArgsValue(value: controller1.text),
          describe: V1CircleUpdateArgsValue(value: controller2.text),
          image: V1CircleUpdateArgsValue(value: avatar)));
      if (mounted) Navigator.of(context).pop();
      logger.i(res);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

//获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    //获取群信息
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      setState(() {
        detail = res;
        avatar = detail!.image!;
        controller1.text = detail!.name!;
        controller2.text = detail!.describe!;
        circleType = detail!.circleType ?? GCircleType.NIL;
        if (detail!.circleType == GCircleType.PRIVATE) isPrivate = true;
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['circleId'] != null) circleId = args['circleId'];
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('修改圈子'.tr()),
        // actions: [
        //   TextButton(
        //     onPressed: save,
        //     child: Text('完成'.tr()),
        //   ),
        // ],
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    //圈子图片
                    Row(
                      children: [
                        Expanded(
                          flex: 0,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            child: GestureDetector(
                              onTap: pickerAvatar,
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: myColors.grey,
                                  // border: Border.all(
                                  //   color: myColors .lineGrey,
                                  //   width: 1,
                                  // ),
                                  borderRadius: BorderRadius.circular(75),
                                ),
                                child: avatar.isNotEmpty
                                    ? AppNetworkImage(
                                        avatar,
                                        avatar: true,
                                        width: avatarSize,
                                        height: avatarSize,
                                        imageSpecification:
                                            ImageSpecification.w230,
                                        borderRadius: BorderRadius.circular(
                                            avatarSize / 2),
                                      )
                                    : Icon(
                                        Icons.camera_alt_outlined,
                                        color: myColors.lineGrey,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: AppTextarea(
                              hintText: '输入圈子名称'.tr(),
                              controller: controller1,
                              radius: 15,
                              maxLength: null,
                              minLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppTextarea(
                        controller: controller2,
                        minLines: 20,
                        maxLines: 20,
                        radius: 15,
                        maxLength: null,
                        hintText: '圈子内容描述...........'.tr(),
                      ),
                    ),
                    if (circleType != GCircleType.GUARANTEE &&
                        circleType != GCircleType.NIL)
                      Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '是否私密'.tr(),
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                              AppSwitch(
                                value: isPrivate,
                                onChanged: (val) {
                                  setState(() {
                                    isPrivate = val;
                                  });
                                },
                              ),
                            ],
                          )),
                  ],
                ),
              ),
              BottomButton(
                title: '完成'.tr(),
                onTap: save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
