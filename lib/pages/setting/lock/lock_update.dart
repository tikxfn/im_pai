import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../common/interceptor.dart';

class LockUpdate extends StatefulWidget {
  const LockUpdate({super.key});

  static const String path = 'lock/update';

  @override
  State<StatefulWidget> createState() => _LockUpdateState();
}

class _LockUpdateState extends State<LockUpdate> {
  final TextEditingController _controller = TextEditingController();
  bool update = false;
  String oldPin = '';

  //设置锁定码
  _savePin() async {
    var api = UserApi(apiClient());
    loading();
    try {
      var args = V1SetPinArgs(
        pin: V1SetPinArgsValue(pin: _controller.text),
      );
      await api.userSetPin(args);
      await Global.syncLoginUser();
      tipSuccess('保存成功'.tr());
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    }
    loadClose();
  }

  //修改锁定码
  _updatePin() async {
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userUpdatePin(
        V1UpdatePinArgs(
          oldPin: oldPin,
          newPin: _controller.text,
        ),
      );
      await Global.syncLoginUser();
      tipSuccess('保存成功'.tr());
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    }
    loadClose();
  }

  //保存按钮事件
  saveBtnTap() {
    if (_controller.text.length < 4) return;
    if (!update) {
      _savePin();
    } else if (oldPin.isEmpty) {
      oldPin = _controller.text;
      _controller.text = '';
      setState(() {});
    } else {
      _updatePin();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    update = toBool(Global.user?.isPin);
    String title = update ? '请输入旧锁定码'.tr() : '设置锁定码'.tr();
    if (update && oldPin.isNotEmpty) {
      title = '请输入新锁定码'.tr();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: ListView(
            children: [
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 4; i++)
                        Container(
                          width: 46,
                          height: 46,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: myColors.grey4,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _controller.text.length > i
                                ? _controller.text[i]
                                : '',
                            style: const TextStyle(
                              fontSize: 21,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      width: 210,
                      height: 46,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controller,
                        onChanged: (val) {
                          setState(() {});
                        },
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly //限制输入纯数字
                        ],
                        maxLength: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleButton(
                    theme: AppButtonTheme.blue,
                    disabled: _controller.text.length < 4,
                    title: update && oldPin.isEmpty ? '下一步'.tr() : '完成'.tr(),
                    width: 280,
                    height: 40,
                    radius: 40,
                    fontSize: 16,
                    onTap: saveBtnTap,
                  ),
                ],
              ),
              if (update && oldPin.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _controller.text = oldPin;
                    oldPin = '';
                    _controller.selection =
                        const TextSelection.collapsed(offset: 4);
                    setState(() {});
                  },
                  child: Text(
                    '上一步'.tr(),
                    style: TextStyle(color: myColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
