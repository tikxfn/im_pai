import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/account/account_list.dart';
import 'package:unionchat/pages/account/password_question.dart';
import 'package:unionchat/pages/mine/mine_update_account.dart';
import 'package:unionchat/pages/setting/my_card.dart';
import 'package:unionchat/pages/setting/set_email.dart';
import 'package:unionchat/pages/setting/set_new_pwd.dart';
import 'package:unionchat/pages/setting/set_phone.dart';
import 'package:unionchat/widgets/image_editor.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/app_state_notifier.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/avatar.dart';
import '../../widgets/button.dart';

class MineSetting extends StatefulWidget {
  const MineSetting({super.key});

  static const String path = 'mine/setting';

  @override
  State<StatefulWidget> createState() {
    return _MineSettingState();
  }
}

class _MineSettingState extends State<MineSetting> {
  double avatarSize = 40;
  Uint8List? avatarFile;
  bool uploading = false;
  bool passwordQuestion = false;

  // 是否设置密保
  hasPasswordQuestion() async {
    var api = UserSecurityApi(apiClient());
    try {
      var res = await api.userSecuritySecurityList({});
      if (!mounted) return;
      setState(() {
        passwordQuestion = (res?.questions ?? []).isNotEmpty;
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //保存
  Future<bool> save({
    GSex? sex,
    String? birthday,
    String? avatar,
    String? userName,
    String? slogan,
    bool load = true,
  }) async {
    if (sex == null &&
        birthday == null &&
        avatar == null &&
        userName == null &&
        slogan == null) {
      return false;
    }
    V1SetBasicInfoArgs args = V1SetBasicInfoArgs();
    if (sex != null) {
      args.sex = V1SetBasicInfoArgsSex(sex: sex);
    }
    if (birthday != null) {
      args.birthday = SetBasicInfoArgsBirthday(birthday: birthday);
    }
    if (avatar != null) {
      args.avatar = V1SetBasicInfoArgsValue(value: avatar);
    }
    if (userName != null) {
      args.nickname = V1SetBasicInfoArgsValue(value: userName);
    }
    if (slogan != null) {
      args.slogan = V1SetBasicInfoArgsValue(value: slogan);
    }
    var api = UserApi(apiClient());
    if (load) loading();
    try {
      await api.userSetBasicInfo(args);
      await Global.syncLoginUser();
      if (!mounted) return false;
      setState(() {});
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    } finally {
      if (load) loadClose();
    }
  }

  //选择头像
  pickerAvatar() async {
    // if (!platformPhone) {
    //   tip('请使用手机端上传头像');
    //   return;
    // }
    ImagePicker picker = ImagePicker();
    AppStateNotifier().enablePinDialog = false;
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    AppStateNotifier().enablePinDialog = true;
    if (file == null) return;
    // if (file.path.endsWith('.gif') &&
    //     Global.userVipLevel != GVipLevel.NIL &&
    //     Global.userVipLevel != GVipLevel.n1) {
    //   photoGifUpload(file);
    // } else {
    //   photoCrop(file.path);
    // }
    photoCrop(file);
  }

  //gif图片上传 不裁剪上传
  photoGifUpload(XFile? result) async {
    if (result == null) return;
    Uint8List newAvatarFile = await result.readAsBytes();
    setState(() {
      avatarFile = newAvatarFile;
      uploading = true;
    });
    final urls = await UploadFile(
      providers: [
        FileProvider.fromFilepath(result.path, V1FileUploadType.USER_AVATAR),
      ],
    ).aliOSSUpload();
    await save(avatar: urls.firstOrNull ?? '', load: false);
    setState(() {
      uploading = false;
    });
  }

  //图片上传
  photoUpload(Uint8List? result) async {
    if (result == null) return;
    setState(() {
      avatarFile = result;
      uploading = true;
    });
    final urls = await UploadFile(
      providers: [
        FileProvider.fromBytes(result, V1FileUploadType.USER_AVATAR, 'png'),
      ],
    ).aliOSSUpload();
    await save(avatar: urls.firstOrNull ?? '', load: false);
    setState(() {
      uploading = false;
    });
  }

  //图片裁剪
  photoCrop(XFile? result) async {
    if (result == null) return;
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => AppImageEditor(
          File(result.path),
          avatar: true,
          isUser: true,
        ),
      ),
    ).then((res) {
      if (res == null) return;
      if (res['isCrop']) {
        photoUpload(res['result']);
      } else {
        photoGifUpload(result);
      }
    });
  }

  // //图片裁剪
  // photoCrop(String path) async {
  //   Navigator.push(
  //     context,
  //     CupertinoModalPopupRoute(
  //       builder: (context) => AppImageEditor(
  //         File(path),
  //         avatar: true,
  //       ),
  //     ),
  //   ).then((res) {
  //     if (res == null) return;
  //     photoUpload(res['result']);
  //   });
  // }

  //保存名字
  Future<bool> saveName(String str) async {
    if (str.isEmpty) {
      tipError('名字不能为空'.tr());
      return false;
    }
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(
          V1SetBasicInfoArgs(nickname: V1SetBasicInfoArgsValue(value: str)));
      await Global.syncLoginUser();
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    hasPasswordQuestion();
    Global.syncLoginUser();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    String userName = (Global.user?.nickname ?? '').isNotEmpty
        ? Global.user!.nickname!
        : '未设置'.tr();
    String phone =
        (Global.user?.phone ?? '').isNotEmpty ? Global.user!.phone! : '';
    String email =
        (Global.user?.email ?? '').isNotEmpty ? Global.user!.email! : '';
    String slogan =
        (Global.user?.slogan ?? '').isNotEmpty ? Global.user!.slogan! : '';

    return ThemeImage(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: uploading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(radius: 7),
                    Text(
                      '正在上传，请稍后'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                )
              : Text(
                  '消息编辑'.tr(),
                ),
        ),
        body: ThemeBody(
          topPadding: 10,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    shadowBox(
                      child: MenuUl(
                        marginTop: 0,
                        children: [
                          MenuItemData(
                            onTap: pickerAvatar,
                            title: '头像'.tr(),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (avatarFile != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.memory(
                                      avatarFile!,
                                      width: avatarSize,
                                      height: avatarSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                if (avatarFile == null)
                                  AppAvatar(
                                    list: [
                                      Global.user?.avatar ?? '',
                                    ],
                                    userName: Global.user?.nickname ?? '',
                                    userId: Global.user?.id ?? '',
                                    size: avatarSize,
                                  ),
                              ],
                            ),
                          ),
                          MenuItemData(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoModalPopupRoute(builder: (context) {
                                  return SetNameInput(
                                    title: '修改个人昵称'.tr(),
                                    value: userName,
                                    onEnter: (val) async {
                                      return await save(userName: val);
                                    },
                                  );
                                }),
                              );
                            },
                            title: '昵称'.tr(),
                            content: Text(
                              userName,
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                          MenuItemData(
                            onTap: () {
                              openSheetMenu(
                                context,
                                list: ['男'.tr(), '女'.tr()],
                                onTap: (i) {
                                  save(sex: i == 0 ? GSex.BOY : GSex.GIRL);
                                },
                              );
                            },
                            title: '性别'.tr(),
                            content: Text(
                              Global.user != null &&
                                      sex2text(Global.user!.sex).isNotEmpty
                                  ? sex2text(Global.user!.sex)
                                  : '未设置'.tr(),
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                          MenuItemData(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoModalPopupRoute(builder: (context) {
                                  return SetNameInput(
                                    title: '修改个人简介'.tr(),
                                    value: slogan,
                                    onEnter: (val) async {
                                      return await save(slogan: val);
                                    },
                                  );
                                }),
                              );
                              // Navigator.pushNamed(context, EditSelfPage.path);
                            },
                            title: '简介'.tr(),
                            arrow: false,
                            content: Text(
                              slogan.isNotEmpty ? slogan : '未填写'.tr(),
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shadowBox(
                      child: MenuUl(
                        marginTop: 0,
                        children: [
                          MenuItemData(
                            onTap: () {
                              Navigator.pushNamed(
                                      context, MineUpdateAccount.path)
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            title: '账号'.tr(),
                          ),
                          MenuItemData(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                SetPhone.path,
                                arguments: {
                                  'phone': phone.isNotEmpty ? phone : ''
                                },
                              ).then((value) {
                                if (mounted) setState(() {});
                              });
                            },
                            title: '手机'.tr(),
                            content: Text(
                              phone.isNotEmpty ? phone : '未设置'.tr(),
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                          MenuItemData(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                SetEmail.path,
                                arguments: {
                                  'email': email.isNotEmpty ? email : ''
                                },
                              ).then((value) {
                                if (mounted) setState(() {});
                              });
                            },
                            title: '邮箱'.tr(),
                            content: Text(email.isNotEmpty ? email : '未设置'.tr(),
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: ThemeNotifier().textGrey,
                                )),
                          ),
                          MenuItemData(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, SetNewPasswordPage.path);
                            },
                            title: '修改登录密码'.tr(),
                          ),
                          MenuItemData(
                            onTap: () {
                              if (passwordQuestion) return;
                              Navigator.pushNamed(
                                context,
                                PasswordQuestion.path,
                              ).then((value) => hasPasswordQuestion());
                            },
                            title: '密保问题'.tr(),
                            content: Text(
                              passwordQuestion ? '已设置'.tr() : '未设置'.tr(),
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shadowBox(
                      child: MenuUl(
                        marginTop: 0,
                        children: [
                          MenuItemData(
                            onTap: () {
                              Navigator.pushNamed(context, MyCardPage.path);
                            },
                            needColor: myColors.isDark,
                            title: '我的二维码'.tr(),
                            icon: assetPath('images/my/erweima.png'),
                          ),
                          MenuItemData(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.utc(1970, 1, 1),
                                lastDate: DateTime.now(),
                              );
                              if (date == null) return;
                              save(birthday: date2time(date));
                            },
                            needColor: myColors.isDark,
                            title: '生日'.tr(),
                            icon: assetPath('images/my/shengri.png'),
                            content: Text(
                              Global.user != null &&
                                      Global.user!.birthday != null &&
                                      Global.user!.birthday! != '0'
                                  ? time2date(Global.user!.birthday,
                                      format: 'yyyy/MM/dd')
                                  : '未设置'.tr(),
                              style: menuItemGreyTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onTap: pickerAvatar,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(avatarSize / 2), // 圆角的半径
              //     child: Stack(
              //       alignment: AlignmentDirectional.bottomEnd,
              //       children: [
              //         if (avatarFile != null)
              //           Image.memory(
              //             avatarFile!,
              //             width: avatarSize,
              //             height: avatarSize,
              //             fit: BoxFit.contain,
              //           ),
              //         if (avatarFile == null)
              //           AppAvatar(
              //             list: [
              //               Global.user?.avatar ?? '',
              //             ],
              //             userName: Global.user?.nickname ?? '',
              //             userId: Global.user?.id ?? '',
              //             size: avatarSize,
              //           ),
              //         Container(
              //           height: avatarSize / 3,
              //           width: avatarSize,
              //           color: Colors.black.withOpacity(0.3),
              //           child: Center(
              //             child: Text(
              //               '编辑'.tr(),
              //               style: TextStyle(
              //                 color: myColors.white,
              //                 fontSize: 11.0,
              //               ),
              //             ),
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              // Container(
              //   padding: const EdgeInsets.only(top: 10, bottom: 15),
              //   alignment: Alignment.center,
              //   child: UserNameTags(
              //     userName: (Global.user?.nickname ?? '').isNotEmpty
              //         ? Global.user!.nickname!
              //         : '未设置'.tr(),
              //     select: false,
              //     needMarqueeText: true,
              //     // vip: Global.userVip,
              //     // vipLevel: Global.userVipLevel,
              //     // onlyName: Global.userOnlyName,
              //     // goodNumber: Global.userGoodNumber,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Expanded(
              //   flex: 1,
              //   child: Container(
              //     child: ListView(
              //       children: [
              //         MenuUl(
              //           marginTop: 0,
              //           children: [
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.pushNamed(
              //                         context, MineUpdateAccount.path)
              //                     .then((value) {
              //                   setState(() {});
              //                 });
              //               },
              //               needColor: myColors.isDark,
              //               title: '账号'.tr(),
              //               icon: assetPath('images/my/zhanghao.png'),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.pushNamed(
              //                   context,
              //                   SetPhone.path,
              //                   arguments: {
              //                     'phone': phone.isNotEmpty ? phone : ''
              //                   },
              //                 ).then((value) {
              //                   if (mounted) setState(() {});
              //                 });
              //               },
              //               needColor: myColors.isDark,
              //               title: '手机'.tr(),
              //               icon: assetPath('images/my/sp_yinsianquani.png'),
              //               content: Text(
              //                 phone.isNotEmpty ? phone : '未设置'.tr(),
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.pushNamed(
              //                   context,
              //                   SetEmail.path,
              //                   arguments: {
              //                     'email': email.isNotEmpty ? email : ''
              //                   },
              //                 ).then((value) {
              //                   if (mounted) setState(() {});
              //                 });
              //               },
              //               needColor: myColors.isDark,
              //               title: '邮箱'.tr(),
              //               icon: assetPath('images/my/sp_yinsianquani.png'),
              //               content: Text(email.isNotEmpty ? email : '未设置'.tr(),
              //                   style: TextStyle(
              //                     overflow: TextOverflow.ellipsis,
              //                     color: ThemeNotifier().textGrey,
              //                   )),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.push(
              //                   context,
              //                   CupertinoModalPopupRoute(builder: (context) {
              //                     return SetNameInput(
              //                       title: '修改个人昵称'.tr(),
              //                       value: userName,
              //                       onEnter: (val) async {
              //                         return await save(userName: val);
              //                       },
              //                     );
              //                   }),
              //                 );
              //                 // Navigator.pushNamed(context, EditNamePage.path);
              //               },
              //               needColor: myColors.isDark,
              //               title: '昵称'.tr(),
              //               icon: assetPath('images/my/mingcheng.png'),
              //               content: Text(
              //                 userName,
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.push(
              //                   context,
              //                   CupertinoModalPopupRoute(builder: (context) {
              //                     return SetNameInput(
              //                       title: '修改个人简介'.tr(),
              //                       value: slogan,
              //                       onEnter: (val) async {
              //                         return await save(slogan: val);
              //                       },
              //                     );
              //                   }),
              //                 );
              //                 // Navigator.pushNamed(context, EditSelfPage.path);
              //               },
              //               needColor: myColors.isDark,
              //               title: '简介'.tr(),
              //               icon: assetPath('images/my/jianjie.png'),
              //               arrow: false,
              //               content: Text(
              //                 slogan.isNotEmpty ? slogan : '未填写'.tr(),
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.pushNamed(context, MyCardPage.path);
              //               },
              //               needColor: myColors.isDark,
              //               title: '我的二维码'.tr(),
              //               icon: assetPath('images/my/erweima.png'),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 Navigator.pushNamed(
              //                     context, SetNewPasswordPage.path);
              //               },
              //               needColor: myColors.isDark,
              //               title: '修改登录密码'.tr(),
              //               icon: assetPath('images/my/xiugaimima.png'),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 if (passwordQuestion) return;
              //                 Navigator.pushNamed(
              //                   context,
              //                   PasswordQuestion.path,
              //                 ).then((value) => hasPasswordQuestion());
              //               },
              //               needColor: myColors.isDark,
              //               title: '密保问题'.tr(),
              //               icon: assetPath('images/my/xiugaimima.png'),
              //               content: Text(
              //                 passwordQuestion ? '已设置'.tr() : '未设置'.tr(),
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //             MenuItemData(
              //               onTap: () async {
              //                 DateTime? date = await showDatePicker(
              //                   context: context,
              //                   initialDate: DateTime.now(),
              //                   firstDate: DateTime.utc(1970, 1, 1),
              //                   lastDate: DateTime.now(),
              //                 );
              //                 if (date == null) return;
              //                 save(birthday: date2time(date));
              //               },
              //               needColor: myColors.isDark,
              //               title: '生日'.tr(),
              //               icon: assetPath('images/my/shengri.png'),
              //               content: Text(
              //                 Global.user != null &&
              //                         Global.user!.birthday != null &&
              //                         Global.user!.birthday! != '0'
              //                     ? time2date(Global.user!.birthday,
              //                         format: 'yyyy/MM/dd')
              //                     : '未设置'.tr(),
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //             MenuItemData(
              //               onTap: () {
              //                 openSheetMenu(
              //                   context,
              //                   list: ['男'.tr(), '女'.tr()],
              //                   onTap: (i) {
              //                     save(sex: i == 0 ? GSex.BOY : GSex.GIRL);
              //                   },
              //                 );
              //               },
              //               needColor: myColors.isDark,
              //               title: '性别'.tr(),
              //               icon: assetPath('images/my/xibie.png'),
              //               content: Text(
              //                 Global.user != null &&
              //                         sex2text(Global.user!.sex).isNotEmpty
              //                     ? sex2text(Global.user!.sex)
              //                     : '未设置'.tr(),
              //                 style: menuItemGreyTextStyle,
              //               ),
              //             ),
              //           ],
              //         ),
              //         Container(
              //           child: Padding(
              //             padding: const EdgeInsets.only(
              //                 left: 15, right: 15, bottom: 10, top: 10),
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   flex: 1,
              //                   child: CircleButton(
              //                     theme: AppButtonTheme.primary,
              //                     onTap: () {
              //                       Navigator.pushNamed(
              //                           context, AccountList.path);
              //                     },
              //                     fontSize: 15,
              //                     height: 45,
              //                     radius: 50,
              //                     title: '切换账号'.tr(),
              //                   ),
              //                 ),
              //                 const SizedBox(width: 15),
              //                 Expanded(
              //                   flex: 1,
              //                   child: CircleButton(
              //                     theme: AppButtonTheme.red,
              //                     onTap: () {
              //                       confirm(
              //                         context,
              //                         content: '是否确定退出登录？'.tr(),
              //                         onEnter: () async {
              //                           await Global.loginOut();
              //                         },
              //                       );
              //                     },
              //                     fontSize: 15,
              //                     height: 45,
              //                     radius: 50,
              //                     title: '退出登录'.tr(),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              Container(
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: myColors.bottom,
                  boxShadow: [
                    BoxShadow(
                      color: myColors.bottomShadow,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          theme: AppButtonTheme.blue,
                          onTap: () {
                            Navigator.pushNamed(context, AccountList.path);
                          },
                          fontSize: 16,
                          icon: 'images/my/changeAccount.png',
                          height: 47,
                          radius: 10,
                          title: '切换账号'.tr(),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          theme: AppButtonTheme.red,
                          onTap: () {
                            confirm(
                              context,
                              content: '是否确定退出登录？'.tr(),
                              onEnter: () async {
                                await Global.loginOut();
                              },
                            );
                          },
                          fontSize: 16,
                          icon: 'images/my/exit.png',
                          height: 47,
                          radius: 10,
                          title: '退出登录'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: myColors.isDark
            ? null
            : [
                BoxShadow(
                  color: myColors.bottomShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
