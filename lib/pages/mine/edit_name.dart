import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key});
  static const String path = 'EditNamePage/page';

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = Global.user?.nickname ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: myColors.backGroundColor,
        title: const Text('编辑昵称'),
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
                maxLength: 8,
                controller: controller,
                maxLines: 2,
                autofocus: false,
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
    );
  }

  //保存名字
  void saveName(String str) async {
    if (str.isEmpty) {
      tipError('昵称不能为空');
      return;
    }
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
        nickname: V1SetBasicInfoArgsValue(value: str),
      ));
      await Global.syncLoginUser();
      tipSuccess('昵称保存成功');
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
