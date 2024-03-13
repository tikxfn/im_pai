import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_vlc/dart_vlc.dart' as vlc;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/common_data.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/channel.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/model/show_user.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/chat_management/group_card.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/note_item_pro.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:window_manager/window_manager.dart';

import '../adapter/adapter.dart';
import '../notifier/app_state_notifier.dart';
import '../pages/chat/chat_talk.dart';
import '../pages/chat/widgets/chat_talk_model.dart';
import 'api_request.dart';
import 'enum.dart';

//判断是否是手机
bool platformPhone = Platform.isAndroid || Platform.isIOS;

//图片黑白
ColorFilter greyImageFilter = const ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

//测试网络图片
const String testNetworkPhoto =
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F202003%2F30%2F20200330091314_yNVUZ.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1685949551&t=e0704bf351290fe66f9a8924765f91d6';

//是否手持设备
bool isHandset(BuildContext context) {
  // if(MediaQuery.of(context).size.width < 700 || Platform.isIOS || Platform.isAndroid){
  //   return true;
  // }else if(Platform.isIOS || Platform.isAndroid){
  //   return true;
  // }
  // return false;
  return MediaQuery.of(context).size.width < 700 ||
      Platform.isIOS ||
      Platform.isAndroid;
}

//靓号规律筛选转文本
String goodNumberType2string(GUserNumberType type) {
  // switch (type) {
  //   case GUserNumberType.LEOPARD:
  //     return '豹子号';
  //   case GUserNumberType.STRAIGHT:
  //     return '顺子号';
  //   case GUserNumberType.SHORT:
  //     return '短位靓号';
  //   case GUserNumberType.OTHER:
  //     return '普通号';
  //   case GUserNumberType.NIL:
  //     return '';
  // }
  switch (type) {
    case GUserNumberType.LEOPARD:
      return '至尊靓号1';
    case GUserNumberType.HONORABLE:
      return '至尊靓号2';
    case GUserNumberType.NIL:
      return '';
    case GUserNumberType.OTHER:
      return '普通靓号';
    case GUserNumberType.SHORT:
      return '极品靓号';
    case GUserNumberType.STRAIGHT:
      return '贵族靓号';
    case GUserNumberType.EXCELLENT:
      return '超级靓号';
  }
  return '';
}

//靓号展示转文本
String goodNumberShowstring(GUserNumberType type) {
  switch (type) {
    case GUserNumberType.LEOPARD:
      return '至尊靓号';
    case GUserNumberType.HONORABLE:
      return '至尊靓号';
    case GUserNumberType.NIL:
      return '';
    case GUserNumberType.OTHER:
      return '普通靓号';
    case GUserNumberType.SHORT:
      return '极品靓号';
    case GUserNumberType.STRAIGHT:
      return '贵族靓号';
    case GUserNumberType.EXCELLENT:
      return '超级靓号';
  }
  return '';
}

//靓号图
String goodNumberImageString(GUserNumberType type) {
  switch (type) {
    case GUserNumberType.LEOPARD:
      return 'images/my/liang_zun.png';
    case GUserNumberType.NIL:
      return '';
    case GUserNumberType.OTHER:
      return 'images/my/liang_pu.png';
    case GUserNumberType.SHORT:
      return 'images/my/liang_ji.png';
    case GUserNumberType.STRAIGHT:
      return 'images/my/liang_gui.png';
    case GUserNumberType.EXCELLENT:
      return 'images/my/liang_chao.png';
    case GUserNumberType.HONORABLE:
      return 'images/my/liang_zun.png';
  }
  return '';
}

// 传到后台的数字
String number2api(dynamic n) {
  try {
    var an = (toDouble(n) * 100).toString();
    return an;
  } catch (e) {
    logger.d(e);
    return '0';
  }
}

// 显示后台数组
String api2number(dynamic n) {
  try {
    var an = (toDouble(n) / 100).toStringAsFixed(2);
    return an;
  } catch (e) {
    logger.d(e);
    return '0';
  }
}

// 获取是否打开消息提醒
bool get noticeOpen {
  return (settingsBox.get('noticeClose') ?? '').isEmpty;
}

// 获取是否打开圈子消息提醒
bool get circleNoticeOpen {
  return (settingsBox.get('circleNotice') ?? '').isNotEmpty;
}

// 获取是否打开消息声音提醒
bool get noticeSound {
  return (settingsBox.get('noticeSoundClose') ?? '').isEmpty;
}

// 获取是否打开消息震动提醒
bool get noticeVibration {
  return (settingsBox.get('noticeVibrationClose') ?? '').isEmpty;
}

// 新消息提示
messageNotice({
  bool vibration = true,
  bool sound = true,
  bool message = false,
}) async {
  if (!noticeOpen ||
      !platformPhone ||
      (platformPhone && AppStateNotifier().appHide)) {
    return;
  }
  if (message) {
    sound = noticeSound && sound;
    vibration = noticeVibration && vibration;
  }
  if (await Vibration.hasVibrator() ?? false) {
    if (vibration) Vibration.vibrate(duration: 100);
    if (sound) FlutterRingtonePlayer.playNotification();
  }
}

// 分享笔记链接
Future<void> shareNoteLinks(List<String> ids) async {
  List<String> links = [];
  var url = (Global.systemInfo.settingUrl?.settingUrl?.noteUrl ?? '');
  if (url.isNotEmpty) {
    for (var v in ids) {
      links.add('$url/share/note/$v');
    }
  }
  var shareLink = links.join('\n');
  logger.d(shareLink);
  // await Share.share(shareLink);
}

// 获取自己的senderUser
ShowUser getSenderUser({GUserModel? user}) {
  user ??= Global.user;
  if (user == null) return ShowUser();
  return ShowUser()
    ..nickname = user.nickname
    ..vipExpireTime = toInt(user.userExtend?.vipExpireTime)
    ..vipLevel = user.userExtend?.vipLevel
    ..vipBadge = user.userExtend?.vipBadge
    ..avatar = user.avatar;
}

// json转笔记列表数据
NoteItemData json2note(String? str) {
  str = str ?? '';
  late Notes notes;
  try {
    if (str.isEmpty || str.contains('[{"insert":"')) {
      notes = Notes();
    } else {
      notes = Notes.fromJson(jsonDecode(str));
    }
  } catch (e) {
    logger.d(e);
    notes = Notes();
  }
  return notes2noteItem(notes);
}

// 笔记转笔记列表类型
NoteItemData notes2noteItem(Notes notes) {
  var list = notes.items;
  if (list.isEmpty) return NoteItemData();
  var title = '';
  var text = '';
  var imageUrl = '';
  var cover = '';
  for (var v in list) {
    if (v.type == GNoteType.TEXT || v.type == GNoteType.TITLE) {
      if (title.isEmpty) {
        title = v.content ?? '';
      } else if (text.isEmpty) {
        text = v.content ?? '';
      }
    }
    if (v.type == GNoteType.IMAGE && imageUrl.isEmpty) {
      imageUrl = v.content ?? '';
    }
    if (v.type == GNoteType.VIDEO && cover.isEmpty) {
      cover = getVideoCover(v.content ?? '');
    }
    if (title.isNotEmpty &&
        text.isNotEmpty &&
        (imageUrl.isNotEmpty || cover.isNotEmpty)) {
      break;
    }
  }
  return NoteItemData(
    title: title,
    text: text,
    image: imageUrl,
    cover: cover,
  );
}

//生成materialColor
MaterialColor generateMaterialColor(Color baseColor) {
  // 根据基色创建不同的色调
  Color color50 = baseColor.withOpacity(0.1);
  Color color100 = baseColor.withOpacity(0.2);
  Color color200 = baseColor.withOpacity(0.3);
  Color color300 = baseColor.withOpacity(0.4);
  Color color400 = baseColor.withOpacity(0.5);
  Color color500 = baseColor.withOpacity(0.6);
  Color color600 = baseColor.withOpacity(0.7);
  Color color700 = baseColor.withOpacity(0.8);
  Color color800 = baseColor.withOpacity(0.9);
  Color color900 = baseColor.withOpacity(1.0);

  return MaterialColor(baseColor.value, {
    50: color50,
    100: color100,
    200: color200,
    300: color300,
    400: color400,
    500: color500,
    600: color600,
    700: color700,
    800: color800,
    900: color900,
  });
}

//文件大小单位显示计算
String b2size(double size) {
  if (size < 1024) {
    return '${size}B';
  }
  size = size / 1024;
  if (size < 1024) {
    return '${size.toStringAsFixed(1)}KB';
  }
  size = size / 1024;
  if (size < 1024) {
    return '${size.toStringAsFixed(1)}M';
  }
  size = size / 1024;
  if (size < 1024) {
    return '${size.toStringAsFixed(1)}G';
  }
  size = size / 1024;
  if (size < 1024) {
    return '${size.toStringAsFixed(1)}T';
  }
  return '';
}

bool isMobile() {
  if (platformPhone) {
    return true;
  }
  return false;
}

//判断输入是否纯数字
bool isDouble(String str) {
  return RegExp(r'^[0-9]+$').hasMatch(str);
}

//判断账号格式
bool accountFormat(String str) {
  return RegExp(r'[a-zA-Z]\w{3,15}$').hasMatch(str);
}

// 邮箱判断
bool isEmail(String input) {
  String regexEmail =
      '^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$';
  return RegExp(regexEmail).hasMatch(input);
}

//日期转后台时间戳
String date2time(DateTime? date) {
  date ??= DateTime.now();
  return (date.microsecondsSinceEpoch ~/ 1000000).toString();
}

bool is64BitSystem() {
  // 比较 int 类型的最大值是否大于 32 位整数的最大值
  var n = pow(2, 63) - 1;
  return n.toString() == '9223372036854775807';
}

//时间戳转最后在线时间
String time2onlineDate(String? time,
    {String joinStr = '', String zeroStr = ''}) {
  int timeInt = toInt(time);
  if (timeInt <= 0) return '';
  String str = '';
  DateTime nowTime = DateTime.now();
  int nowTimeInt = nowTime.millisecondsSinceEpoch ~/ 1000;
  var cTime = nowTimeInt - timeInt; //相差时间戳
  int minuteSecond = 60;
  int hourSecond = 60 * minuteSecond;
  int daySecond = 24 * hourSecond;
  var cMinute = cTime ~/ minuteSecond;
  var cHour = cTime ~/ hourSecond;
  var cDay = cTime ~/ daySecond;
  if (cMinute <= 10) {
    str = '0';
  } else if (cMinute < 60) {
    str = '分钟'.tr(args: [cMinute.toString()]);
  } else if (cHour < 24) {
    str = '小时'.tr(args: [cHour.toString()]);
  } else {
    str = '天'.tr(args: [cDay < 7 ? cDay.toString() : '7']);
  }
  // str = str != '0' ? '$str前$joinStr' : zeroStr;
  // if(str == '0') str = zeroStr;
  return str != '0' ? '前'.tr(args: [str, joinStr]) : zeroStr;
}

//判断显示日期格式
String time2formatDate(String? time) {
  // Int64 timeInt64 = Int64(time);
  if (time == null ||
      int.tryParse(time) == null ||
      time.isEmpty ||
      time == '0') {
    return '';
  }
  int timeInt = int.parse(time);
  String str = '';
  DateTime nowTime = DateTime.now();
  int year = nowTime.year;
  int month = nowTime.month;
  int day = nowTime.day;
  int daySecond = 24 * 60 * 60;
  int dayStart = (DateTime(year, month, day).millisecondsSinceEpoch / 1000)
      .floor(); //今天开始时间戳
  int yesterdayStart = dayStart - daySecond; //昨天开始时间戳
  int yesterdayBeforeStart = yesterdayStart - daySecond; //前天开始时间戳
  // int monthStart = (DateTime(year, month, 1).millisecondsSinceEpoch / 1000).floor(); //本月开始时间戳
  int yearStart =
      (DateTime(year, 1, 1).millisecondsSinceEpoch / 1000).floor(); //几年开始时间戳
  if (timeInt >= dayStart) {
    str = time2date(time, format: 'HH:mm');
  } else if (timeInt >= yesterdayStart) {
    str = '昨天 '.tr(args: [time2date(time, format: 'HH:mm')]);
  } else if (timeInt >= yesterdayBeforeStart) {
    str = '前天 '.tr(args: [time2date(time, format: 'HH:mm')]);
  } else if (timeInt >= yearStart) {
    str = time2date(time, format: 'MM-dd HH:mm');
  } else {
    str = time2date(time, format: 'yyyy-MM-dd HH:MM');
  }
  return str;
}

//等级枚举转文字
String level2str(GVipLevel? level) {
  switch (level) {
    case GVipLevel.NIL:
      return '';
    case GVipLevel.n1:
      return 'VIP1';
    case GVipLevel.n2:
      return 'VIP2';
    case GVipLevel.n3:
      return 'VIP3';
    case GVipLevel.n4:
      return 'VIP4';
    case GVipLevel.n5:
      return 'VIP5';
    case GVipLevel.n6:
      return 'VIP6';
  }
  return '';
}

//分 格式化金额
double toCny(String? money) {
  if (money == null || money.isEmpty) return 0;
  var dm = double.tryParse(money);
  if (dm == null) return 0;
  return dm / 100;
}

//格式化时间
String time2date(
  String? str, {
  int num = 1000,
  String format = 'yyyy-MM-dd HH:mm',
}) {
  if (str == null || int.tryParse(str) == null) return '';
  int n = int.parse(str);
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(n * num);
  return DateFormat(format).format(dt);
}

// 历史记录缩略显示
String history2Text(MessageItem e) {
  var content = e.content;
  if (e.type != GMessageType.TEXT) {
    content = messageType2text(e.type);
  }
  return '${e.nickname ?? ''}:$content';
}

//消息类型转文字
String messageType2text(GMessageType? type) {
  var str = messageType2textr(type);
  return str.isEmpty ? '' : '[$str]';
}

String messageType2textr(GMessageType? type) {
  switch (type) {
    case GMessageType.COLLECT:
      return '收藏'.tr();
    case GMessageType.FORWARD_ONE_BY_ONE:
      return '转发'.tr();
    case GMessageType.NIL:
      return '未知类型'.tr();
    case GMessageType.TEXT:
      return '文字'.tr();
    case GMessageType.IMAGE:
      return '图片'.tr();
    case GMessageType.AUDIO:
      return '语音'.tr();
    case GMessageType.VIDEO:
      return '视频'.tr();
    case GMessageType.FILE:
      return '文件'.tr();
    case GMessageType.LOCATION:
      return '位置'.tr();
    case GMessageType.USER_CARD:
      return '个人名片'.tr();
    case GMessageType.ROOM_CARD:
      return '群名片'.tr();
    case GMessageType.HISTORY:
      return '聊天记录'.tr();
    case GMessageType.NOTES:
      return '笔记'.tr();
    case GMessageType.RED_PACKET:
      return '红包'.tr();
    case GMessageType.RED_INTEGRAL:
      return '积分红包'.tr();
    case GMessageType.VIDEO_CALL:
      return '视频通话'.tr();
    case GMessageType.AUDIO_CALL:
      return '语音通话'.tr();
    case GMessageType.FORWARD_CIRCLE:
      return '圈子名片'.tr();
    case GMessageType.FRIEND_APPLY_PASS:
      return '申请已通过'.tr();
    case GMessageType.SHAKE:
      return '抖一抖'.tr();
    case GMessageType.ROOM_NOTICE_EXIT:
      return '提醒';
    case GMessageType.ROOM_NOTICE_JOIN:
      return '提醒';
    case GMessageType.GIVE_RELIABLE:
      return '收到靠谱草';
  }
  return '';
}

// 是否有该消息类型权限
bool messageHasPower(int power, GMessageType type) {
  if (power == -1) return true;
  var i = messageType2int(type);
  return power & i == i;
}

// 消息权限
int messageType2int(GMessageType? type) {
  switch (type) {
    case GMessageType.COLLECT:
    case GMessageType.FORWARD_ONE_BY_ONE:
    case GMessageType.NIL:
    case GMessageType.RED_INTEGRAL:
    case GMessageType.VIDEO_CALL:
    case GMessageType.AUDIO_CALL:
    case GMessageType.ROOM_NOTICE_JOIN:
    case GMessageType.ROOM_NOTICE_EXIT:
    case GMessageType.GIVE_RELIABLE:
    case GMessageType.FRIEND_APPLY_PASS:
      return 0;
    case GMessageType.TEXT:
      return 1 << 1;
    case GMessageType.IMAGE:
      return 1 << 2;
    case GMessageType.AUDIO:
      return 1 << 3;
    case GMessageType.VIDEO:
      return 1 << 4;
    case GMessageType.FILE:
      return 1 << 5;
    case GMessageType.LOCATION:
      return 1 << 6;
    case GMessageType.USER_CARD:
      return 1 << 7;
    case GMessageType.ROOM_CARD:
      return 1 << 8;
    case GMessageType.HISTORY:
      return 1 << 13;
    case GMessageType.NOTES:
      return 1 << 9;
    case GMessageType.RED_PACKET:
      return 1 << 10;
    case GMessageType.FORWARD_CIRCLE:
      return 1 << 14;
    case GMessageType.SHAKE:
      return 1 << 18;
  }
  return 0;
}

//底部选择
openSheetMenu(
  BuildContext context, {
  required List<String> list,
  Function(int)? onTap,
  String title = '',
  double titleSize = 13,
  Color? color,
}) {
  var myColors = ThemeNotifier();
  color = color ?? myColors.textGrey;
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: myColors.themeBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        color: color,
                      ),
                    ),
                  ),
                for (var i = 0; i < list.length; i++)
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (onTap != null) onTap(i);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      // decoration: BoxDecoration(
                      //   border: i != list.length - 1
                      //       ? const Border(
                      //           bottom: BorderSide(
                      //             color: myColors.lineGrey,
                      //             width: .5,
                      //           ),
                      //         )
                      //       : null,
                      // ),
                      child: Text(list[i]),
                    ),
                  ),
                Container(
                  height: 5,
                  margin: const EdgeInsets.only(top: 10),
                  color: myColors.tagColor,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Text(
                      '取消'.tr(),
                      style: TextStyle(
                        color: myColors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

//接口性别类型转文本
String sex2text(GSex? sex) {
  if (sex == null) {
    return '保密'.tr();
  }
  switch (sex) {
    case GSex.BOY:
      return '男'.tr();
    case GSex.GIRL:
      return '女'.tr();
    case GSex.UNKNOWN:
      return '保密'.tr();
  }
  return '';
}

//秒转分钟
second2minute(int second) {
  var m = (second ~/ 60).toString();
  var s = (second % 60).toString();
  m = m.length <= 1 ? '0$m' : m;
  s = s.length <= 1 ? '0$s' : s;
  return '$m:$s';
}

//秒转分钟
second2minute2(int second) {
  var m = (second ~/ 60).toString();
  var s = (second % 60).toString();
  m = m.length <= 1 ? m : m;
  s = s.length <= 1 ? '0$s' : s;
  return '分秒'.tr(args: [m, s]);
}

//loading
Future<void> loading({String? text}) async {
  await EasyLoading.show(
    status: text,
    maskType: EasyLoadingMaskType.none,
  );
}

//关闭loading
loadClose() {
  EasyLoading.dismiss();
}

//错误提示
bool tipWait = false;

tip(String text) async {
  if (tipWait) return;
  tipWait = true;
  const duration = Duration(seconds: 3);
  EasyLoading.showToast(
    text,
    duration: duration,
  );
  await Future.delayed(duration);
  tipWait = false;
}

//错误提示
tipError(String text) {
  EasyLoading.showError(text, duration: const Duration(seconds: 3));
}

//成功提示
tipSuccess(String text) {
  EasyLoading.showSuccess(text, duration: const Duration(seconds: 3));
}

//对话框
Future<bool?> confirm(
  BuildContext context, {
  String title = '提示',
  String content = '',
  String cancel = '取消',
  String enter = '确定',
  Function()? onCancel,
  Function()? onEnter,
}) async {
  var myColors = ThemeNotifier();
  if (Platform.isIOS || Platform.isMacOS) {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title.tr()),
          content: Text(content.tr()),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, false);
                if (onCancel != null) onCancel();
              },
              child: Text(
                cancel.tr(),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, true);
                if (onEnter != null) onEnter();
              },
              child: Text(enter.tr()),
            ),
          ],
        );
      },
    );
  }
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title.tr()),
        content: Text(content.tr()),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context, false);
              if (onCancel != null) onCancel();
            },
            child: Text(
              cancel.tr(),
            ),
          ),
          MaterialButton(
            color: myColors.imGreen2,
            onPressed: () {
              Navigator.pop(context, true);
              if (onEnter != null) onEnter();
            },
            child: Text(
              enter.tr(),
              style: TextStyle(
                color: myColors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}

//版本号转int
int version2int(String version) {
  if (!version.contains('.')) return 0;
  var gv = version.split('.').map((e) {
    return toInt(e);
  }).toList();
  int versionInt = 0;
  try {
    versionInt = gv[0] * 1000000 + gv[1] * 1000 + gv[2];
  } catch (e) {
    logger.d(e);
  }
  return versionInt;
}

//获取视频封面
String getVideoCover(String url) {
  if (!urlValid(url)) {
    return '';
  }
  var uri = Uri.parse(url);
  var origin = uri.origin;
  url = '${url.replaceAll(origin, '$origin/process')}.jpg';
  return url;
}

// bool urlValid(String url) {
//   try {
//     final uri = Uri.parse(url);
//     return uri.isAbsolute;
//   } catch (e) {
//     return false;
//   }
// }

bool urlValid(String input) {
  Uri? uri;
  try {
    uri = Uri.parse(input);
  } catch (e) {
    return false;
  }
  return uri.hasScheme && uri.hasAuthority;
}

// 字符串转int
int str2int(String? str) {
  if (str == null || str.isEmpty) return 0;
  return int.tryParse(str) ?? 0;
}

// 字符串转double
double str2double(String? str) {
  if (str == null || str.isEmpty) return 0;
  return double.tryParse(str) ?? 0;
}

String toStr(dynamic v) {
  return v == null ? '' : v.toString();
}

int toInt(dynamic v) {
  return v == null ? 0 : str2int(v.toString());
}

double toDouble(dynamic v) {
  return v == null ? 0 : str2double(v.toString());
}

bool toBool(GSure? v) {
  if (v == null) return false;
  return v == GSure.YES;
}

GSure toSure(bool? v) {
  if (v == null) return GSure.NO;
  return v ? GSure.YES : GSure.NO;
}

bool containsAllFlags(int v, int x) {
  return (v & x) == x;
}

const base32Chars = '0123456789abcdefghijklmnopqrstuv';

String toBase32(int n) {
  var result = '';
  while (n > 0) {
    var remainder = n % 32;
    result = base32Chars[remainder] + result;
    n = n ~/ 32;
  }

  // Ensure the result is 8 characters long, if not, prepend 0's
  while (result.length < 8) {
    result = '0$result';
  }

  return result;
}

int fromBase32(String s) {
  var result = 0;
  var multiplier = 1;
  for (var i = s.length - 1; i >= 0; i--) {
    var index = base32Chars.indexOf(s[i]);
    result += index * multiplier;
    multiplier *= 32;
  }
  return result;
}

//生成对话id
String generatePairId(int a, int b) {
  assert(a > 0 || b > 0, 'a and b must be greater than 0');
  assert(a != b, 'a and b must not be equal');
  if (a > b) {
    var temp = a;
    a = b;
    b = temp; // Swap values
  }

  // Convert a and b to base 32 and concatenate them, each number is converted to an 8 character string
  return toBase32(a) + toBase32(b);
}

List<int> extractIntegersFromPairId(String pairId) {
  if (pairId.length != 16) {
    return [0, 0]; // 无效的输入
  }

  // 分解字符串，并分别转换回10进制
  int a = fromBase32(pairId.substring(0, 8));
  int b = fromBase32(pairId.substring(8, 16));

  return [a, b];
}

//显示用户账号/靓号
String showAccount(String? account, String? userNumber) {
  account ??= '';
  userNumber ??= '';
  if (userNumber.isNotEmpty) return userNumber;
  if (account.isNotEmpty) return account;
  return '';
}

// 获取安卓存储权限
Future<bool> androidStorage() async {
  var status = await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    return true;
  }
  status = await Permission.storage.request();
  if (status.isGranted) {
    return true;
  }
  confirm(
    Global.context!,
    content: '未检查到保存权限，点击确定前往设置。',
    onEnter: () {
      openAppSettings();
    },
  );
  return false;
}

//判断权限
Future<bool> devicePermission(List<Permission> permission,
    {bool tip = true}) async {
  if (Platform.isMacOS) {
    return true;
  }
  if (permission.isEmpty) return true;
  confirmError(String t) {
    if (tip) {
      confirm(
        Global.context!,
        content: t,
        onEnter: () {
          openAppSettings();
        },
      );
    }
  }

  late Map<Permission, PermissionStatus> statuses;
  try {
    statuses = await permission.request();
  } catch (e) {
    logger.d(e);
    return false;
  }
  var location = Permission.location;
  if (permission.contains(location)) {
    var status = statuses[location];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到定位权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开定位权限'.tr());
      return false;
    }
  }
  var microphone = Permission.microphone;
  if (permission.contains(microphone)) {
    var status = statuses[microphone];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到麦克风权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开麦克风权限'.tr());
      return false;
    }
  }
  var camera = Permission.camera;
  if (permission.contains(camera)) {
    var status = statuses[camera];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到摄像头权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开摄像头权限'.tr());
      return false;
    }
  }
  var photos = Permission.photos;
  if (permission.contains(photos)) {
    var status = statuses[photos];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到相册权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开相册权限'.tr());
      return false;
    }
  }
  var newStorage = Permission.manageExternalStorage;
  if (permission.contains(newStorage)) {
    var status = statuses[newStorage];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到保存权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开保存权限'.tr());
      return false;
    }
  }
  var storage = Permission.storage;
  if (permission.contains(storage)) {
    var status = statuses[storage];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到保存权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      if (tip) tipError('未打开保存权限'.tr());
      return false;
    }
  }
  var manageExternalStorage = Permission.manageExternalStorage;
  if (permission.contains(manageExternalStorage)) {
    var status = statuses[manageExternalStorage];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到访问外部存储权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      tipError('未打开访问外部存储权限'.tr());
      return false;
    }
  }
  var requestInstallPackages = Permission.requestInstallPackages;
  if (permission.contains(requestInstallPackages)) {
    var status = statuses[requestInstallPackages];
    if (status!.isPermanentlyDenied) {
      confirmError('未检查到允许安装APK文件权限，点击确定前往设置。'.tr());
      return false;
    }
    if (!status.isGranted) {
      tipError('未打开允许安装APK文件权限'.tr());
      return false;
    }
  }
  return true;
}

//底部选择框
void openSelect(
  BuildContext context, {
  required List<String> list,
  int index = 0,
  Function(int)? onEnter,
}) {
  var myColors = ThemeNotifier();
  var scrollController = FixedExtentScrollController(initialItem: index);
  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return Container(
        height: 240,
        // color: CupertinoColors.systemBackground.resolveFrom(context),
        color: myColors.themeBackgroundColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消'.tr(),
                    style: TextStyle(
                      color: myColors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (onEnter != null) onEnter(scrollController.selectedItem);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '确定'.tr(),
                    style: TextStyle(color: myColors.primary),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: CupertinoPicker(
                scrollController: scrollController,
                itemExtent: 32.0,
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                // This is called when selected item is changed.
                onSelectedItemChanged: (selectedItem) {},
                children: list.map((e) {
                  return Center(
                      child: Text(
                    e,
                    style: TextStyle(
                      color: myColors.iconThemeColor,
                    ),
                  ));
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

enum AppFileType {
  image,
  video,
  other,
}

//通过文件路径判断文件类型
AppFileType getFileType(String path) {
  var extension = path.split('.').last;

  List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif', 'bmp', 'webp'];
  List<String> videoExtensions = ['mp4', 'mov', 'mkv', 'flv', 'avi', 'wmv'];

  if (imageExtensions.contains(extension.toLowerCase())) {
    return AppFileType.image;
  } else if (videoExtensions.contains(extension.toLowerCase())) {
    return AppFileType.video;
  } else {
    return AppFileType.other;
  }
}

//windows获取本地视频时长
getVideoDuration(
  String path, {
  Function(int)? success,
}) async {
  StreamSubscription<vlc.PositionState>? sub;
  var player = vlc.Player(id: randomNumber(1000000000))..setVolume(0);
  stop(vlc.PositionState event) {
    var seconds = event.duration?.inSeconds ?? 0;
    if (seconds <= 0) return;
    sub?.cancel();
    player.stop();
    if (success != null) success(seconds);
  }

  sub = player.positionStream.listen((event) {
    player.setVolume(0);
    stop(event);
  });
  player.setVolume(0);
  player.open(
    vlc.Media.file(
      File(path),
    ),
    autoStart: true,
  );
}

pcNotifier(GChatModel data) async {
  if (!noticeOpen) return;
  if (!Platform.isWindows && !Platform.isMacOS) return;
  await _pcNotifier(data);
}

Completer<void>? _pcNotifierCompleter;

//pc消息通知
_pcNotifier(GChatModel data) async {
  if (_pcNotifierCompleter != null && !_pcNotifierCompleter!.isCompleted) {
    return _pcNotifierCompleter!.future;
  }
  _pcNotifierCompleter = Completer<void>();
  var roomId = data.receiverRoomId ?? '';
  var room = roomId.isNotEmpty && roomId != '0';
  var message = Message();
  var id = (room ? roomId : data.sender) ?? '';
  var pairId = message.pairId ?? '';
  if (pairId.isEmpty) {
    if (room) {
      pairId = generatePairId(0, toInt(roomId));
    } else {
      logger.d(id);
      pairId = generatePairId(toInt(Global.user?.id ?? ''), toInt(id));
    }
  }
  var content = message.content ?? '';
  if (data.type != GChatType.TEXT) {
    content = messageType2text(message.type!);
  }
  var nickName = message.senderUser?.nickname ?? '';
  var mark = message.senderUser?.mark ?? '';
  LocalNotification notification = LocalNotification(
    title: mark.isNotEmpty ? mark : nickName,
    body: content,
  );
  notification.onClick = () {
    windowManager.show();
    MessageUtil.resetUnreadCount([pairId]);
    ApiRequest.apiMessageRead([pairId]);
    var params = ChatTalkParams(
      name: nickName,
      mark: mark,
    );
    if (room) {
      params.roomId = roomId;
    } else {
      params.receiver = id;
    }
    Adapter.navigatorTo(ChatTalk.path, arguments: params);
  };
  List<Future> futures = [
    notification.show(),
    Future.delayed(const Duration(seconds: 3)),
  ];
  await Future.wait(futures);
  _pcNotifierCompleter!.complete();
}

// 获取随机数
randomNumber(int max) {
  var rng = Random();
  return rng.nextInt(max);
}

//获取uint8list图片格式
String bytesImageGetFormat(Uint8List imageBytes) {
  if (imageBytes.length < 4) {
    return '';
  }
  if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
    return 'jpeg';
  }
  if (imageBytes[0] == 0x89 &&
      imageBytes[1] == 0x50 &&
      imageBytes[2] == 0x4E &&
      imageBytes[3] == 0x47) {
    return 'png';
  }
  if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46) {
    return 'gif';
  }
  if (imageBytes[0] == 0x42 && imageBytes[1] == 0x4D) {
    return 'bmp';
  }
  if (imageBytes[0] == 0x52 &&
      imageBytes[1] == 0x49 &&
      imageBytes[2] == 0x46 &&
      imageBytes[3] == 0x46 &&
      imageBytes[8] == 0x57 &&
      imageBytes[9] == 0x45 &&
      imageBytes[10] == 0x42 &&
      imageBytes[11] == 0x50) {
    return 'webp';
  }
  return '';
}

String assetPath(String fileName) {
  if (!Global.isRunningInPackage) {
    return 'assets/$fileName';
  } else {
    return 'packages/im_core/assets/$fileName';
  }
}

String zombieAvatar(String userId) {
  var i = toInt(userId) % 1136;
  return assetPath('images/avatar/$i.jpg');
}

// 关键词屏蔽
bool banSpeakHas(String str) {
  str = str.replaceAll(' ', '').replaceAll('\n', '');
  for (var v in Global.banSpeakList) {
    if (str.contains(v)) {
      tipError('敏感词汇无法发送');
      return true;
    }
  }
  return false;
}

// 转json
Map? str2map(String str) {
  try {
    return jsonDecode(str);
  } catch (e) {
    return null;
  }
}

//生成带有分享码的二维码地址
String createScanUrl({
  required String type,
  required String data,
}) {
  String url =
      '${Global.systemInfo.appVersion?.appVersion?.shareUrl ?? ''}?${Global.shareCodeName}=${Global.user!.uid}&'
      'type=$type&data=$data&target=feiou';
  // logger.i(url);
  return url;
}

//二维码扫描结果
bool getResult(String result, BuildContext context) {
  // var name = Global.shareCodeName;
  var name = 'feiou';
  var str = result;
  String data = '';
  String type = '';
  String loginToken = '';
  String account = '';
  // logger.i(str);
  if (str.isEmpty || !str.contains(name)) return false;
  if (urlValid(str)) {
    List a = str.split('&');
    for (var v in a) {
      if (v.toString().contains('data')) {
        data = v.toString().split('=')[1];
      }
      if (v.toString().contains('type')) {
        type = v.toString().split('=')[1];
      }
    }
    if (type == 'helpFriend') {
      List l = data.toString().split(',');
      loginToken = l[0];
      account = l[1];
    }
  } else {
    try {
      Map v = json.decode(str);
      if (v['imUser'] != null) {
        type = 'imUser';
        data = v['imUser'];
      }
      if (v['imRoom'] != null) {
        type = 'imRoom';
        data = v['imRoom'];
      }
      if (v['authorization'] != null) {
        type = 'authorization';
        data = v['authorization'];
      }
      if (v['loginToken'] != null && v['account'] != null) {
        type = 'helpFriend';
        loginToken = v['loginToken'];
        account = v['account'];
      }
    } catch (e) {
      logger.d(e);
      return false;
    }
  }
  if (type == 'imUser') {
    Navigator.pushReplacementNamed(
      context,
      FriendDetails.path,
      arguments: {'id': data, 'friendFrom': 'QR'},
    );
    return true;
  } else if (type == 'imRoom') {
    Navigator.pushReplacementNamed(
      context,
      GroupCard.path,
      arguments: {
        'roomId': data,
        'roomFrom': 'QR',
        'isCard': false,
      },
    );
    return true;
  } else if (type == 'authorization') {
    Navigator.pop(context);
    ApiRequest.authorizationLogin(data);
    return true;
  } else if (type == 'helpFriend') {
    Navigator.pop(context);
    ApiRequest.helpFriendSetPassword(loginToken, account);
    return true;
  } else {
    return false;
  }

  // if (v['imUser'] != null) {
  //   Navigator.pushReplacementNamed(
  //     context,
  //     FriendDetails.path,
  //     arguments: {'id': v['imUser'], 'friendFrom': 'QR'},
  //   );
  //   return true;
  // }
  // if (v['imRoom'] != null) {
  //   Navigator.pushReplacementNamed(
  //     context,
  //     GroupCard.path,
  //     arguments: {
  //       'roomId': v['imRoom'],
  //       'roomFrom': 'QR',
  //       'isCard': false,
  //     },
  //   );
  //   return true;
  // }
  // if (v['authorization'] != null) {
  //   Navigator.pop(context);
  //   logger.i(v['authorization']);
  //   ApiRequest.authorizationLogin(v['authorization']);
  //   return true;
  // }
  // if (v['loginToken'] != null && v['account'] != null) {
  //   Navigator.pop(context);
  //   logger.i(v['loginToken']);
  //   logger.i(v['account']);
  //   ApiRequest.helpFriendSetPassword(v['loginToken'], v['account']);
  //   return true;
  // } else {
  //   return false;
  // }
}

// 获取消息转发标题
String messageHistory2text(MessageHistory? history) {
  if (history == null) return '';
  if (history.isRoom == true) {
    return '[群聊]${'的聊天记录'.tr(args: [history.nameA ?? ''])}';
  } else {
    return '和的聊天记录'.tr(args: [history.nameA ?? '', history.nameB ?? '']);
  }
}

// 延迟执行数据请求
futureDelayFunction(Function() call) {
  Future.delayed(const Duration(milliseconds: 500), call);
}

// 判断两个 DateTime 是否属于同一天
bool sameDayCheck(int timeA, int timeB) {
  DateTime dateA = DateTime.fromMillisecondsSinceEpoch(timeA * 1000);
  DateTime dateB = DateTime.fromMillisecondsSinceEpoch(timeB * 1000);
  return dateA.year == dateB.year &&
      dateA.month == dateB.month &&
      dateA.day == dateB.day;
}

// channel转chatItem
ChatItemData channel2chatItem(Channel v) {
  var roomId = toInt(v.relateRoomId) > 0 ? v.relateRoomId.toString() : '';
  var userId = toInt(v.relateUserId) > 0 ? v.relateUserId.toString() : '';
  var room = roomId.isNotEmpty;
  var user = v.senderUser;
  var content = '';
  var time = '';
  var chat = v.lastMessage;
  if (chat != null) {
    time = toInt(chat.createTime) > 0 ? chat.createTime.toString() : '';
    content = chat.content ?? '';
    if (chat.type != GMessageType.TEXT) {
      content = chat.type == null ? '' : messageType2text(chat.type);
    }
    if (room) {
      if (chat.type == GMessageType.FRIEND_APPLY_PASS) {
        content = '[新人进群]'.tr();
      }
      var srn = chat.roomNickname ?? '';
      var mark = chat.mark ?? '';
      var sn = mark.isEmpty ? chat.nickname ?? '' : mark;
      var name = srn.isEmpty ? sn : srn;
      if (chat.sender.toString() == Global.user!.id) name = '我'.tr();
      if (name.isNotEmpty) content = '$name:$content';
    }
  }
  var item = ChatItemData(
    draft: chatEditText[v.pairId] ?? '',
    id: room ? roomId : userId,
    title: v.name ?? '',
    mark: v.mark ?? '',
    icons: [v.avatar ?? ''],
    pairId: v.pairId,
    room: room,
    text: content,
    time: time2formatDate(time),
    notReadNumber: v.unreadCount,
    isTop: toInt(v.topTime) > 0,
    doNotDisturb: v.doNotDisturb,
    goodNumber: (user?.userNumber ?? '').isNotEmpty,
    numberType: user?.userNumberType ?? GUserNumberType.NIL,
    userNumber: user?.userNumber ?? '',
    circleGuarantee: toBool(user?.circleGuarantee),
    vip: toInt(user?.vipExpireTime) >= toInt(date2time(null)),
    vipLevel: user?.vipLevel ?? GVipLevel.NIL,
    vipBadge: user?.vipBadge ?? GBadge.NIL,
    onlyName: user?.useChangeNicknameCard ?? false,
    userType: UserTypeExt.formMerchantType(user?.customerType),
    at: v.atMessageIds.isNotEmpty,
    atMessageId: v.atMessageIds.isNotEmpty ? v.atMessageIds[0].toString() : '',
    readId: v.otherReadId ?? 0,
    group: v.groups,
  );
  if (room) {
    item.time = time2formatDate(time);
  }
  return item;
}

// 获取粘贴板邀请码
Future<String> getClipboardShareCode() async {
  var data = await Clipboard.getData('text/plain');
  var name = Global.shareCodeName;
  var str = data?.text ?? '';
  String b = '';
  logger.i(str);
  if (str.isEmpty || !str.contains(name) || !str.contains('=')) return '';
  List a = str.split('&');
  for (var v in a) {
    if (v.toString().contains('feiou_code')) {
      b = v.toString();
      logger.i(b.split('=')[1]);
    }
  }
  return b.split('=')[1];
}

// 是否包含汉字
bool containsChinese(String input) {
  RegExp exp = RegExp(r'[\u4e00-\u9fff]');
  return exp.hasMatch(input);
}

bool updateDialog = false;

//vip等级阶段气泡
vipStageBubble(GVipLevel vipLevel) {
  switch (vipLevel) {
    case GVipLevel.NIL:
      return;
    case GVipLevel.n1:
      return ThemeNotifier().chatBubble1;
    case GVipLevel.n2:
      return ThemeNotifier().chatBubble1;
    case GVipLevel.n3:
      return ThemeNotifier().chatBubble2;
    case GVipLevel.n4:
      return ThemeNotifier().chatBubble2;
    case GVipLevel.n5:
      return ThemeNotifier().chatBubble3;
    case GVipLevel.n6:
      return ThemeNotifier().chatBubble3;
  }
  return;
}

//vip等级阶段字体
vipStageText(GVipLevel vipLevel) {
  switch (vipLevel) {
    case GVipLevel.NIL:
      return;
    case GVipLevel.n1:
      return ThemeNotifier().vipText1;
    case GVipLevel.n2:
      return ThemeNotifier().vipText1;
    case GVipLevel.n3:
      return ThemeNotifier().vipText2;
    case GVipLevel.n4:
      return ThemeNotifier().vipText2;
    case GVipLevel.n5:
      return ThemeNotifier().vipText3;
    case GVipLevel.n6:
      return ThemeNotifier().vipText3;
  }
  return;
}

// 获取对话参数
ChatTalkParams chat2talkParams(ChatItemData e) {
  var params = ChatTalkParams(
    pairId: e.pairId ?? '',
    name: e.title,
    mark: e.mark,
    userNumber: e.userNumber,
    remindId: e.atMessageId,
    // queryId: e.atMessageId,
    readId: e.readId,
    onlyName: e.onlyName,
    vip: e.vip,
    vipLevel: e.vipLevel,
    vipBadge: e.vipBadge,
    numberType: e.numberType,
    circleGuarantee: e.circleGuarantee,
    isTop: e.isTop,
    doNotDisturb: e.doNotDisturb,
  );
  if (e.room) params.roomId = e.id ?? '';
  if (!e.room) params.receiver = e.id ?? '';
  return params;
}
