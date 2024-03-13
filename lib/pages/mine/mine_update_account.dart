import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class MineUpdateAccount extends StatefulWidget {
  const MineUpdateAccount({super.key});
  static const String path = 'mine/Update_account';
  @override
  State<StatefulWidget> createState() {
    return _MineUpdateAccountState();
  }
}

class _MineUpdateAccountState extends State<MineUpdateAccount> {
  final TextEditingController _controller = TextEditingController();
  // String selectAccount = '账号'.tr();
  @override
  void initState() {
    super.initState();
    loadAccount();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  loadAccount() {
    _controller.text = Global.user?.account ?? '';
    if (mounted) setState(() {});
  }

  //保存账号
  saveAccount(String str) async {
    if (str.isEmpty) {
      tipError('账号不能为空');
      return;
    }
    if (!accountFormat(str)) {
      tipError('账号输入不正确');
      return;
    }
    confirm(context, title: '账号只能修改一次，确定将账号修改为“$str”,修改后无法再次更改!!!',
        onEnter: () async {
      var api = UserApi(apiClient());
      loading();
      try {
        await api.userChangeAccount(V1ChangAccountArgs(account: str));
        await Global.syncLoginUser();
        loadAccount();
        setState(() {});
      } on ApiException catch (e) {
        onError(e);
      } finally {
        loadClose();
      }
    });
  }

  // //选择展示号
  // saveShowAccount(String accountName) async {
  //   GShowNameType showtype = GShowNameType.ACCOUNT;
  //   if (accountName == '账号'.tr()) {
  //     showtype = GShowNameType.ACCOUNT;
  //   } else if (accountName == '手机号'.tr()) {
  //     showtype = GShowNameType.PHONE;
  //   } else if (accountName == '靓号'.tr()) {
  //     showtype = GShowNameType.NUMBER;
  //   } else {
  //     return;
  //   }
  //   var api = UserApi(apiClient());
  //   loading();
  //   try {
  //     await api.userSetShowName(V1SetShowNameArgs(type: showtype));
  //     await Global.loginUser();
  //     tip('设置成功');
  //     setState(() {});
  //   } on ApiException catch (e) {
  //     onError(e);
  //   } finally {
  //     loadClose();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    // Color tagColor = myColors.tagColor;
    // List<String> showAccount = ['账号'.tr(), '手机号'.tr(), '靓号'.tr()];
    // String userNo = (Global.user?.account ?? '').isNotEmpty
    //     ? Global.user!.account!
    //     : '未设置'.tr();
    // String userNumber = (Global.user?.userNumber ?? '').isNotEmpty
    //     ? Global.user!.userNumber!
    //     : '';
    // String phone =
    //     (Global.user?.phone ?? '').isNotEmpty ? Global.user!.phone! : '';
    // switch (Global.user?.userExtend?.showName) {
    //   case GShowNameType.ACCOUNT:
    //     selectAccount = '账号'.tr();
    //     break;
    //   case GShowNameType.PHONE:
    //     selectAccount = '手机号'.tr();
    //     break;
    //   case GShowNameType.NUMBER:
    //     selectAccount = '靓号'.tr();
    //     break;
    //   case GShowNameType.NIL:
    //     selectAccount = '账号'.tr();
    //     break;
    // }
    return Scaffold(
      backgroundColor: myColors.themeBackgroundColor,
      appBar: AppBar(),
      body: KeyboardBlur(
        child: ThemeBody(
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 44,
                ),
                Text(
                  '修改账号'.tr(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 65, right: 65),
                  child: Text(
                    textAlign: TextAlign.center,
                    '账号只能修改一次，请谨慎操作'.tr(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                //修改账号输入框
                Container(
                  padding: const EdgeInsets.fromLTRB(45, 40, 45, 0),
                  child: AppInput(
                    readOnly: toBool(Global.user?.isChangeAccount),
                    controller: _controller,
                    borderTop: false,
                    autofocus: true,
                    horizontal: 15,
                    showClean: !toBool(Global.user?.isChangeAccount),
                    onChanged: (value) {
                      setState(() {});
                    },
                    clear: () {
                      setState(() {
                        _controller.clear();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text(
                    '以字母开头，4~16位数字字母下划线'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: myColors.textGrey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: CircleButton(
                    height: 41,
                    width: 223,
                    radius: 20,
                    fontSize: 14,
                    title: '确定'.tr(),
                    theme: toBool(Global.user?.isChangeAccount)
                        ? AppButtonTheme.grey
                        : AppButtonTheme.blue,
                    onTap: toBool(Global.user?.isChangeAccount)
                        ? null
                        : () async {
                            logger.d(Global.user?.isChangeAccount);
                            if (toBool(Global.user?.isChangeAccount)) {
                              tip('当前无法修改，账号只能修改一次'.tr());
                              return;
                            }
                            await saveAccount(_controller.text);
                          },
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 50),
                //   child: Text(
                //     '向其他用户展示我的'.tr(),
                //     style: TextStyle(
                //       fontSize: 14,
                //       color: textColor,
                //     ),
                //   ),
                // ),
                // //选择展示账号
                // Padding(
                //   padding: const EdgeInsets.only(
                //     top: 20,
                //     left: 100,
                //     right: 100,
                //   ),
                //   child: SizedBox(
                //     // width: 120,
                //     height: 30.0,
                //     child: DropdownButtonFormField<String>(
                //       dropdownColor: tagColor,
                //       isExpanded: true,
                //       iconSize: 20,
                //       style: TextStyle(
                //         fontSize: 15,
                //         color: textColor,
                //       ),
                //       decoration: const InputDecoration(
                //           contentPadding: EdgeInsets.only(left: 5, right: 5),
                //           border: OutlineInputBorder(gapPadding: 1),
                //           labelText: ''),
                //       // 设置默认值
                //       value: selectAccount,
                //       // 选择回调
                //       onChanged: (String? newSelectAccount) {
                //         setState(() {
                //           selectAccount = newSelectAccount!;
                //           saveShowAccount(selectAccount);
                //         });
                //       },
                //       // 传入可选的数组
                //       items: showAccount.map((String data) {
                //         return DropdownMenuItem(
                //           value: data,
                //           alignment: Alignment.center,
                //           child: Text(data),
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 40),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         '当前账号：'.tr(args: [userNo]),
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: myColors.textGrey,
                //         ),
                //       ),
                //       Text(
                //         '当前靓号：'.tr(args: [userNumber]),
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: myColors.textGrey,
                //         ),
                //       ),
                //       Text(
                //         '当前手机号：'.tr(args: [phone]),
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: myColors.textGrey,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
