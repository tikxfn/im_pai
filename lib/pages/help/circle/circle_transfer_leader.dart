import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class CircleTransferLeader extends StatefulWidget {
  const CircleTransferLeader({super.key});

  static const String path = 'circle/transfer_leader';

  @override
  State<StatefulWidget> createState() {
    return _CircleTransferLeaderState();
  }
}

class _CircleTransferLeaderState extends State<CircleTransferLeader> {
  int limit = 50;
  String keywords = '';

  String circleId = ''; //圈子id

  //成员列表
  List<GCircleJoinModel> userList = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListMember(
        V1ListMemberCircleArgs(
          keywords: keywords,
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : userList.length.toString(),
          ),
        ),
      );
      if (res == null || !mounted) return 0;
      List<GCircleJoinModel> l = [];
      for (var v in res.list) {
        if (v.role == GRole.LEADER) continue;
        l.add(v);
      }
      setState(() {
        if (init) {
          userList = l;
        } else {
          userList.addAll(l);
        }
      });
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  transferLeader(String id, String name) {
    confirm(
      context,
      title: '确定将圈主转让给""用户'.tr(args: [name]),
      onEnter: () async {
        final api = CircleApi(apiClient());
        loading();
        try {
          await api.circleTransferCircleOwner(
              V1TransferCircleOwnerArgs(circleId: circleId, userId: id));
          if (mounted) Navigator.pop(context);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('圈子成员'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SearchInput(
                        onChanged: (str) {
                          setState(() {
                            keywords = str;
                            if (keywords == '') {
                              _getList(init: true);
                            }
                          });
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _getList(init: true);
                      },
                      child: Text(
                        '搜索'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: keywords != ''
                              ? myColors.primary
                              : myColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  limit: limit,
                  onInit: () async {
                    if (!mounted) return 0;
                    dynamic args = ModalRoute.of(context)!.settings.arguments;
                    if (args == null) return 0;
                    if (args['circleId'] != null) circleId = args['circleId'];

                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    for (var e in userList)
                      GestureDetector(
                        onTap: () {
                          transferLeader(e.userId!, e.nickname ?? '');
                        },
                        child: ChatItem(
                          hasSlidable: false,
                          data: ChatItemData(
                            icons: [e.avatar ?? ''],
                            title: e.nickname ?? '',
                            id: e.userId,
                          ),
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
}
