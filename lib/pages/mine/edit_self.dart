import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class EditSelfPage extends StatefulWidget {
  const EditSelfPage({super.key});

  static const String path = 'EditSelfPage/page';

  @override
  State<EditSelfPage> createState() => _EditSelfPageState();
}

class _EditSelfPageState extends State<EditSelfPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = Global.user?.slogan ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        currentFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: myColors.backGroundColor,
        appBar: AppBar(
          backgroundColor: myColors.backGroundColor,
          title: const Text('个性签名'),
          actions: [
            TextButton(
              onPressed: () {
                saveName(controller.text);
              },
              child: Text(
                '保存',
                style: TextStyle(color: myColors.primary),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 2,
                  maxLength: 30,
                  autofocus: false,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: '请输入',
                    hintMaxLines: 20,
                    // border: InputBorder.none,
                  ),
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //保存名字
  void saveName(String str) async {
    if (str.isEmpty) {
      tipError('个人简介不能为空');
      return;
    }
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
        slogan: V1SetBasicInfoArgsValue(value: str),
      ));
      await Global.syncLoginUser();
      tipSuccess('个人简介保存成功');
      Future.delayed(const Duration(seconds: 1)).then((value) {
        Navigator.pop(context);
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }
}
