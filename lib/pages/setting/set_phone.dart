import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class SetPhone extends StatefulWidget {
  const SetPhone({super.key});

  static const path = 'setPhone/home';

  @override
  State<SetPhone> createState() => _SetPhoneState();
}

class _SetPhoneState extends State<SetPhone> {
  final double iconSize = 30;
  Timer? _timer;
  String phoneNumber = '';
  final TextEditingController phone = TextEditingController();
  TextEditingController code = TextEditingController();
  bool getCode = false;
  late int time;
  bool waitStatus = false; //发送等待

  //绑定手机
  void submmitTo() async {
    if (phone.text == '') {
      tip('请输入手机号'.tr());
      return;
    }

    if (code.text == '') {
      tip('请输入验证码'.tr());
      return;
    }
    final api = UserApi(apiClient());
    try {
      loading();
      await api.userBindPhone(V1BindPhoneArgs(
        phone: phoneNumber,
        code: code.text,
      ));
      await Global.syncLoginUser();
      if (mounted) {
        tipSuccess('手机号绑定成功'.tr());
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      tipError('保存异常'.tr());
      onError(e);
    } finally {
      loadClose();
    }
  }

  //取消绑定手机
  void cancelPhone() async {
    var cfm = await confirm(
      context,
      title: '解绑手机',
      content:
          '确定要解绑当前已经绑定的手机号？解绑后将无法使用${Global.user?.phone ?? '该手机号'}进行登录，请谨慎操作！',
    );
    if (cfm != true) return;
    final api = UserApi(apiClient());
    try {
      loading();
      await api.userCancelBindPhone({});
      await Global.syncLoginUser();
      if (mounted) {
        tipSuccess('手机号解绑成功'.tr());
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //获取验证码
  countdown() async {
    if (phone.text == '') {
      tip('请输入手机号'.tr());
      return;
    }
    waitStatus = true;
    setState(() {});
    final api = PassportApi(apiClient());

    try {
      await api.passportSendSms(V1SendSmsArgs(
        phone: phoneNumber,
        type: GSmsType.BIND_PHONE,
      ));
      if (!mounted) return;
      if (mounted) {
        getCode = true;
        time = 60;
        _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time = time - 1;
          if (time == 0) {
            getCode = false;
            _timer?.cancel();
          }
          setState(() {});
        });
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      waitStatus = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      String phoneText = '';
      if (args['phone'] != null) {
        phoneText = args['phone'].replaceAll(RegExp(r'^\+86'), '');
        phone.text = phoneText;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    phone.dispose();
    code.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color inputColor = myColors.chatInputColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: myColors.themeBackgroundColor,
      appBar: AppBar(),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Center(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 27.5, left: 43.5),
                  child: Text(
                    '绑定新的手机号'.tr(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: IntlPhoneField(
                      controller: phone,
                      showCountryFlag: false,
                      disableLengthCheck: true,
                      dropdownIconPosition: IconPosition.trailing,
                      initialCountryCode: 'CN',
                      invalidNumberMessage: '无效的电话号码'.tr(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        helperStyle: const TextStyle(fontSize: 11),
                        errorStyle: const TextStyle(fontSize: 11),
                        hintText: '',
                        hintStyle: TextStyle(
                          color: myColors.imTextGrey1,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 10,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      languageCode: context.locale.languageCode,
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                  child: AppInputBox(
                    controller: code,
                    color: inputColor,
                    hintColor: myColors.imTextGrey1,
                    keyboardType: TextInputType.number,
                    hintText: '请输入验证码'.tr(),
                    fontSize: 15,
                    fontColor: textColor,
                    action: waitStatus
                        ? const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CupertinoActivityIndicator(radius: 10),
                          )
                        : GestureDetector(
                            onTap: !getCode ? countdown : null,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                !getCode
                                    ? '获取验证码'.tr()
                                    : '秒后重新获取'.tr(args: [time.toString()]),
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                  child: CircleButton(
                    theme: AppButtonTheme.blue,
                    title: '完成'.tr(),
                    onTap: submmitTo,
                    fontSize: 16,
                    height: 41,
                    radius: 10,
                  ),
                ),
                if ((Global.user?.phone ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(44, 15, 44, 0),
                    child: CircleButton(
                      theme: AppButtonTheme.red,
                      title: '解绑当前已绑定的手机号'.tr(),
                      onTap: cancelPhone,
                      fontSize: 16,
                      height: 41,
                      radius: 10,
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
