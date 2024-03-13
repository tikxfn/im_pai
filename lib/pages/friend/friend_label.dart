import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_label_add.dart';
import 'package:unionchat/pages/friend/friend_label_members.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/search_input.dart';

class FriendLabel extends StatefulWidget {
  const FriendLabel({super.key});

  static const String path = 'friends/label';

  @override
  State<StatefulWidget> createState() {
    return _FriendLabelState();
  }
}

class _FriendLabelState extends State<FriendLabel> {
  String keywords = '';
  List<ListLabelRespListLabelItem> labelData = [];
  List<ListLabelRespListLabelItem> activeIds = [];
  bool showDelete = false; //显示删除样式

  //获取列表
  getList() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userListLabel({});

      logger.i(res);
      labelData = res?.list ?? [];
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //选择用户
  onChoose(ListLabelRespListLabelItem e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //删除标签
  delete() async {
    if (activeIds.isEmpty) return;
    confirm(
      context,
      title: '确定要删除选择的标签？'.tr(),
      onEnter: () async {
        List<String> groupList = [];
        for (var v in activeIds) {
          groupList.add(v.name.toString());
        }
        final api = UserApi(apiClient());
        loading();
        try {
          await api.userCleanLabel(
            V1CleanLabelFriendArgs(
              label: groupList,
            ),
          );
          if (!mounted) return;
          if (mounted) getList();
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(showDelete ? '管理标签'.tr() : '通讯录标签'.tr()),
        leading: GestureDetector(
          onTap: () {
            showDelete
                ? setState(() {
                    showDelete = !showDelete;
                  })
                : Navigator.pop(context);
          },
          child: Icon(
            showDelete ? Icons.close_outlined : Icons.arrow_back,
            color: textColor,
          ),
        ),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            SearchInput(
              radius: 10,
              onChanged: (str) {
                setState(() {
                  keywords = str;
                });
              },
            ),
            Expanded(
              child: KeyboardBlur(
                child: Container(
                  color: bgColor,
                  child: ListView(
                    children: [
                      for (var e in labelData)
                        if ((e.name ?? '').toLowerCase().contains(keywords))
                          _itemWidget(e),
                    ],
                  ),
                ),
              ),
            ),
            //底部管理按钮
            if (!showDelete) _bottomWidget(),
            //底部清理按钮
            if (showDelete) _deleteWidget(),
          ],
        ),
      ),
    );
  }

  //标签行组件
  _itemWidget(ListLabelRespListLabelItem e) {
    var myColors = ThemeNotifier();
    if (showDelete && e.name == '') return Container();
    String name = '${e.name == '' || e.name == null ? '未设置标签的朋友'.tr() : e.name}'
        '(${e.count})';
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        showDelete
            ? onChoose(e)
            : Navigator.pushNamed(context, FriendLabelMembers.path, arguments: {
                'label': e.name,
              }).then((value) {
                getList();
              });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: myColors.tagColor,
        child: Row(
          children: [
            if (showDelete)
              AppCheckbox(
                value: activeIds.contains(e),
                size: 25,
                paddingLeft: 15,
              ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                height: 50,
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //底部按钮
  _bottomWidget() {
    var myColors = ThemeNotifier();
    return Container(
      color: myColors.tagColor,
      child: SafeArea(
        child: Container(
          // height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    FriendLabelAdd.path,
                  ).then((value) {
                    getList();
                  });
                },
                child: Text(
                  '新建'.tr(),
                  style: TextStyle(
                    color: myColors.blueTitle,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showDelete = !showDelete;
                  });
                },
                child: Text(
                  '管理'.tr(),
                  style: TextStyle(
                    color: myColors.blueTitle,
                    fontSize: 16,
                  ),
                ),
              ),
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
        margin: const EdgeInsets.all(12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: myColors.im2Refuse,
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
