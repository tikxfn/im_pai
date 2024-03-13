import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class MyPointPage extends StatefulWidget {
  const MyPointPage({super.key});

  static const String path = 'MyPointPage/page';

  @override
  State<MyPointPage> createState() => _MyPointPageState();
}

class _MyPointPageState extends State<MyPointPage> {
  int limit = 20;
  List<GUserIntegralModel> _list = [];
  double integral = 0;
  bool showIntegral = false;

  _init() async {
    await Global.syncLoginUser();
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = UserApi(apiClient());
    try {
      var res = await api.userListUserIntegral(
        V1ListUserIntegralArgs(
          userIntegralType: GUserIntegralType.INVITE,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : _list.length.toString(),
          ),
        ),
      );
      if (res == null || !mounted) return 0;
      logger.i(res.list);
      List<GUserIntegralModel> l = res.list.toList();
      setState(() {
        if (init) {
          _list = l;
        } else {
          _list.addAll(l);
        }
      });
      logger.i(_list);
      return l.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '分享记录',
        ),
      ),
      body: ThemeBody(
        child: PagerBox(
          limit: limit,
          onInit: () async {
            return await _getList(init: true);
          },
          onPullDown: () async {
            return await _getList(init: true);
          },
          onPullUp: () async {
            return await _getList();
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: _list.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: .5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        FriendDetails.path,
                                        arguments: {
                                          'id': v.userIntegralTypeId ?? '',
                                          'detail': GUserModel(
                                            nickname: v.inviteNickname,
                                          ),
                                        },
                                      );
                                    },
                                    child: Text(
                                      v.inviteNickname ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '注册成功',
                                    style: TextStyle(
                                        fontSize: 15, color: myColors.textGrey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                time2date(v.createTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: myColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${v.integral}',
                          style: TextStyle(
                            color: myColors.imGreen2,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
