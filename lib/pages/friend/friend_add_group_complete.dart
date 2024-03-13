import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/pages/chat/chat_management/group_manage.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/image_editor.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/keyboard_blur.dart';
import '../chat/widgets/chat_talk_model.dart';

class FriendAddGroupComplete extends StatefulWidget {
  const FriendAddGroupComplete({super.key});

  static const String path = 'friends/add_group_complete';

  @override
  State<StatefulWidget> createState() {
    return _FriendAddGroupCompleteState();
  }
}

class _FriendAddGroupCompleteState extends State<FriendAddGroupComplete> {
  bool waitStatus = false; //发送等待
  String? userId; //传入默认选择用户Id
  String avatar = '';
  bool addFriend = true;

  //公开群聊
  bool isPublic = false;

  //勾选列表
  List<ChatItemData> activeIds = [];

  //文本控制器
  final TextEditingController _textController = TextEditingController();

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

  // //图片裁剪
  // photoCrop(String path) async {
  //   logger.d(path);
  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: path,
  //     aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //     // aspectRatioPresets: [],
  //     compressFormat: ImageCompressFormat.png,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: '图片裁剪',
  //         toolbarColor: Colors.black,
  //         toolbarWidgetColor: Colors.white,
  //         lockAspectRatio: true,
  //       ),
  //       IOSUiSettings(
  //         title: '图片裁剪',
  //         doneButtonTitle: '完成',
  //         cancelButtonTitle: '取消',
  //         aspectRatioLockEnabled: true,
  //       ),
  //       WebUiSettings(context: context),
  //     ],
  //   );
  //   if (croppedFile == null) return;
  //   List<String?> urls = await UploadFile(
  //     [croppedFile.path],
  //     type: V1FileUploadType.USER_AVATAR,
  //   ).upload();
  //   avatar = urls[0]!;
  //   logger.d(avatar);
  //   setState(() {});
  // }

  //发起群聊
  addGroup() async {
    if (_textController.text.isEmpty) {
      tipError('名称不能为空'.tr());
      return;
    } else if (_textController.text.length > 15) {
      tipError('群聊名称不能超过15个字');
      return;
    }
    List<String> groupList = [];
    for (var v in activeIds) {
      groupList.add(v.id.toString());
    }
    waitStatus = true;
    setState(() {});
    loading();
    final api = RoomApi(apiClient());

    try {
      var args = V1InitiateRoomArgs(
        userIds: groupList,
        roomAvatar: avatar,
        roomName: _textController.text,
        enableFriend: addFriend ? GSure.YES : GSure.NO,
        // roomType: isPublic ? GRoomType.PUBLIC : GRoomType.PRIVATE,
      );
      final res = await api.roomInitiateRoom(args);
      if (res == null) return;
      if (!mounted) return;
      bottomSheet(res.id ?? '');
      // Navigator.pushReplacementNamed(
      //   context,
      //   ChatTalk.path,
      //   arguments: ChatTalkParams(
      //     roomId: res.id ?? '',
      //     name: _textController.text,
      //   ),
      // );
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

    dynamic args =
        ModalRoute.of(context)!.settings.arguments ?? {'activeIds': ''};
    if (args['activeIds'] == null) return;
    activeIds = args['activeIds'];
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color chatInputColor = myColors.chatInputColor;

    double padding = 16;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('新建群聊'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              '群聊名称'.tr(),
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
                            top: 10, left: padding, right: padding),
                        child: AppInputBox(
                          controller: _textController,
                          hintText: '请输入群组名称'.tr(),
                          hintColor: myColors.textGrey,
                          fontSize: 15,
                          color: chatInputColor,
                          fontColor: textColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: padding, right: padding, bottom: 10),
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
                              '上传群头像'.tr(),
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
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: padding,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
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
                                  opacity: 0.2,
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
                      // MenuUl(
                      //   marginTop: 0,
                      //   children: [
                      //     MenuItemData(
                      //       icon: assetPath('images/talk/image_public.png'),
                      //       title: '群内是否可以添加好友'.tr(),
                      //       arrow: false,
                      //       needColor: myColors.isDark,
                      //       content: AppSwitch(
                      //         value: addFriend,
                      //         onChanged: (val) {
                      //           setState(() {
                      //             addFriend = val;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      // MenuItemData(
                      //   title: '是否公开群聊'.tr(),
                      //   arrow: false,
                      //   content: AppSwitch(
                      //     value: isPublic,
                      //     onChanged: (val) {
                      //       setState(() {
                      //         isPublic = val;
                      //       });
                      //     },
                      //   ),
                      // ),
                      //   ],
                      // ),
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
                            Expanded(
                              child: Text(
                                '群组成员'.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${activeIds.length.toString()}/5000',
                              style: TextStyle(
                                fontSize: 14,
                                color: myColors.subIconThemeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 6,
                          runSpacing: 8,
                          children: activeIds.map((e) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: AppAvatar(
                                    list: e.icons,
                                    size: 41,
                                    userName: e.title,
                                    userId: e.id ?? '',
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      activeIds.remove(e);
                                      setState(() {});
                                    },
                                    child: Image.asset(
                                      assetPath('images/talk/group_close.png'),
                                      height: 19,
                                      width: 19,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomButton(
                  title: '创建'.tr(),
                  onTap: addGroup,
                  waiting: waitStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //提示框
  bottomSheet(String roomId) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeNotifier().themeBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 32,
                    ),
                    child: Image.asset(
                      assetPath('images/talk/success.png'),
                      height: 58,
                      width: 58,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 28,
                      bottom: 58,
                    ),
                    child: Text(
                      '群聊设置成功!,是否前往群设置'.tr(),
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: CircleButton(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                context,
                                ChatTalk.path,
                                arguments: ChatTalkParams(
                                  roomId: roomId,
                                  name: _textController.text,
                                ),
                              );
                              Navigator.pushNamed(
                                context,
                                GroupManage.path,
                                arguments: {'roomId': roomId},
                              );
                            },
                            title: '前往设置'.tr(),
                            radius: 10,
                            theme: AppButtonTheme.blue0,
                            fontSize: 16,
                            height: 47,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: CircleButton(
                            onTap: () async {
                              // Navigator.pop(context);
                              Navigator.popUntil(
                                  context, ModalRoute.withName(Tabs.path));
                              Navigator.pushNamed(
                                context,
                                ChatTalk.path,
                                arguments: ChatTalkParams(
                                  roomId: roomId,
                                  name: _textController.text,
                                ),
                              );
                            },
                            title: '完成创建'.tr(),
                            radius: 10,
                            theme: AppButtonTheme.blue,
                            fontSize: 16,
                            height: 47,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
