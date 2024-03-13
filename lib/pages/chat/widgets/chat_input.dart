import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_editor_plus/image_editor_plus.dart' as photo_editor;
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/file_save.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/media_picker.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/custom_emoji_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/custom_emoji.dart';
import 'package:unionchat/pages/chat/widgets/remind_group.dart';
import 'package:unionchat/pages/chat/widgets/talk_message.dart';
import 'package:unionchat/pages/friend/friend_list.dart';
import 'package:unionchat/pages/note/note_home.dart';
import 'package:unionchat/pages/setting/fast_chat_bottom.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/image_editor_pro.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../../function_config.dart';
import '../../../notifier/app_state_notifier.dart';
import '../../collect/collect_home.dart';

//长按菜单类型
enum CustomEmojiPopType {
  //置顶
  top,
  //删除
  delete,
}

extension CustomEmojiPopTypeExt on CustomEmojiPopType {
  String get toChar {
    switch (this) {
      case CustomEmojiPopType.top:
        return '移到前面';
      case CustomEmojiPopType.delete:
        return '删除';
    }
  }
}

class ChatInput extends StatefulWidget {
  //发送
  final Function(
    String,
    GMessageType, {
    int? duration,
    // String? cover,
    String? fileName,
    MessagePopType? editType,
    Message? data,
    List<int>? remind,
  })? onSend;

  //语音录制监听
  final Function(double)? listenRecord;

  final String roomId;
  final String? receiveId;

  //输入框焦点
  final FocusNode focusNode;

  //输入框控制器
  final TextEditingController textEditingController;

  //语音录制状态
  final Function(VoicePressType)? voicePress;

  //群聊可发送的消息类型
  final int roomPower;

  //群身份
  final GRoomMemberIdentity identity;

  // 是否全局禁言
  final bool allNoSpeak;

  // 是否个人禁言
  final bool singleNoSpeak;

  const ChatInput({
    required this.focusNode,
    required this.textEditingController,
    this.allNoSpeak = false,
    this.singleNoSpeak = false,
    this.onSend,
    this.listenRecord,
    this.voicePress,
    this.roomId = '',
    this.receiveId,
    this.roomPower = -1,
    this.identity = GRoomMemberIdentity.NIL,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return ChatInputState();
  }
}

class ChatInputState extends State<ChatInput> {
  int emojiLimit = 100000;
  final GlobalKey _stackKey = GlobalKey();
  bool _isText = true;
  double height = 55;
  bool tapOut = false;
  bool tap = false;
  Codec codec = Codec.aacMP4;
  int voiceDuration = 0;
  bool recorderInit = false;
  ImagePicker picker = ImagePicker();
  final record = Record();
  int recordStartTime = 0;

  //表情选项
  List emojiList = [
    'emoji',
    'customEmoji ',
  ];
  String emojiSelected = 'emoji';
  List<GUserExpressionModel> customEmojiData = [];
  List<CustomEmojiPopType> pops = [
    CustomEmojiPopType.top, //删除
    CustomEmojiPopType.delete, //删除
  ];

  //初始化语音控件
  Future<void> _initializeRecorder() async {
    if (recorderInit) return;
    if (!await devicePermission([Permission.microphone])) return;
    recorderInit = true;
  }

  // 抖一抖
  sendVibration() async {
    if (!messageHasPower(widget.roomPower, GMessageType.SHAKE)) {
      tipError('当前对话已禁止发送名片'.tr());
      return;
    }
    if (widget.onSend != null) {
      widget.onSend!('', GMessageType.SHAKE);
    }
  }

  //发送消息
  sendBtnTap() async {
    if (!messageHasPower(widget.roomPower, GMessageType.TEXT)) {
      tipError('当前对话已禁止发送文字'.tr());
      return;
    }
    var notifier = Provider.of<ChatInputNotifier>(context, listen: false);
    var text = widget.textEditingController.text.trim();
    if (widget.onSend != null && text.isNotEmpty) {
      widget.onSend!(
        text,
        GMessageType.TEXT,
        editType: notifier.messagePopType,
        data: notifier.quoteEditMessageData,
        remind: notifier.remindList.map((e) => toInt(e.id)).toList(),
      );
      notifier.remindList = [];
    }
    if (Platform.isWindows) widget.focusNode.unfocus();
    Future.microtask(() {
      widget.textEditingController.text = '';
      _inputOldText = '';
      notifier.messagePopType = null;
      notifier.quoteEditMessageData = null;
      notifier.showSendBtn = false;
      if (Platform.isWindows) widget.focusNode.requestFocus();
    });

    // inputUnFocus();
  }

  // 开始录音
  startRecord() async {
    if (!messageHasPower(widget.roomPower, GMessageType.AUDIO)) {
      tipError('当前对话已禁止发送语音'.tr());
      return;
    }
    if (platformPhone && !await devicePermission([Permission.microphone])) {
      return;
    }
    var encoder = AudioEncoder.aacLc;
    if (Platform.isWindows) {
      encoder = AudioEncoder.flac;
    }
    await record.start(encoder: encoder);
    recordStartTime = DateTime.now().microsecondsSinceEpoch;
  }

  // 结束录音
  endRecord() async {
    var path = await record.stop();
    if (tapOut || path == null || path.isEmpty) {
      tapOut = false;
      return;
    }
    var duration =
        (DateTime.now().microsecondsSinceEpoch - recordStartTime) ~/ 1000000;
    if (duration < 1) return;
    if (widget.onSend != null) {
      var filePath = path;
      if (!Platform.isWindows) {
        filePath = File.fromUri(Uri.parse(path)).path;
      }
      widget.onSend!(
        filePath,
        GMessageType.AUDIO,
        duration: duration,
      );
    }
  }

  //录音手势事件
  tapEvent(VoicePressType type) {
    if (!messageHasPower(widget.roomPower, GMessageType.AUDIO)) {
      tipError('当前对话已禁止发送语音'.tr());
      return;
    }
    if (widget.voicePress != null) widget.voicePress!(type);
    switch (type) {
      case VoicePressType.down: //按下
        closeBottom();
        tap = true;
        height = _stackKey.currentContext!.size!.height + 50;
        startRecord();
        break;
      case VoicePressType.up: //抬起
        endRecord();
        tap = false;
        height = 55;
        break;
      case VoicePressType.out: //移动到区域外
        tapOut = true;
        break;
      case VoicePressType.inside: //移动到区域内
        tapOut = false;
        break;
      case VoicePressType.nil:
        break;
    }
    setState(() {});
  }

  String _inputOldText = '';

  //显示@好友
  showTipFriend(String val) {
    var oldVal = _inputOldText;
    _inputOldText = val;
    if (oldVal.length > val.length) return;
    if (val.isEmpty || val.split('').last != '@' || widget.roomId.isEmpty) {
      return;
    }
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context1) {
          return RemindGroup(
            // choice: remind.toList(),
            roomId: widget.roomId,
            onConfirm: (friends) {
              var str = '';
              var notifier =
                  Provider.of<ChatInputNotifier>(context, listen: false);
              var remind = notifier.remindList;
              for (var v in friends) {
                if (notifier.remindContainsId(v.id!)) continue;
                remind.add(v);
                str += '@${v.title} ';
              }
              notifier.remindList = remind;
              // remind.addAll(rl);
              var controller = widget.textEditingController;
              var inputText = controller.text;
              controller.text = inputText.substring(0, inputText.length - 1);
              if (str.isNotEmpty) {
                controller.text += str;
              }
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
          );
        },
      ),
    );
  }

  //判断是否删除@好友
  removeRemind(String val) {
    // val = val.trim();
    var notifier = Provider.of<ChatInputNotifier>(context, listen: false);
    if (val.isEmpty || notifier.remindList.isEmpty) return;
    List<ChatItemData> rl = [];
    for (var v in notifier.remindList) {
      var str = '@${v.title}';
      if (widget.textEditingController.text.contains(str)) {
        rl.add(v);
      }
    }
    notifier.remindList = rl;
  }

  //文字输入框
  Widget _textInputWidget(Color textColor) {
    var notifier = Provider.of<ChatInputNotifier>(context, listen: false);
    return TextFormField(
      focusNode: widget.focusNode,
      controller: widget.textEditingController,
      onTap: closeBottom,
      onChanged: (val) {
        showTipFriend(val);
        if (val.isEmpty && notifier.showSendBtn) {
          notifier.showSendBtn = false;
        }
        if (val.isNotEmpty && !notifier.showSendBtn) {
          notifier.showSendBtn = true;
        }
        removeRemind(val);
      },
      onSaved: (val) {},
      onEditingComplete: () {
        sendBtnTap();
      },
      maxLines: 10,
      minLines: 1,
      style: TextStyle(
        color: textColor,
      ),
      textInputAction: !platformPhone ? TextInputAction.send : null,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //语音输入框
  voiceInput(Color textColor) {
    return Container(
      alignment: Alignment.center,
      height: 48,
      child: Text(
        '按住说话'.tr(),
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //pc选择图片
  pcPickerImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (widget.onSend != null && result != null && result.files.isNotEmpty) {
      String str = '';
      for (var v in result.files) {
        str += '${v.path},';
      }
      str = str.substring(0, str.length - 1);
      if (str.isNotEmpty) widget.onSend!(str, GMessageType.IMAGE);
    }
  }

  // 手机编辑图片
  Future<void> phoneEditImage(String path) async {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => ImageEditorPro(
          File(path).readAsBytesSync(),
          // avatar: true,
        ),
      ),
    ).then((res) async {
      if (res == null) return;
      loading();
      var imagePath = await FileSave().pcTempSaveImage(res['result']);
      loadClose();
      if (imagePath.isNotEmpty) {
        widget.onSend!(imagePath, GMessageType.IMAGE);
      }
    });
    return;
  }

  // 手机编辑图片
  Future<void> phoneEditImage1(String path) async {
    try {
      photo_editor.ImageEditor.i18n({
        'Remove': '删除'.tr(),
        'Save': '保存'.tr(),
        'Crop': '裁剪'.tr(),
        'Brush': '画笔'.tr(),
        'Text': '文字'.tr(),
        'Flip': '翻转'.tr(),
        'Rotate left': '向左旋转'.tr(),
        'Rotate right': '向右旋转'.tr(),
        'Blur': '模糊'.tr(),
        'Filter': '滤镜'.tr(),
        'Emoji': '表情'.tr(),
      });
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => photo_editor.ImageEditor(
            image: File(path).readAsBytesSync(),
          ),
        ),
      );
      loading();
      if (editedImage != null) {
        var imagePath = await FileSave().pcTempSaveImage(editedImage);
        if (imagePath.isNotEmpty) {
          widget.onSend!(imagePath, GMessageType.IMAGE);
        }
      }
    } catch (e) {
      tipError('图片编辑失败');
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //手机选择图片
  phonePickerImage(ImageSource source, {bool edit = false}) async {
    List<String> path = [];
    AppStateNotifier().enablePinDialog = false;
    if (source == ImageSource.camera) {
      XFile? file = await picker.pickImage(source: source);
      if (file != null) path.add(file.path);
    } else if (source == ImageSource.gallery) {
      var files = await MediaPicker.image(
        context,
        maxLength: edit ? 1 : 9,
        edit: edit,
      );
      path = files.map((e) => e.path).toList();
    }
    AppStateNotifier().enablePinDialog = true;
    if (widget.onSend != null && path.isNotEmpty) {
      // widget.onSend!(path.join(','), GMessageType.IMAGE);
      if (edit) {
        phoneEditImage(path[0]);
      } else {
        widget.onSend!(path.join(','), GMessageType.IMAGE);
      }
    }
  }

  //选择图片
  pickerImage() async {
    if (!messageHasPower(widget.roomPower, GMessageType.IMAGE)) {
      tipError('当前对话已禁止发送图片'.tr());
      return;
    }
    if (platformPhone) {
      openSheetMenu(context, list: [
        '相册'.tr(),
        '拍照'.tr(),
        if (platformPhone) '编辑发送'.tr(),
      ], onTap: (i) {
        phonePickerImage(
          i == 1 ? ImageSource.camera : ImageSource.gallery,
          edit: i == 2,
        );
      });
    } else if (Platform.isWindows || Platform.isMacOS) {
      pcPickerImage();
    } else {
      tip('该平台暂不支持'.tr());
    }
  }

  //发送视频消息
  sendVideoMessage(List<String> path) {
    if (path.isEmpty) return;
    if (Platform.isWindows) {
      getVideoDuration(path[0], success: (seconds) {
        widget.onSend!(
          path[0],
          GMessageType.VIDEO,
          duration: seconds,
          // cover: cover,
        );
      });
      return;
    }
    for (var p in path) {
      var video = VideoPlayerController.file(File(p));
      video.initialize().then((val) {
        widget.onSend!(
          p,
          GMessageType.VIDEO,
          duration: video.value.duration.inSeconds,
        );
        video.dispose();
      });
    }
  }

  //pc选择视频
  pcPickerVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (widget.onSend != null && result != null && result.files.isNotEmpty) {
      sendVideoMessage([result.files[0].path!]);
    }
  }

  //选择视频
  pickerVideo() async {
    if (!messageHasPower(widget.roomPower, GMessageType.VIDEO)) {
      tipError('当前对话已禁止发送视频'.tr());
      return;
    }
    if (Platform.isWindows || Platform.isMacOS) {
      pcPickerVideo();
      return;
    }
    openSheetMenu(
      context,
      list: ['相册'.tr(), '摄像头'.tr()],
      onTap: (i) async {
        ImageSource source = i == 0 ? ImageSource.gallery : ImageSource.camera;
        AppStateNotifier().enablePinDialog = false;
        List<String> path = [];
        if (i == 0) {
          var files = await MediaPicker.video(context);
          path = files.map((e) => e.path).toList();
        } else {
          XFile? file = await picker.pickVideo(
            source: source,
            // preferredCameraDevice: CameraDevice.rear,
            maxDuration: i == 0 ? null : const Duration(seconds: 60),
          );
          if (file != null) path = [file.path];
        }

        AppStateNotifier().enablePinDialog = true;
        if (path.isEmpty || widget.onSend == null) return;
        // final fileName = await VideoThumbnail.thumbnailFile(
        //   video: file.path,
        //   thumbnailPath: Global.temporaryDirectory,
        //   imageFormat: ImageFormat.PNG,
        //   quality: 100,
        // );
        // var cover = await MediaZip.videoCover(file.path);
        sendVideoMessage(path);
      },
    );
  }

  //选择文件
  pickerFile() async {
    if (!messageHasPower(widget.roomPower, GMessageType.FILE)) {
      tipError('当前对话已禁止发送文件'.tr());
      return;
    }
    AppStateNotifier().enablePinDialog = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    AppStateNotifier().enablePinDialog = true;
    if (widget.onSend != null && result != null && result.files.isNotEmpty) {
      var file = result.files[0];
      if (file.path == null || file.path!.isEmpty) return;
      var fileType = getFileType(file.path!);
      switch (fileType) {
        case AppFileType.image:
          widget.onSend!(file.path!, GMessageType.IMAGE);
          break;
        case AppFileType.video:
          sendVideoMessage([file.path!]);
          break;
        case AppFileType.other:
          widget.onSend!(
            file.path!,
            GMessageType.FILE,
            duration: file.size,
            fileName: file.name,
          );
          break;
      }
    }
  }

  //关闭底部功能按钮
  closeBottom() {
    var notifier = Provider.of<ChatInputNotifier>(context, listen: false);
    notifier.showBottomBtn = false;
    notifier.showEmojiPicker = false;
  }

  //打开快捷语弹窗
  openFast() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return FastChatBottom(
          onTap: (str) {
            if (widget.onSend != null && str.isNotEmpty) {
              widget.onSend!(str, GMessageType.TEXT);
            }
          },
        );
      },
    );
  }

  //通话选择
  callOptions() {
    openSheetMenu(context, list: [
      '视频通话'.tr(),
      '语音通话'.tr(),
    ], onTap: (i) {
      if (i == 0) {
        if (!messageHasPower(widget.roomPower, GMessageType.VIDEO_CALL)) {
          tipError('当前对话已禁止发送视频通话'.tr());
          return;
        }
        if (widget.onSend != null) {
          widget.onSend!('', GMessageType.VIDEO_CALL);
        }
      } else if (i == 1) {
        if (!messageHasPower(widget.roomPower, GMessageType.AUDIO_CALL)) {
          tipError('当前对话已禁止发送语音通话'.tr());
          return;
        }
        if (widget.onSend != null) {
          widget.onSend!('', GMessageType.AUDIO_CALL);
        }
      }
    });
  }

  //编辑消息的内容组件
  Widget editWidget(Message? quoteEditMessage, MessagePopType? messagePopType) {
    if (quoteEditMessage == null ||
        messagePopType == null ||
        messagePopType != MessagePopType.edit) {
      return Container();
    }
    return quoteEditWidget(
      '[编辑消息]'.tr(args: [quoteEditMessage.content ?? '']),
      bottom: 10,
      top: 0,
    );
  }

  //引用消息的内容组件
  Widget quoteWidget(
      Message? quoteEditMessage, MessagePopType? messagePopType) {
    if (quoteEditMessage == null ||
        messagePopType == null ||
        messagePopType != MessagePopType.quote) {
      return Container();
    }
    var msg = quoteEditMessage;
    var content = msg.content ?? '';
    if (msg.type != GMessageType.TEXT) {
      content = messageType2text(msg.type);
    }
    if (msg.type == GMessageType.USER_CARD ||
        msg.type == GMessageType.ROOM_CARD) {
      content += ' ${msg.content ?? ''}';
    }
    if (msg.type == GMessageType.HISTORY || msg.type == GMessageType.NOTES) {
      content += ' ${msg.title ?? ''}';
    }
    return quoteEditWidget('${msg.senderUser?.nickname}：$content');
  }

  //引用、编辑样式组件
  Widget quoteEditWidget(
    String text, {
    double top = 10,
    double bottom = 0,
  }) {
    var myColors = ThemeNotifier();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 10, right: 10, top: top, bottom: bottom),
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: myColors.tagColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: myColors.textGrey,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              var notifier =
                  Provider.of<ChatInputNotifier>(context, listen: false);
              notifier.quoteEditMessageData = null;
              notifier.messagePopType = null;
              widget.textEditingController.text = '';
              widget.focusNode.unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
              child: Icon(
                Icons.close,
                size: 15,
                color: myColors.iconThemeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //表情整体box
  Widget emojiSelectBar(ChatInputNotifier notifier) {
    return Column(
      children: [
        emojiTabWidget(),
        if (emojiSelected == emojiList[0]) emojiPickerWidget(notifier),
        if (emojiSelected == emojiList[1]) customEmojiWidget(),
      ],
    );
  }

  // 表情与custom切换组件
  Widget emojiTabWidget() {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              emojiSelected = emojiList[0];
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: emojiSelected == emojiList[0] ? myColors.grey : null,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 5,
              ),
              child: const Icon(Icons.emoji_emotions_outlined),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              emojiSelected = emojiList[1];
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: emojiSelected == emojiList[1] ? myColors.grey : null,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 5,
              ),
              child: const Icon(Icons.favorite_border_outlined),
            ),
          ),
        ],
      ),
    );
  }

  //emoji表情组件
  Widget emojiPickerWidget(ChatInputNotifier notifier) {
    var myColors = ThemeNotifier();
    return Container(
      color: myColors.tagColor,
      height: 240,
      child: EmojiPicker(
        onEmojiSelected: (cate, emoji) {
          if (widget.textEditingController.text.isNotEmpty) {
            notifier.showSendBtn = true;
          }
        },
        textEditingController: widget.textEditingController,
        config: Config(bgColor: myColors.tagColor),
      ),
    );
  }

  //自定义customEmoji表情组件
  Widget customEmojiWidget() {
    //有的屏幕宽度不是整数，取整
    double size = ((MediaQuery.of(context).size.width - 70) ~/ 5).toDouble();
    var myColors = ThemeNotifier();
    customEmojiData = context.watch<CustomEmojiNotifier>().imageData;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: myColors.tagColor,
      height: 240,
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: PagerBox(
              limit: emojiLimit,
              onInit: () async {
                if (!mounted) return 0;
                return await CustomEmojiNotifier().refresh(init: true);
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _addCustomButton(size), //添加按钮
                    for (var v in customEmojiData) _customBox(v, size), //图片项
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //自定义customEmoji表情添加按钮
  Widget _addCustomButton(double size) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, CustomEmoji.path);
      },
      child: Image.asset(
        assetPath('images/talk/add_image.png'),
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }

  OverlayEntry? _overlayEntry;

  //打开图片预览
  tipImage(
    BuildContext imgContext,
    double screenWidth,
    double size,
    double magnification,
    Widget magnificationChild, {
    double paddingHeight = 0, //距离当前图片增加高度
    double paddingWidth = 0, //距离当前列表左右边距总和
  }) {
    closeTipImage();
    var myColors = ThemeNotifier();
    RenderBox renderBox = imgContext.findRenderObject() as RenderBox;
    Offset positioned = renderBox.localToGlobal(Offset.zero);
    double rightPositioned = 0;
    double topPositioned = positioned.dy - size * magnification - paddingHeight;
    double leftPositioned = paddingWidth / 2;
    if (positioned.dx == paddingWidth / 2) {
      leftPositioned = leftPositioned;
    } else if (screenWidth - positioned.dx - size - paddingWidth / 2 - 5 < 0) {
      //有的屏幕宽度不是整数，取整，最大减去5判断
      rightPositioned = paddingWidth / 2;
    } else {
      leftPositioned = positioned.dx - size / 2 - paddingWidth / 4;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: closeTipImage,
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            //三角形
            Positioned(
              left: positioned.dx + size / 2,
              top: positioned.dy,
              child: Container(
                width: 0,
                height: 0,
                decoration: BoxDecoration(
                  border: Border(
                    // 朝向设置颜色
                    bottom: BorderSide(
                        color: myColors.tagColor,
                        width: 30,
                        style: BorderStyle.solid),
                    right: const BorderSide(
                        color: Colors.transparent,
                        width: 20,
                        style: BorderStyle.solid),
                    left: const BorderSide(
                        color: Colors.transparent,
                        width: 20,
                        style: BorderStyle.solid),
                    top: const BorderSide(
                        color: Colors.transparent,
                        width: 30,
                        style: BorderStyle.solid),
                  ),
                ),
              ),
            ),
            //放大内容
            Positioned(
              left: rightPositioned == 0 ? leftPositioned : null,
              right: rightPositioned == 0 ? null : rightPositioned,
              top: topPositioned,
              child: magnificationChild,
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  //关闭图片预览
  closeTipImage() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    if (mounted) setState(() {});
  }

  //自定义customEmoji发大预览样式
  Widget _customTipBox(
    GUserExpressionModel v,
    double size,
    double magnification,
  ) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: myColors.tagColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size * magnification,
            height: size * magnification,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppNetworkImage(
              v.link!,
              width: size * magnification,
              height: size * magnification,
              fit: BoxFit.cover,
            ),
          ),
          //移动、删除按钮
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  style: BorderStyle.solid,
                  color: myColors.chatInputBoderColor,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < pops.length; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          manageCustom(pops[i], v);
                          closeTipImage();
                        },
                        child: Container(
                          width: size,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: i != pops.length - 1
                                ? Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      style: BorderStyle.solid,
                                      color: myColors.chatInputBoderColor,
                                    ),
                                  )
                                : null,
                          ),
                          child: Text(
                            pops[i].toChar,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  //自定义customEmoji表情图片基本项
  Widget _customBox(GUserExpressionModel v, double size) {
    double screenWidth = MediaQuery.of(context).size.width;
    double magnification = 2; //放大两倍
    return Builder(
      builder: (BuildContext imgContext) {
        return GestureDetector(
          onLongPressStart: (details) {
            tipImage(
              imgContext,
              screenWidth,
              size,
              magnification,
              _customTipBox(v, size, magnification),
              paddingWidth: 30,
              paddingHeight: 60,
            );
          },
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () async {
                widget.onSend!(v.link!, GMessageType.IMAGE);
              },
              child: AppNetworkImage(
                v.link!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  //方法：管理customEmoji表情
  manageCustom(CustomEmojiPopType type, GUserExpressionModel v) async {
    switch (type) {
      case CustomEmojiPopType.delete:
        loading();
        final api = UserExpressionApi(apiClient());
        try {
          await api.userExpressionDel(GIdsArgs(
            ids: [v.id!],
          ));
          if (mounted) CustomEmojiNotifier().removeById([v.id!]);
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
        break;
      case CustomEmojiPopType.top:
        double sort = 0;
        if (customEmojiData.isNotEmpty) {
          if (customEmojiData[0].sort != null &&
              toDouble(customEmojiData[0].sort!) < customEmojiData.length + 1) {
            sort = customEmojiData.length + 1;
          } else {
            sort = toDouble(customEmojiData[0].sort) + 1;
          }
        }
        logger.i(sort);
        if (sort == 0) return;
        loading();
        final api = UserExpressionApi(apiClient());
        try {
          await api.userExpressionUpdate(V1UpdateUserExpressionArgs(
            id: v.id,
            sort: V1UpdateUserExpressionArgsSort(value: sort),
          ));
          if (mounted) {
            int oldIndex = customEmojiData.indexOf(v);
            CustomEmojiNotifier().move(0, oldIndex);
          }
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
        break;
    }
  }

  int bottomBtnIndex = 0;

  //底部功能按钮组件
  Widget bottomBtnWidget() {
    var myColors = ThemeNotifier();
    List<Widget> btns = [
      ChatInputButton(
        onTap: pickerImage,
        title: '图片'.tr(),
        icon: Icon(
          Icons.photo,
          color: myColors.iconThemeColor,
        ),
      ),
      ChatInputButton(
        onTap: pickerVideo,
        title: '视频'.tr(),
        icon: Icon(
          Icons.videocam_rounded,
          color: myColors.iconThemeColor,
        ),
      ),
      if (widget.roomId.isEmpty && FunctionConfig.sendCall)
        ChatInputButton(
          onTap: callOptions,
          title: '视频通话'.tr(),
          icon: Icon(
            Icons.video_call,
            color: myColors.iconThemeColor,
          ),
        ),
      // if (widget.roomId.isNotEmpty &&
      //     (widget.identity == GRoomMemberIdentity.OWNER ||
      //         widget.identity == GRoomMemberIdentity.ADMIN) &&
      //     FunctionConfig.sendRedPacket)
      //   ChatInputButton(
      //     onTap: () {
      //       if (!MessageType.redPacket.hasPower(widget.roomPower)) {
      //         tipError('当前对话已禁止发送红包'.tr());
      //         return;
      //       }
      //       if (widget.onSend != null) {
      //         widget.onSend!('', MessageType.redPacket);
      //       }
      //     },
      //     title: '红包'.tr(),
      //     icon: Icon(
      //       Icons.wallet,
      //       color: myColors.iconThemeColor,
      //     ),
      //   ),
      if (FunctionConfig.sendLocation && (Platform.isIOS || Platform.isAndroid))
        ChatInputButton(
          onTap: () async {
            if (!messageHasPower(widget.roomPower, GMessageType.LOCATION)) {
              tipError('当前对话已禁止发送位置'.tr());
              return;
            }
            if (!await devicePermission([Permission.location])) {
              return;
            }
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AppMap(
                      onEnter: (location) {
                        var msg = Message()
                          ..senderUser = getSenderUser()
                          ..type = GMessageType.LOCATION
                          ..location = location.location
                          ..title = location.title
                          ..content = location.desc;
                        widget.onSend!(
                          '',
                          GMessageType.LOCATION,
                          data: msg,
                        );
                      },
                    );
                  },
                ),
              );
              // Navigator.pushNamed(context, MapPage.path).then((value) {
              //   if (widget.onSend != null && value != null) {
              //     widget.onSend!('', MessageType.location,
              //         data: value as Message);
              //   }
              // });
            }
          },
          title: '位置',
          icon: Icon(
            Icons.location_on,
            color: myColors.iconThemeColor,
          ),
        ),
      ChatInputButton(
        onTap: () {
          if (!messageHasPower(widget.roomPower, GMessageType.NOTES)) {
            tipError('当前对话已禁止发送笔记'.tr());
            return;
          }
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const ThemeImage(child: NoteHome()),
              settings: RouteSettings(
                arguments: {
                  'share': true,
                  'receiver': widget.receiveId,
                  'roomId': widget.roomId,
                },
              ),
            ),
          );
        },
        title: '笔记'.tr(),
        icon: Icon(
          Icons.note_alt,
          color: myColors.iconThemeColor,
        ),
      ),
      ChatInputButton(
        onTap: () {
          if (!messageHasPower(widget.roomPower, GMessageType.USER_CARD)) {
            tipError('当前对话已禁止发送名片'.tr());
            return;
          }
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const ThemeImage(child: FriendList()),
              settings: RouteSettings(
                arguments: {
                  'receiver': widget.receiveId,
                  'roomId': widget.roomId,
                },
              ),
            ),
          );
        },
        title: '好友名片'.tr(),
        icon: Icon(
          Icons.card_membership_outlined,
          color: myColors.iconThemeColor,
        ),
      ),
      ChatInputButton(
        onTap: () {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const ThemeImage(child: CollectHome()),
              settings: RouteSettings(
                arguments: {
                  'share': true,
                  'receiver': widget.receiveId,
                  'roomId': widget.roomId,
                },
              ),
            ),
          );
        },
        title: '我的收藏'.tr(),
        icon: Icon(
          Icons.favorite,
          color: myColors.iconThemeColor,
        ),
      ),
      ChatInputButton(
        onTap: openFast,
        title: '快捷语'.tr(),
        icon: Icon(
          Icons.rocket_launch,
          color: myColors.iconThemeColor,
        ),
      ),
      if (FunctionConfig.sendFile)
        ChatInputButton(
          onTap: pickerFile,
          title: '文件'.tr(),
          icon: Icon(
            Icons.file_present_rounded,
            color: myColors.iconThemeColor,
          ),
        ),
      ChatInputButton(
        onTap: () {
          if (widget.onSend != null) {
            widget.onSend!('', GMessageType.RED_INTEGRAL);
          }
        },
        title: '派聊红包'.tr(),
        icon: Icon(
          Icons.wallet,
          color: myColors.iconThemeColor,
        ),
      ),
      // if (widget.roomId.isNotEmpty &&
      //     (widget.identity == GRoomMemberIdentity.ADMIN ||
      //         widget.identity == GRoomMemberIdentity.OWNER))
      if (widget.roomId.isEmpty)
        ChatInputButton(
          onTap: sendVibration,
          title: '抖一抖'.tr(),
          icon: Icon(
            Icons.vibration_rounded,
            color: myColors.iconThemeColor,
          ),
        ),
    ];
    List<List<Widget>> rowList = [];
    if (btns.length <= 8) {
      rowList = [btns];
    } else {
      rowList = [btns.sublist(0, 8), btns.sublist(8, btns.length)];
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (i, _) {
              setState(() => bottomBtnIndex = i);
            },
            viewportFraction: 1,
            height: 200,
          ),
          items: rowList.map((e) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: RowList(
                rowNumber: 4,
                lineSpacing: 10,
                children: e.map((v) {
                  return v;
                }).toList(),
              ),
            );
          }).toList(),
        ),
        if (rowList.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowList.map((e) {
              var i = rowList.indexOf(e);
              return Container(
                margin: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      bottomBtnIndex == i ? myColors.black : myColors.textGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  double _boxHeight = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    record.dispose();
    // recordStreamSub?.cancel();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _overlayEntry?.dispose();
    super.dispose();
  }

  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color chatInputColor = myColors.chatInputColor;
    Color chatInputBoderColor = myColors.chatInputBoderColor;
    Color textColor = myColors.iconThemeColor;
    double btnSize = 30;
    return LayoutBuilder(builder: (context, constraints) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        var height = _key.currentContext?.size?.height ?? 0;
        if (_boxHeight > 0 && _boxHeight == height) return;
        setState(() {
          _boxHeight = _key.currentContext?.size?.height ?? 0;
        });
      });
      return Stack(
        children: [
          Consumer<ChatInputNotifier>(
            builder: (context, notifier, _) {
              bool showBottomBtn = notifier.showBottomBtn;
              bool showEmojiPicker = notifier.showEmojiPicker;
              bool showSendBtn = notifier._showSendBtn;
              Message? quoteEditMessage = notifier.quoteEditMessageData;
              MessagePopType? messagePopType = notifier.messagePopType;
              return Container(
                key: _key,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: !tap
                      ? Border(
                          top: BorderSide(
                            color: chatInputBoderColor,
                            width: 0.5,
                            style: BorderStyle.solid,
                          ),
                        )
                      : null,
                ),
                child: Stack(
                  key: _stackKey,
                  alignment: Alignment.topCenter,
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                //切换语音输入按钮
                                GestureDetector(
                                  onTap: () {
                                    widget.focusNode.unfocus();
                                    setState(() {
                                      _isText = !_isText;
                                    });
                                    if (!_isText) {
                                      closeBottom();
                                      _initializeRecorder();
                                    }
                                  },
                                  child: Image.asset(
                                    assetPath(
                                        'images/${_isText ? 'sp_yuyin_input' : 'sp_jianpan'}.png'),
                                    color: textColor,
                                    width: btnSize,
                                    height: btnSize,
                                  ),
                                ),
                                //语音、键盘输入框
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      editWidget(
                                        quoteEditMessage,
                                        messagePopType,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: chatInputColor,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                            color: chatInputBoderColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: _isText
                                            ? _textInputWidget(textColor)
                                            : voiceInput(textColor),
                                      ),
                                      quoteWidget(
                                        quoteEditMessage,
                                        messagePopType,
                                      ),
                                    ],
                                  ),
                                ),
                                //表情按钮
                                GestureDetector(
                                  onTap: () {
                                    widget.focusNode.unfocus();
                                    notifier.showEmojiPicker =
                                        !notifier.showEmojiPicker;
                                    notifier.showBottomBtn = false;
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Image.asset(
                                      assetPath('images/sp_biaoqing.png'),
                                      color: textColor,
                                      width: btnSize,
                                      height: btnSize,
                                    ),
                                  ),
                                ),
                                //发送按钮
                                if (showSendBtn)
                                  GestureDetector(
                                    onTap: sendBtnTap,
                                    child: Container(
                                      width: btnSize,
                                      height: btnSize,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: myColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(btnSize),
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        size: 20,
                                        color: myColors.white,
                                      ),
                                    ),
                                  ),
                                //更多按钮
                                if (!showSendBtn)
                                  GestureDetector(
                                    onTap: () {
                                      widget.focusNode.unfocus();
                                      notifier.showBottomBtn =
                                          !notifier.showBottomBtn;
                                      notifier.showEmojiPicker = false;
                                    },
                                    child: Image.asset(
                                      assetPath('images/sp_jia_0.png'),
                                      color: textColor,
                                      width: btnSize,
                                      height: btnSize,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          //表情选择
                          AnimatedCrossFade(
                            firstChild: emojiSelectBar(notifier),
                            secondChild: Container(),
                            crossFadeState: showEmojiPicker
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 150),
                          ),
                          // if (showEmojiPicker) emojiPickerWidget(notifier),
                          //通话图片等功能按钮
                          AnimatedCrossFade(
                            firstChild: bottomBtnWidget(),
                            secondChild: Container(),
                            crossFadeState: showBottomBtn
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 150),
                          ),
                          // if (showBottomBtn) bottomBtnWidget(),
                        ],
                      ),
                    ),
                    if (tap)
                      Container(
                        height: 40,
                        width: double.infinity,
                        color: myColors.themeBackgroundColor,
                      ),
                    if (tap)
                      Container(
                        height: 40,
                        width: double.infinity,
                        color: myColors.voiceBg,
                      ),
                    //语音点击区域
                    !_isText
                        ? Positioned(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: tap ? 0 : 60,
                                right: tap ? 0 : 100,
                              ),
                              height: height,
                              child: GestureDetector(
                                onPanDown: (d) => tapEvent(VoicePressType.down),
                                onPanEnd: (d) => tapEvent(VoicePressType.up),
                                onPanCancel: () => tapEvent(VoicePressType.up),
                                onPanUpdate: (detail) {
                                  double y = detail.localPosition.dy + 50;
                                  if (y < 0 && !tapOut) {
                                    tapEvent(VoicePressType.out);
                                  }
                                  if (y >= 0 && tapOut) {
                                    tapEvent(VoicePressType.inside);
                                  }
                                },
                                // behavior: HitTestBehavior.opaque,
                                child: CustomPaint(
                                  painter: ArcPainter(
                                    color: tap
                                        ? (tapOut
                                            ? myColors.red
                                            : chatInputBoderColor)
                                        : Colors.transparent,
                                    height: height - (height / 4),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    height: double.infinity,
                                    // color: tap
                                    //     ? (tapOut ? myColors.red : myColors.grey1)
                                    //     : Colors.transparent,
                                    // padding: const EdgeInsets.only(top: 19.5),
                                    child: tap
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // if (tapOut) const Text('松开取消'),
                                              // if (!tapOut) const Text('松开发送'),
                                              Image.asset(
                                                assetPath(
                                                    'images/sp_yuying_0.png'),
                                                width: 13,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            },
          ),
          if (widget.allNoSpeak || widget.singleNoSpeak)
            Container(
              height: _boxHeight,
              decoration: BoxDecoration(
                color: myColors.tagColor,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Image.asset(
                      assetPath('images/jingyanzhong.png'),
                      color: myColors.isDark ? myColors.iconThemeColor : null,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(widget.allNoSpeak ? '全体禁言中' : '禁言中'),
                ],
              ),
            ),
        ],
      );
    });
  }
}

//绘制弧形
class ArcPainter extends CustomPainter {
  final Color color;
  final double height;

  ArcPainter({required this.color, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    var drawHeight = height;
    path.moveTo(0, drawHeight); // 将起点设置在左上角
    path.lineTo(size.width, drawHeight); // 沿着水平线绘制一条直线
    path.lineTo(size.width, 0); // 绘制右边的垂直线段
    path.quadraticBezierTo(
      size.width / 2,
      -drawHeight / 2,
      0,
      0,
    ); // 绘制弧形
    path.close();
    canvas.translate(0, size.height - drawHeight); // 向下平移到底部
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ChatInputNotifier with ChangeNotifier {
  // @好友列表
  List<ChatItemData> _remindList = [];

  List<ChatItemData> get remindList => _remindList;

  set remindList(List<ChatItemData> newData) {
    _remindList = newData;
    notifyListeners();
  }

  //通过id判断@列表是否存该用户
  remindAdd(ChatItemData data) {
    _remindList.add(data);
    notifyListeners();
  }

  //通过id判断@列表是否存该用户
  bool remindContainsId(String id) {
    for (var v in _remindList) {
      if (v.id == id) return true;
    }
    return false;
  }

  bool _showBottomBtn = false; //是否显示底部功能按钮
  bool get showBottomBtn => _showBottomBtn;

  set showBottomBtn(bool newData) {
    _showBottomBtn = newData;
    notifyListeners();
  }

  bool _showEmojiPicker = false; //是否显示表情选择
  bool get showEmojiPicker => _showEmojiPicker;

  set showEmojiPicker(bool newData) {
    _showEmojiPicker = newData;
    notifyListeners();
  }

  bool _showSendBtn = false; //是否显示发送按钮
  bool get showSendBtn => _showSendBtn;

  set showSendBtn(bool newData) {
    _showSendBtn = newData;
    notifyListeners();
  }

  Message? _quoteEditMessageData; //引用、编辑的消息数据
  Message? get quoteEditMessageData => _quoteEditMessageData;

  set quoteEditMessageData(Message? newData) {
    _quoteEditMessageData = newData;
    notifyListeners();
  }

  MessagePopType? _messagePopType; //引用、编辑类型
  MessagePopType? get messagePopType => _messagePopType;

  set messagePopType(MessagePopType? newData) {
    _messagePopType = newData;
    notifyListeners();
  }
}

class ChatInputButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final Function()? onTap;

  const ChatInputButton({
    required this.title,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: myColors.tagColor,
            ),
            child: icon,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: myColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

//语音按钮事件类型
enum VoicePressType {
  nil,
  //按下
  down,
  //抬起
  up,
  //移出
  out,
  //移入
  inside,
}
