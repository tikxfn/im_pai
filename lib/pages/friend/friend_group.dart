import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/light_text.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/search_input.dart';
import '../chat/chat_talk.dart';
import '../chat/widgets/chat_talk_model.dart';

class FriendGroup extends StatefulWidget {
  const FriendGroup({super.key});

  static const String path = 'friends/group';

  @override
  State<StatefulWidget> createState() {
    return _FriendGroupState();
  }
}

class _FriendGroupState extends State<FriendGroup>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String keywords = '';
  static List<GRoomModel> groupData = [];
  final List<GRoomMemberIdentity> _targetsType = [
    GRoomMemberIdentity.MEMBER,
    GRoomMemberIdentity.OWNER,
    GRoomMemberIdentity.ADMIN
  ];

  late TabController _tabController;

  //获取列表
  getList() async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomList({});
      // logger.d(res);
      if (!mounted) return;
      groupData = res?.list ?? [];
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //获取_targetsType类型名称
  getTypeName(type) {
    switch (type) {
      case GRoomMemberIdentity.MEMBER:
        return '我加入的'.tr();
      case GRoomMemberIdentity.OWNER:
        return '我创建的'.tr();
      case GRoomMemberIdentity.ADMIN:
        return '我管理的'.tr();
    }
  }

  //tab切换
  Widget tab() {
    var myColors = ThemeNotifier();
    return ValueListenableBuilder(
      valueListenable: UnreadValue.groupApplyNotRead,
      builder: (context, groupApplyNotRead, _) {
        return TabBar(
          controller: _tabController,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 45),
          indicatorColor: myColors.circleBlueButtonBg,
          indicatorWeight: 3.0,
          labelColor: myColors.iconThemeColor,
          labelStyle: const TextStyle(
            height: 1,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: myColors.textGrey,
          unselectedLabelStyle: const TextStyle(fontSize: 16, height: 1),
          tabs: [
            Tab(
              text: '我加入的'.tr(),
            ),
            Badge(
              offset: const Offset(9, 13),
              largeSize: 8,
              isLabelVisible: groupApplyNotRead.groupMyCreateApplyNotRead > 0,
              backgroundColor: myColors.redTitle,
              label: const Text(
                '',
              ),
              child: Tab(
                text: '我创建的'.tr(),
              ),
            ),
            Badge(
              offset: const Offset(9, 13),
              largeSize: 8,
              isLabelVisible: groupApplyNotRead.groupMyJoinApplyNotRead > 0,
              backgroundColor: myColors.redTitle,
              label: const Text(
                '',
              ),
              child: Tab(
                text: '我管理的'.tr(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      keywords = args['keywords'] ?? '';
      if (keywords.isNotEmpty) {
        _controller.text = keywords;
        setState(() {});
      }
    });
    getList();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('我的群组'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                controller: _controller,
                onChanged: (str) {
                  setState(() {
                    keywords = str;
                  });
                },
              ),
              if (keywords == '') tab(),
              Expanded(
                child: Container(
                  color: bgColor,
                  child: keywords == ''
                      ? TabBarView(
                          controller: _tabController,
                          children: [
                            for (var v in _targetsType)
                              RefreshIndicator(
                                onRefresh: () async {
                                  await getList();
                                },
                                child: ListView(
                                  children: [
                                    for (var e in groupData)
                                      if ((e.roomName!
                                                  .toLowerCase()
                                                  .contains(keywords) &&
                                              (e.identity == v)) ||
                                          ((e.roomMark ?? '')
                                                  .toLowerCase()
                                                  .contains(keywords) &&
                                              (e.identity == v)))
                                        FriendGroupItem(e, keywords,
                                            callBack: getList),
                                  ],
                                ),
                              )
                          ],
                        )
                      : ListView(
                          children: [
                            for (var e in groupData)
                              if (e.roomName!
                                      .toLowerCase()
                                      .contains(keywords) ||
                                  (e.roomMark ?? '')
                                      .toLowerCase()
                                      .contains(keywords))
                                FriendGroupItem(e, keywords, callBack: getList),
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
}

class FriendGroupItem extends StatelessWidget {
  final GRoomModel data;
  final Function? callBack;
  final String keywords;

  const FriendGroupItem(this.data, this.keywords, {this.callBack, super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    var e = data;
    var name = e.roomName ?? '';
    var mark = e.roomMark ?? '';
    var title = '$name${mark.isNotEmpty ? ' ($mark)' : ''}';
    return ChatItem(
      titleSize: 17,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pushNamed(
          context,
          ChatTalk.path,
          arguments: ChatTalkParams(
            roomId: e.id ?? '',
            name: name,
            mark: mark,
            totalCount: e.totalCount ?? '',
          ),
        ).then((value) {
          callBack?.call();
        });
      },
      data: ChatItemData(
        icons: [e.roomAvatar ?? ''],
        id: e.id,
        title: name,
        mark: mark,
        notReadNumber: toInt(e.unreadCount),
        room: true,
      ),
      hasSlidable: false,
      titleWidget: Row(
        children: [
          Expanded(
            flex: 1,
            child: LightText(
              keywords.isNotEmpty ? title : name,
              keywords,
              style: TextStyle(
                fontSize: 17,
                color: textColor,
              ),
            ),
          ),
          Badge(
            isLabelVisible: toInt(e.unreadCount) > 0,
            backgroundColor: myColors.redTitle,
            label: Text(e.unreadCount ?? ''),
          )
        ],
      ),
      // titleWidget: e.roomMark != null && e.roomMark!.isNotEmpty
      //     ? Text.rich(
      //         TextSpan(
      //           text: e.roomMark,
      //           children: [
      //             TextSpan(
      //               text: ' (${e.roomName})',
      //               style: const TextStyle(
      //                 fontSize: 12,
      //                 color: myColors.textGrey,
      //               ),
      //             ),
      //           ],
      //         ),
      //         overflow: TextOverflow.ellipsis,
      //       )
      //     : null,
    );
  }
}
