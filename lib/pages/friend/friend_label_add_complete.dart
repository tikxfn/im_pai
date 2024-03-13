import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_label.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/keyboard_blur.dart';

class FriendLabelAddComplete extends StatefulWidget {
  const FriendLabelAddComplete({super.key});

  static const String path = 'friends/label_add_complete';

  @override
  State<StatefulWidget> createState() {
    return _FriendLabelAddCompleteState();
  }
}

class _FriendLabelAddCompleteState extends State<FriendLabelAddComplete> {
  //勾选列表
  List<ChatItemData> activeIds = [];

  //文本控制器
  final TextEditingController _controller = TextEditingController();

  //保存标签
  addGroup() async {
    List<String> groupList = [];
    for (var v in activeIds) {
      groupList.add(v.id.toString());
    }
    final api = UserApi(apiClient());
    loading();
    try {
      await api.userAddLabelUser(
        V1AddLabelUserArgs(
          label: _controller.text,
          userId: groupList,
        ),
      );
      if (!mounted) return;
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName(FriendLabel.path));
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
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
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('保存为标签'.tr()),
        actions: [
          TextButton(
            onPressed: _controller.text.isNotEmpty ? addGroup : null,
            child: Text(
              '保存'.tr(),
              style: TextStyle(
                color: _controller.text.isNotEmpty
                    ? myColors.primary
                    : myColors.textGrey,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        '标签名字'.tr(),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppInput(
                        controller: _controller,
                        borderTop: false,
                        horizontal: 15,
                        hintText: '请输入'.tr(),
                        onChanged: (value) {
                          setState(() {});
                        },
                        clear: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Text(
                        '成员'.tr(),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 13,
                    runSpacing: 13,
                    children: activeIds.map((e) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: AppAvatar(
                              list: e.icons,
                              size: 38,
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
                                height: 15,
                                width: 15,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Positioned(
                          //   right: 0,
                          //   top: 0,
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       setState(() {
                          //         activeIds.remove(e);
                          //       });
                          //     },
                          //     child: const Icon(
                          //       Icons.close,
                          //       size: 14,
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
