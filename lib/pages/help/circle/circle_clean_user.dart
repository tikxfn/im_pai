import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class CircleCleanUser extends StatefulWidget {
  const CircleCleanUser({super.key});

  static const path = 'circle/clean_user';

  @override
  State<CircleCleanUser> createState() => _CircleCleanUserState();
}

class _CircleCleanUserState extends State<CircleCleanUser> {
  String circleId = '';
  String selectDays = '';
  bool selectAvatar = false;
  List typeList = ['7', '15', '30'];

  save() async {
    if (selectDays == '' && selectAvatar == false) {
      return;
    }
    GDays days = GDays.NIL;
    switch (selectDays) {
      case '7':
        days = GDays.n7;
        break;
      case '15':
        days = GDays.n15;
        break;
      case '30':
        days = GDays.n30;
        break;
    }
    loading();
    var api = CircleApi(apiClient());
    try {
      var args = GClearMemberArgs(
        avatar: selectAvatar ? GSure.YES : GSure.NO,
        days: days,
        id: circleId,
      );
      await api.circleClearMember(args);
      tip('操作成功'.tr());
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      tip('失败'.tr());
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
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['circleId'] != null) circleId = args['circleId'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '异常用户清理',
        ),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: const Text(
                          '无头像用户',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            selectAvatar = !selectAvatar;
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: AppCheckbox(
                                  value: selectAvatar,
                                  size: 25,
                                  paddingRight: 15,
                                  paddingLeft: 15,
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 15,
                                  ),
                                  child: Text(
                                    '未设置头像用户',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: const Text(
                          '不活跃用户',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      radioWidgte(['7', '15', '30']),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(60, 20, 60, 0),
              child: CircleButton(
                theme: AppButtonTheme.primary,
                title: '确定'.tr(),
                onTap: save,
                fontSize: 16,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //单选框
  Widget radioWidgte(List<String> typeList) {
    return Column(
      children: [
        for (var v in typeList)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (selectDays == v) {
                  selectDays = '';
                } else {
                  selectDays = v;
                }
                setState(() {});
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: AppCheckbox(
                      value: selectDays == v,
                      size: 25,
                      paddingRight: 15,
                      paddingLeft: 15,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                      ),
                      child: Text(
                        '$v天未活跃用户',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
