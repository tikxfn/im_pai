import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../widgets/keyboard_blur.dart';

class FriendSettingLabel extends StatefulWidget {
  const FriendSettingLabel({super.key});

  static const String path = 'friends/setting_label';

  @override
  State<StatefulWidget> createState() {
    return _FriendSettingLabelState();
  }
}

class _FriendSettingLabelState extends State<FriendSettingLabel> {
  String userId = '';

  //文本控制器
  final TextEditingController _controller = TextEditingController();

  //勾选列表
  List<String> activeIds = [];
  //标签列
  List<ListLabelRespListLabelItem> labelList = [];

  //获取用户设置
  getSetting() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userGetUserFriendSetting(GIdArgs(id: userId));
      if (res == null) return;
      if (res.label != null && res.label != '') {
        activeIds = res.label!.split(',');
        if (mounted) setState(() {});
      }
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取已有标签列表
  getList() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userListLabel({});

      List<ListLabelRespListLabelItem> newLabelList = [];
      for (var v in res?.list ?? []) {
        if (v.name == '' || v.name == null) continue;
        newLabelList.add(v);
      }
      labelList = newLabelList;
      logger.i(labelList);
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //选择标签
  onChoose(String e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //设置标签
  setLabel() async {
    String? labelName;
    if (_controller.text.isNotEmpty) activeIds.add(_controller.text);
    if (activeIds.isNotEmpty) labelName = activeIds.join(',');
    final api = UserApi(apiClient());
    loading();
    try {
      await api.userUpdateUserFriendSetting(
        V1UpdateUserFriendSettingArgs(
          id: userId,
          label: V1UpdateUserFriendSettingArgsValue(
            value: labelName,
          ),
        ),
      );
      if (!mounted) return;
      if (mounted) {
        Navigator.pop(context);
      }
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
      if (args['userId'] == null) return;
      userId = args['userId'];
      getSetting();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('从全部标签中添加'.tr()),
        actions: [
          TextButton(
            onPressed: setLabel,
            child: Text(
              '保存'.tr(),
              style: TextStyle(color: myColors.primary),
            ),
          ),
        ],
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: SafeArea(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        '添加新的标签名字'.tr(),
                        style: TextStyle(
                          color: textColor,
                        ),
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
                      child: Text(
                        '已有标签'.tr(),
                        style: TextStyle(
                          color: textColor,
                        ),
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
                    children: labelList.map((e) {
                      return GestureDetector(
                        onTap: () => onChoose(e.name!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeIds.contains(e.name)
                                ? myColors.circleTagTitle
                                : myColors.grey3,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Text(
                            e.name ?? '',
                            // textAlign: TextAlign.center,
                          ),
                        ),
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
