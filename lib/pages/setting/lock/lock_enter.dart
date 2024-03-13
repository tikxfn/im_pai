import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../tabs.dart';

class LockEnter extends StatefulWidget {
  const LockEnter({super.key});

  static const String path = 'lock/enter';

  @override
  State<StatefulWidget> createState() => _LockEnterState();
}

class _LockEnterState extends State<LockEnter> {
  String code = '';
  String errText = '';

  //取消
  _cancel() async {
    await Global.loginOut();
  }

  //删除
  _remove() {
    if (code.isEmpty) return;
    setState(() {
      if (errText.isNotEmpty) errText = '';
      code = code.substring(0, code.length - 1);
    });
  }

  //验证锁定码
  _verifyPin() async {
    var api = UserApi(apiClient());
    loading();
    try {
      var res = await api.userVerifyPin(V1VerifyPinArgs(pin: code));

      if (res == null || !toBool(res.is_) || !mounted) {
        setState(() {
          code = '';
          errText = '锁定码错误';
        });
        loadClose();
        return;
      }
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Tabs.path,
        (route) => false,
      );
    } on ApiException catch (e) {
      onError(e);
    }
    loadClose();
  }

  //输入按钮
  Widget _enterBtn(String text) {
    var myColors = ThemeNotifier();
    return InkWell(
      onTap: () {
        if (code.length < 4) {
          errText = '';
          Vibration.vibrate(duration: 50);
          setState(() {
            code += text;
          });
          if (code.length == 4) _verifyPin();
        }
      },
      child: Container(
        width: 77,
        height: 77,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: myColors.blueGrey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(77),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28,
            color: myColors.blueGrey,
          ),
        ),
      ),
    );
  }

  //操作按钮
  Widget _editBtn({
    required String text,
    Function()? onTap,
  }) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(
          text,
          style: TextStyle(
            color: myColors.blueGrey,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath('images/my/bg0.png')),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errText.isNotEmpty ? errText : '输入密码'.tr(),
                    style: TextStyle(
                      color:
                          errText.isNotEmpty ? myColors.red : myColors.blueGrey,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 13,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var _ in code.split(''))
                          Container(
                            width: 13,
                            height: 13,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: myColors.blueGrey,
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 280,
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 15,
                          children: [
                            _enterBtn('1'),
                            _enterBtn('2'),
                            _enterBtn('3'),
                            _enterBtn('4'),
                            _enterBtn('5'),
                            _enterBtn('6'),
                            _enterBtn('7'),
                            _enterBtn('8'),
                            _enterBtn('9'),
                            _enterBtn('0'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _editBtn(text: '取消'.tr(), onTap: _cancel),
                            _editBtn(text: '删除'.tr(), onTap: _remove),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
