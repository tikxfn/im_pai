import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/friend/friend_label_members_update.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/contact_list.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class FriendLabelMembers extends StatefulWidget {
  const FriendLabelMembers({super.key});

  static const String path = 'friends/label_members';

  @override
  State<StatefulWidget> createState() {
    return _FriendLabelMembersState();
  }
}

class _FriendLabelMembersState extends State<FriendLabelMembers> {
  String label = '';
  List<GUserModel> labelMembersData = [];
  final TextEditingController _controller = TextEditingController();

  //获取列表
  getList() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userListLabelFriend(
        V1ListLabelFriendArgs(
          label: label,
        ),
      );
      labelMembersData = res?.list ?? [];
      logger.i(labelMembersData);
      if (!mounted) return;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //删除标签
  delete() async {
    confirm(
      context,
      title: '确定要删除此标签？'.tr(),
      onEnter: () async {
        final api = UserApi(apiClient());
        loading();
        try {
          await api.userCleanLabel(
            V1CleanLabelFriendArgs(
              label: [label],
            ),
          );
          if (!mounted) return;
          if (mounted) Navigator.pop(context);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  //修改标签
  update() async {
    List<String> groupList = [];
    for (var v in labelMembersData) {
      groupList.add(v.id.toString());
    }
    final api = UserApi(apiClient());
    loading();
    try {
      await api.userUpdateLabel(
        V1UpdateLabelArgs(
          label: _controller.text,
          oldLabel: label,
          userId: groupList,
        ),
      );
      if (!mounted) return;
      if (mounted) getList();
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
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      label = args['label'] ?? '';
      _controller.text = label;
      getList();
    });
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
    Color primary = myColors.primary;
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(label == '' ? '未设置标签的朋友'.tr() : '编辑标签'.tr()),
        actions: [
          if (label.isNotEmpty)
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                update();
              },
              child: Text(
                '保存'.tr(),
                style: TextStyle(color: myColors.primary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ThemeBody(
          child: Column(
            children: [
              if (label != '')
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
                    AppInput(
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
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '成员'.tr(),
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              var result = await Navigator.pushNamed(
                                context,
                                FriendLabelMembersUpdate.path,
                                arguments: {
                                  'labelMembersData': labelMembersData
                                },
                              );
                              if (result == null) return;
                              labelMembersData = result as List<GUserModel>;
                              logger.i(labelMembersData);
                              setState(() {});
                            },
                            child: Text(
                              '管理'.tr(),
                              style: TextStyle(
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: KeyboardBlur(
                  child: Container(
                    color: bgColor,
                    child: ContactList(
                      list: const [],
                      orderList: [
                        for (var e in labelMembersData)
                          ContractData(
                            widget: ChatItem(
                              titleSize: 16,
                              avatarSize: 38,
                              paddingLeft: 16,
                              hasSlidable: false,
                              data: ChatItemData(
                                id: e.id,
                                icons: [e.avatar ?? ''],
                                title: e.nickname ?? '',
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': e.id,
                                    'detail': e,
                                  },
                                ).then((value) {
                                  // getList();
                                });
                              },
                            ),
                            name: e.nickname ?? '',
                          )
                      ],
                    ),
                  ),
                ),
              ),
              if (label != '') _deleteWidget(),
            ],
          ),
        ),
      ),
    );
  }

  //底部删除按钮
  _deleteWidget() {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: delete,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 10,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: myColors.red,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          '删除标签'.tr(),
          style: TextStyle(
            fontSize: 15,
            color: myColors.white,
          ),
        ),
      ),
    );
  }
}
