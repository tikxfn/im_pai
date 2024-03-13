import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class MineSettingSlogan extends StatefulWidget {
  const MineSettingSlogan({super.key});

  static const String path = 'mine/setting/slogan';

  @override
  State<StatefulWidget> createState() {
    return _MineSettingSloganState();
  }
}

class _MineSettingSloganState extends State<MineSettingSlogan> {
  final TextEditingController _controller = TextEditingController();

  //保存
  save() async {
    // if (_controller.text.isEmpty) {
    //   // if (mounted) Navigator.pop(context);
    //   return;
    // }
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(
        V1SetBasicInfoArgs(
          slogan: V1SetBasicInfoArgsValue(value: _controller.text),
        ),
      );
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  pageInit() async {
    await Global.syncLoginUser();
    if (Global.user != null && Global.user!.slogan != null) {
      _controller.text = Global.user!.slogan!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    pageInit();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '取消',
            style: TextStyle(
              color: myColors.red,
            ),
          ),
        ),
        title: const Text('设置签名'),
        actions: [
          TextButton(
            onPressed: save,
            child: Text(
              '保存',
              style: TextStyle(color: myColors.primary),
            ),
          ),
        ],
      ),
      body: KeyboardBlur(
        child: Column(
          children: [
            AppTextarea(
              controller: _controller,
              autofocus: true,
            ),
            // AppInput(
            //   controller: _controller,
            //   autofocus: true,
            //   horizontal: 15,
            //   hintText: '请输入',
            // ),
          ],
        ),
      ),
    );
  }
}
