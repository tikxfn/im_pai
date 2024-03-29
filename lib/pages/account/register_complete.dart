import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/notifier/app_state_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/image_editor.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';
import 'package:provider/provider.dart';

import '../../function_config.dart';
import '../../notifier/theme_notifier.dart';

class RegisterComplete extends StatefulWidget {
  const RegisterComplete({super.key});

  static const String path = 'account/register_complete';

  @override
  State<StatefulWidget> createState() {
    return _RegisterCompleteState();
  }
}

class _RegisterCompleteState extends State<RegisterComplete> {
  final TextEditingController _nameCtr = TextEditingController();
  final TextEditingController _inviteCtr = TextEditingController();
  String avatar = '';
  double avatarSize = 89;
  String? labelTextName;
  Color? labelColorName;
  // String account = '';
  String password = '';
  String inviteCode = '';
  bool inviteDisabled = false;
  String code = '';
  String emil = '';

  //选择头像
  pickerAvatar() async {
    ImagePicker picker = ImagePicker();
    AppStateNotifier().enablePinDialog = false;
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    AppStateNotifier().enablePinDialog = true;
    if (file == null) return;
    photoCrop(file.path);
  }

  //图片上传
  photoUpload(Uint8List? result) async {
    if (result == null) return;
    final urls = await UploadFile(providers: [
      FileProvider.fromBytes(result, V1FileUploadType.USER_AVATAR, 'png'),
    ]).aliOSSUpload();
    var url = urls.firstOrNull;
    if (url == null) return;
    setState(() {
      avatar = url;
    });
  }

  //图片裁剪
  photoCrop(String path) async {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => AppImageEditor(
          File(path),
          avatar: true,
        ),
      ),
    ).then((res) {
      if (res == null) return;
      photoUpload(res['result']);
    });
  }

  //注册
  register() async {
    // if (avatar == '') {
    //   tipError('请选择头像'.tr());
    //   return;
    // }

    if (_nameCtr.text.isEmpty || _nameCtr.text.trim() == '') {
      tipError('名称不能为空'.tr());
      return;
    }
    // if (_inviteCtr.text.isNotEmpty) {
    //   inviteCode = _inviteCtr.text;
    // }
    final api = PassportApi(apiClient());
    loading();
    try {
      var args = V1RegisterByAccountArgs(
        nickname: V1RegisterByAccountArgsValue(value: _nameCtr.text),
        // account: V1RegisterByAccountArgsValue(value: account),
        password: V1RegisterByAccountArgsValue(value: password),
        inviteCode: V1RegisterByAccountArgsValue(value: _inviteCtr.text),
        avatar: V1RegisterByAccountArgsValue(value: avatar),
        email: V1RegisterByAccountArgsValue(value: emil),
        emailCode: V1RegisterByAccountArgsValue(value: code),
      );
      final res = await api.passportRegisterByAccount(args);
      if (res == null && res!.token != null) return;
      await Global.login(res.token!.accessToken!, res.user!, register: true);
      // await Global.setUser(res.user, setTPns: true);
      // await Global.setToken(res.token!.accessToken!);
      // if (!mounted) return;
      // Navigator.pushNamedAndRemoveUntil(context, Tabs.path, (route) => false);
    } on ApiException catch (e) {
      tipError('注册异常'.tr());
      onError(e);
    } finally {
      loadClose();
    }
  }

  //获取安装参数
  _getInstallData() async {
    if (!FunctionConfig.share) return;
    var shareCode = await getClipboardShareCode();
    if (shareCode.isNotEmpty && mounted) {
      _inviteCtr.text = shareCode;
    }
    OpeninstallFlutterPlugin().install((data) async {
      try {
        var args = jsonDecode(data['bindData'].toString());
        logger.d(args);
        if (args != null && args[Global.shareCodeName] != null) {
          _inviteCtr.text = args[Global.shareCodeName];
          if (_inviteCtr.text.isNotEmpty) {
            setState(() {
              inviteDisabled = true;
            });
          }
          // _inviteCtr.
        }
        // tip('args: $args, ic_code: $icCode');
      } catch (e) {
        logger.e(e);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    // if (args['account'] != null) account = args['account'];
    if (args['password'] != null) password = args['password'];
    if (args['emil'] != null) emil = args['emil'];
    if (args['code'] != null) code = args['code'];
    _getInstallData();
  }

  @override
  void dispose() {
    super.dispose();
    _nameCtr.dispose();
    _inviteCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    double iconSize = 22;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: KeyboardBlur(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                child: ListView(
                  // padding: const EdgeInsets.symmetric(horizontal: 43),
                  children: [
                    title('填写邀请码'.tr()),
                    const SizedBox(
                      height: 18,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Row(
                        children: [
                          // Expanded(
                          //   flex: 0,
                          //   child: Container(
                          //     // alignment: Alignment.center,
                          //     decoration: BoxDecoration(
                          //       color: myColors.white,
                          //       borderRadius:
                          //           BorderRadius.circular(avatarSize / 2),
                          //     ),
                          //     child: GestureDetector(
                          //       onTap: pickerAvatar,
                          //       child: Container(
                          //         width: avatarSize,
                          //         height: avatarSize,
                          //         decoration: BoxDecoration(
                          //           color: myColors.grey,
                          //           borderRadius:
                          //               BorderRadius.circular(avatarSize / 2),
                          //         ),
                          //         child: avatar.isNotEmpty
                          //             ? AppNetworkImage(
                          //                 avatar,
                          //                 avatar: true,
                          //                 width: avatarSize,
                          //                 height: avatarSize,
                          //                 imageSpecification:
                          //                     ImageSpecification.w230,
                          //                 borderRadius: BorderRadius.circular(
                          //                     avatarSize / 2),
                          //               )
                          //             : const Icon(
                          //                 Icons.person_add_alt,
                          //                 color: myColors.lineGrey,
                          //                 size: 31,
                          //               ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              // height: avatarSize,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppInputBox(
                                    controller: _nameCtr,
                                    keyboardType: TextInputType.name,
                                    radius: 15,
                                    hintText: '请输入昵称'.tr(),
                                    hintColor: myColors.subIconThemeColor,
                                    fontSize: 15,
                                    color: myColors.chatInputColor,
                                    fontColor: myColors.iconThemeColor,
                                    prefixIcon: Container(
                                      width: iconSize,
                                      height: iconSize,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        assetPath('images/login/user.png'),
                                        color: myColors.subIconThemeColor,
                                        width: iconSize,
                                        height: iconSize,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    if (FunctionConfig.share)
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppInputBox(
                              controller: _inviteCtr,
                              readOnly: inviteDisabled,
                              keyboardType: TextInputType.name,
                              radius: 15,
                              hintText: '非必输入'.tr(),
                              hintColor: myColors.subIconThemeColor,
                              fontSize: 15,
                              color: myColors.chatInputColor,
                              fontColor: myColors.iconThemeColor,
                              prefixIcon: Container(
                                width: iconSize,
                                height: iconSize,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  assetPath('images/login/yaoqingma.png'),
                                  color: myColors.subIconThemeColor,
                                  width: iconSize,
                                  height: iconSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.fromLTRB(44, 0, 44, 0),
                      child: CircleButton(
                        theme: AppButtonTheme.primary,
                        title: '完成'.tr(),
                        onTap: register,
                        height: 43,
                        fontSize: 17,
                        radius: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //标题
  title(String title) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 27.5, left: 45),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
