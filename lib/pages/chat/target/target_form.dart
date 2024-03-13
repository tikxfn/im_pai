import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/dialog_widget.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class ChatTargetForm extends StatefulWidget {
  const ChatTargetForm({super.key});

  static const String path = 'chat/target/form';

  @override
  State<ChatTargetForm> createState() => _ChatTargetFormState();
}

class _ChatTargetFormState extends State<ChatTargetForm> {
  TextEditingController nameCtr = TextEditingController();

  //勾选列表
  List<String> choice = [];

  //勾选列表
  List<ChatItemData> activeIds = [];
  String oldGroupName = '';
  String keywords = '';
  List<ChatItemData> _channel = [];

  // 获取channel
  _getChannel() async {
    if (!mounted) return;
    _channel = (await MessageUtil.listAllChannel()).map((e) {
      var v = channel2chatItem(e);
      if (oldGroupName.isNotEmpty) {
        if (v.group != null && v.group!.contains(oldGroupName)) {
          choice.add(v.pairId!);
        }
      }
      return v;
    }).toList();
    setState(() {});
  }

  List<String> systemList = ['消息', '未读', '单聊', '群聊'];
  // 保存分组
  _saveGroup() async {
    if (nameCtr.text.trim().isEmpty) {
      tipError('请输入组名'.tr());
      return;
    }
    if (systemList.contains(nameCtr.text.trim())) {
      tipError('系统已预设该分组'.tr());
      return;
    }
    loading();
    try {
      await MessageUtil.editGroup(choice, oldGroupName, nameCtr.text);
      if (mounted) Navigator.pop(context);
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
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      oldGroupName = args['oldGroupName'] ?? '';
      if (oldGroupName.isNotEmpty) {
        nameCtr.text = oldGroupName;
      }
      _getChannel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return KeyboardBlur(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            oldGroupName.isEmpty ? '新增聊天分组'.tr() : oldGroupName,
          ),
        ),
        body: ThemeBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //搜索框
              SearchInput(
                onChanged: (str) {
                  setState(() {
                    keywords = str;
                  });
                },
              ),
              //勾选列表
              if (activeIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < activeIds.length; i++)
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: AppAvatar(
                                    list: activeIds[i].icons,
                                    size: 41,
                                    userName: activeIds[i].title,
                                    userId: activeIds[i].id ?? '',
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      choice.remove(activeIds[i].pairId);
                                      activeIds.removeAt(i);
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
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              //列表
              Expanded(
                flex: 1,
                child: ListView(
                  children: _channel.map((e) {
                    var v = ChatItemData(
                      id: e.id,
                      pairId: e.pairId,
                      icons: e.icons,
                      title: e.title,
                      mark: e.mark,
                      vip: e.vip,
                      vipLevel: e.vipLevel,
                      vipBadge: e.vipBadge,
                      goodNumber: e.goodNumber,
                      circleGuarantee: e.circleGuarantee,
                      numberType: e.numberType,
                      userNumber: e.userNumber,
                      room: e.room,
                    );
                    var active = choice.contains(v.pairId);
                    return e.group == null || !e.group!.contains(oldGroupName)
                        ? v.title.contains(keywords)
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (active) {
                                    var i = -1;
                                    for (var a in activeIds) {
                                      if (a.pairId == v.pairId) {
                                        i = activeIds.indexOf(a);
                                      }
                                    }
                                    choice.remove(v.pairId);
                                    if (i != -1) activeIds.removeAt(i);
                                  } else {
                                    choice.add(v.pairId!);
                                    activeIds.add(e);
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  color: choice.contains(e.pairId)
                                      ? myColors.listCheckedBg
                                      : null,
                                  child: Row(
                                    children: [
                                      AppCheckbox(
                                        value: active,
                                        paddingLeft: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: ChatItem(
                                          avatarSize: 46,
                                          data: v,
                                          hasSlidable: false,
                                          titleSize: 16,
                                          border: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container()
                        : Container();
                  }).toList(),
                ),
              ),
              BottomButton(
                title: '保存',
                disabled: choice.isEmpty,
                onTap: () {
                  if (choice.isEmpty) return;
                  if (oldGroupName.isEmpty) {
                    showDialogWidget(
                      context: context,
                      child: updateNameWidget(),
                    );
                  } else {
                    _saveGroup();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  //修改名称弹窗样式
  Widget updateNameWidget() {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: myColors.themeBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //标题
          Stack(
            alignment: Alignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '分组名称:'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: myColors.iconThemeColor,
                  ),
                ),
              ]),
              Positioned(
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: myColors.iconThemeColor,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: AppTextarea(
              hintText: '请输入名称'.tr(),
              controller: nameCtr,
              radius: 15,
              maxLength: null,
              minLines: 1,
            ),
          ),
          //按钮
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: CircleButton(
              theme: AppButtonTheme.blue,
              title: '确定'.tr(),
              height: 40,
              fontSize: 14,
              onTap: () {
                Navigator.pop(context);
                _saveGroup();
              },
            ),
          ),
        ],
      ),
    );
  }
}
