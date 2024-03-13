import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/image_editor.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/app_state_notifier.dart';
import '../../../notifier/theme_notifier.dart';

class CircleCreate extends StatefulWidget {
  const CircleCreate({super.key});

  static const path = 'help/circle_create';

  @override
  State<StatefulWidget> createState() {
    return _CircleCreateState();
  }
}

class _CircleCreateState extends State<CircleCreate> {
  bool waitStatus = false; //发送等待
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String avatar = '';
  double avatarSize = 150;
  GCircleType circleType = GCircleType.PRIVATE; //默认私有
  String type = '私密圈'.tr();

  List<String> typeSelect = [
    '私密圈'.tr(),
    '公开圈'.tr(),
    '保圈'.tr(),
  ];
  List<GCircleType> typeDate = [
    GCircleType.PRIVATE,
    GCircleType.PUBLIC,
    GCircleType.GUARANTEE,
  ];

  //选择头像
  pickerAvatar() async {
    ImagePicker picker = ImagePicker();
    AppStateNotifier().enablePinDialog = false;
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    AppStateNotifier().enablePinDialog = true;
    if (file == null) return;
    photoCrop(file.path);
  }

  //图片上传
  photoUpload(Uint8List? result) async {
    if (result == null) return;
    final urls = await UploadFile(
      providers: [
        FileProvider.fromBytes(result, V1FileUploadType.USER_AVATAR, 'png'),
      ],
    ).aliOSSUpload();
    setState(() {
      avatar = urls.firstOrNull ?? '';
    });
  }

  //图片裁剪
  photoCrop(String path) async {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => AppImageEditor(
          File(path),
          avatar: true,
        ),
      ),
    ).then((res) {
      if (res == null) return;
      photoUpload(res['result']);
    });
  }

  //设置入圈所需vip
  _chooseCircleType() {
    var index = 0;
    openSelect(
      context,
      index: index,
      list: typeSelect,
      onEnter: (i) async {
        circleType = typeDate[i];
        type = typeSelect[i];
        setState(() {});
      },
    );
  }

  //创建圈子
  save() async {
    if (controller1.text.isEmpty) {
      tipError('名称不能为空'.tr());
      return;
    }
    for (var v in Global.banSpeakList) {
      if (controller1.text.contains(v) || controller2.text.contains(v)) {
        tipError('敏感词汇无法创建');
        return;
      }
    }
    if (avatar.isEmpty) {
      tipError('请选择头像'.tr());
      return;
    }
    final api = CircleApi(apiClient());
    loading();
    waitStatus = true;
    setState(() {});
    try {
      final res = await api.circleAddCircle(
        V1CircleAddArgs(
          circleType: V1CircleAddArgsCircleType(circleType: circleType),
          name: V1CircleAddArgsValue(value: controller1.text),
          describe: V1CircleAddArgsValue(value: controller2.text),
          image: V1CircleAddArgsValue(value: avatar),
        ),
      );
      if (res == null) return;
      if (res.status == GApplyStatus.APPLY) {
        tipSuccess('提交成功，等待平台审核'.tr());
        if (mounted) Navigator.of(context).pop();
      } else {
        tip('创建失败'.tr());
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color inputColor = myColors.chatInputColor;
    Color textColor = myColors.iconThemeColor;
    double padding = 16;
    return Scaffold(
      appBar: AppBar(
        title: Text('创建圈子'.tr()),
        // actions: [
        //   IconButton(
        //     onPressed: save,
        //     icon: Image.asset(
        //       assetPath('images/help/circle_create.png'),
        //       color: textColor,
        //       width: 18,
        //       height: 18,
        //       fit: BoxFit.contain,
        //     ),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: padding, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 17,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: myColors.circleBlueButtonBg,
                              ),
                            ),
                            Text(
                              '圈子名称'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5, left: padding, right: padding),
                        child: AppInputBox(
                          controller: controller1,
                          hintText: '输入圈子名称'.tr(),
                          hintColor: myColors.textGrey,
                          fontSize: 15,
                          color: inputColor,
                          fontColor: textColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: padding, vertical: 15),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 17,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: myColors.circleBlueButtonBg,
                              ),
                            ),
                            Text(
                              '圈子描述'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: myColors.chatInputColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          children: [
                            AppTextarea(
                                controller: controller2,
                                fontSize: 15,
                                radius: 15,
                                minLines: 6,
                                maxLines: 6,
                                maxLength: 200,
                                hintText: '圈子内容描述...........'.tr()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: padding,
                          right: padding,
                          bottom: 10,
                          top: 15,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 17,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: myColors.circleBlueButtonBg,
                              ),
                            ),
                            Text(
                              '上传圈子头像'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: padding,
                        ),
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: pickerAvatar,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                assetPath('images/help/add_image.png'),
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                              if (avatar.isNotEmpty)
                                AppNetworkImage(
                                  avatar,
                                  width: 100,
                                  height: 100,
                                  borderRadius: BorderRadius.circular(13),
                                  imageSpecification: ImageSpecification.w120,
                                  fit: BoxFit.contain,
                                ),
                              if (avatar.isNotEmpty)
                                Opacity(
                                  opacity: 0.1,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: myColors.shade,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      MenuUl(
                        marginTop: 0,
                        // buttonColor: myColors.chatInputColor,
                        children: [
                          MenuItemData(
                            icon: assetPath('images/help/select_circle.png'),
                            iconSize: 21,
                            title: '圈子类型'.tr(),
                            content: Text(
                              type,
                              style: TextStyle(color: textColor),
                            ),
                            onTap: _chooseCircleType,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BottomButton(
                  title: '创建'.tr(),
                  onTap: save,
                  waiting: waitStatus,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
