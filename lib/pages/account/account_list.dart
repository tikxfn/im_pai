import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class AccountList extends StatefulWidget {
  const AccountList({super.key});

  static const path = 'account/list';

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  List<AccountListItem> list = [];
  Map<String, GUserModel> users = {};

  // 获取用户详情
  getAccountInfo() async {
    list = Global.getAccount();
    if (list.isEmpty) return;
    loading();
    var api = UserApi(apiClient());
    try {
      var res = await api.userListUserByIds(GIdsArgs(
        ids: list.map((e) => e.userId).toList(),
      ));
      if (res == null) return;
      for (var v in res.list) {
        if (v.id == null || v.id!.isEmpty) continue;
        users[v.id!] = v;
      }
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  // 删除账号
  removeAccount(GUserModel v) async {
    if (v.id == Global.user?.id) {
      tipError('不能删除当前已登录的账号');
      return;
    }
    loading();
    await Global.removeAccount(v.id!);
    loadClose();
    getAccountInfo();
  }

  // 切换登录账号
  changeAccount(String token, GUserModel userInfo) async {
    loading();
    await Global.loginOut(nav: false);
    await Global.login(token, userInfo);
    // await Global.loginUser(setTPns: true);
    loadClose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      getAccountInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('切换账号'.tr()),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  var account = list[i];
                  var id = account.userId;
                  var active = id == toStr(Global.user?.id);
                  var v = users[id];
                  if (v == null) return Container();
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: .5,
                          color: myColors.grey2,
                        ),
                      ),
                    ),
                    child: ChatItem(
                      hasSlidable: v.id != Global.user?.id,
                      showTop: false,
                      onTap: () {
                        changeAccount(account.token, v);
                      },
                      onDelete: () {
                        removeAccount(v);
                      },
                      data: ChatItemData(
                        icons: [v.avatar ?? ''],
                        title: v.nickname ?? '',
                        text: v.account ?? '',
                        id: v.id ?? '',
                      ),
                      end: active
                          ? Icon(
                              Icons.check,
                              color: myColors.green,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            AppButtonBottomBox(
              child: CircleButton(
                onTap: Global.goAddAccount,
                title: '+添加账号'.tr(),
                fontSize: 14,
                height: 40,
                radius: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
