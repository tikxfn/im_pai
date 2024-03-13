import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/channel.dart';
import 'package:unionchat/db/model/channel_group.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/db/operator/channel_operator.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/message/sse_stream.dart';
import 'package:unionchat/notifier/network_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/chat/search_preview.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_model.dart';
import 'package:unionchat/pages/friend/scanpage.dart';
import 'package:unionchat/pages/help/help_home.dart';
import 'package:unionchat/pages/network_reconnect.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/popup_button.dart';
import 'package:unionchat/widgets/tab_bottom_height.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../account/password_question.dart';
import '../notice/notice_list.dart';

class ChatHome extends StatefulWidget {
  static ValueNotifier<bool> refreshing = ValueNotifier(false);

  const ChatHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatHomeState();
  }
}

class _ChatHomeState extends State<ChatHome> with TickerProviderStateMixin {
  double avatarSize = 45;
  double avatarFrameWidthSize = 15;
  double avatarFrameHeightSize = 25;
  int limit = 20;
  int index = -1;
  bool check = false;
  static bool openTop = false;
  List<String> _choiceIds = [];
  String winPreselectionId = ''; //win预选id
  final ScrollController _controller = ScrollController();
  static ChannelPageStatus _channelStatus = ChannelPageStatus.all;
  static String? _channelGroup;

  static int _channelGroupIndex = 0;

  // 第一次切换未读消息
  _firstChangeAllMessage() {
    var first = settingsBox.get('first_change_topic') ?? '';
    if (first.isNotEmpty) return;
    settingsBox.put('first_change_topic', '1');
    if (Global.context == null) return;
    confirm(
      Global.context!,
      content:
          '已切换至 "未读消息" 列表，单击页面坐上角标题 "未读消息"，或双击页面底部导航栏最左侧 "消息" 导航按钮，来显示 "所有消息" 列表。',
    );
  }

  // 切换已读未读
  _changeChannelStatus() {
    _channelStatus = _channelStatus == ChannelPageStatus.all
        ? ChannelPageStatus.unread
        : ChannelPageStatus.all;
    // _notifier.searchByCondition(ChannelCondition(
    //   status: _channelStatus,
    //   group: _channelGroup,
    // ));
    _firstChangeAllMessage();
  }

  // 回到顶部
  _goTop() {
    if (_controller.position.pixels <= 0) return;
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // 通知消息进入
  _noticeIn() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      if (Global.noticeReceiver.isEmpty && Global.noticeRoomId.isEmpty) {
        return;
      }
      Navigator.pushNamed(
        context,
        ChatTalk.path,
        arguments: ChatTalkParams(
          receiver: Global.noticeReceiver,
          roomId: Global.noticeRoomId,
        ),
      );
      Global.noticeReceiver = '';
      Global.noticeRoomId = '';
    });
  }

  // 是否注册进入
  registerFirstIn() {
    if (!Global.registerIn) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Global.registerIn = false;
      var cfm = await confirm(
        context,
        content:
            '为方便找回密码，请点击"设置密保"立即前往设置"密保问题"！或者自行前往"个人中心" -> "头像" -> "密保问题"设置密保问题。',
        enter: '设置密保'.tr(),
        cancel: '取消'.tr(),
      );
      if (cfm != true) return;
      if (mounted) Navigator.pushNamed(context, PasswordQuestion.path);
    });
  }

  // 请求电源管理权限
  requestPowerPermission() async {
    if (!Platform.isAndroid) return;
    var firstPowerRequest = settingsBox.get('firstPowerRequest') ?? '';
    if (firstPowerRequest.isNotEmpty) return;
    settingsBox.put('firstPowerRequest', '1');
    Permission.ignoreBatteryOptimizations.request();
    // logger.d(state);
  }

  //删除消息提示
  removeTopicConfirm(List<String> ids) {
    confirm(
      context,
      content: '确定要删除对话？'.tr(),
      onEnter: () => removeTopic(ids),
    );
  }

  //删除消息
  removeTopic(List<String> ids) async {
    loading();
    try {
      await MessageUtil.deleteChannel(ids);
      if (check) _choiceIds = [];
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //进入二维码扫描
  Future scanPage() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    var status = await Permission.camera.request();
    if (status.isGranted && mounted) {
      Navigator.pushNamed(context, ScanPage.path);
    }
  }

  //选择事件
  choose(ChatItemData e) {
    var id = e.pairId ?? '';
    if (id.isEmpty) return;
    if (_choiceIds.contains(id)) {
      _choiceIds.remove(id);
    } else {
      _choiceIds.add(id);
    }
    setState(() {});
  }

  //列表点击事件
  listTap(ChatItemData e) {
    if (check) {
      choose(e);
      return;
    }
    Adapter.navigatorTo(ChatTalk.path, arguments: chat2talkParams(e));
  }

  //已读
  _read() async {
    loading();
    await ApiRequest.apiMessageRead(_choiceIds);
    loadClose();
  }

  //置顶
  _setTop(ChatItemData data) {
    if ((data.pairId ?? '').isEmpty) {
      tipError('PairId is empty');
      return;
    }
    MessageUtil.top(data.pairId!, !data.isTop);
  }

  //静音
  _setMute(ChatItemData data, bool isRemind) {
    if ((data.pairId ?? '').isEmpty) {
      tipError('PairId is empty');
      return;
    }
    MessageUtil.silence(data.pairId!, isRemind);
  }

  _init() async {
    if (ChannelListNotifier().channels.isEmpty) {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: _channelStatus,
        group: _channelGroup,
      ));
    }
    // var notifier = TopicListNotifier();
    // if (notifier.list.isEmpty) await notifier.refresh();
    requestPowerPermission();
    registerFirstIn();
    _noticeIn();
  }

  int tabLength = 4;
  List<String> systemList = ['消息', '未读', '单聊', '群聊'];
  late TabController _tabController;
  bool firstCreateTab = true;

//标签分组
  Widget _tabs(List<String> targets) {
    var myColors = ThemeNotifier();
    List<String> list = [...systemList, ...targets];
    //当tabLength长度改变时给_tabController重新赋值
    if (tabLength != targets.length + 4 || firstCreateTab) {
      tabLength = targets.length + 4;
      _tabController = TabController(length: tabLength, vsync: this);
      _channelGroup = null;
      _channelGroupIndex = 0;
    }
    firstCreateTab = false;
    //如果当前选择被删除重置
    if (!targets.contains(_channelGroup) &&
        !systemList.contains(_channelGroup)) {
      _channelGroup = null;
      _channelGroupIndex = 0;
    }
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        color: myColors.themeBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: myColors.bottomShadow,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              controller: _tabController,
              isScrollable: true,
              indicatorColor: myColors.circleBlueButtonBg,
              indicatorWeight: 3.0,
              labelColor: myColors.iconThemeColor,
              labelStyle: const TextStyle(
                height: 1,
                fontSize: 16,
              ),
              onTap: (value) {
                _channelGroup = list[value].isEmpty ? null : list[value];
                _channelGroupIndex = value;
                setState(() {});
                searchTab(groupName: _channelGroup);
              },
              unselectedLabelColor: myColors.textGrey,
              unselectedLabelStyle: const TextStyle(fontSize: 15, height: 1),
              tabs: list.map((e) {
                return Tab(
                  height: 40,
                  text: e,
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            color: myColors.bottom,
            child: GestureDetector(
              onTap: () {
                //打开更多分组
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return moreTabBottom(list: list);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Icon(
                  Icons.more_horiz,
                  color: myColors.subIconThemeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //tab切换搜索
  searchTab({String? groupName}) {
    if (_channelGroup == '消息') {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: ChannelPageStatus.all,
        group: null,
      ));
    } else if (_channelGroup == '未读') {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: ChannelPageStatus.unread,
        group: null,
      ));
    } else if (_channelGroup == '单聊') {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: ChannelPageStatus.all,
        isRoom: false,
        group: null,
      ));
    } else if (_channelGroup == '群聊') {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: ChannelPageStatus.all,
        isRoom: true,
        group: null,
      ));
    } else {
      ChannelListNotifier().searchByCondition(ChannelCondition(
        status: ChannelPageStatus.all,
        group: _channelGroup,
      ));
    }
  }

  //底部弹出更多tab分组选项
  Widget moreTabBottom({required List<String> list}) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: myColors.themeBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  const Text(
                    '更多聊天分组',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: myColors.subIconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: myColors.lineGrey),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var active = index == _channelGroupIndex;
                  return InkWell(
                    onTap: () {
                      _channelGroup = list[index].isEmpty ? null : list[index];
                      _channelGroupIndex = index;
                      setState(() {});
                      Navigator.pop(context);
                      searchTab(groupName: _channelGroup);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: myColors.noticeBoder,
                            width: .5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              list[index],
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: active ? 17 : 15,
                                fontWeight: active ? FontWeight.w600 : null,
                                color: active
                                    ? myColors.iconThemeColor
                                    : myColors.subIconThemeColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 头部公告
  Widget _appNotice() {
    var myColors = ThemeNotifier();
    return ValueListenableBuilder(
      valueListenable: UnreadValue.notice,
      builder: (context, notice, _) {
        return ValueListenableBuilder(
          valueListenable: UnreadValue.noticeNotRead,
          builder: (context, noticeNotRead, _) {
            if (notice == null ||
                (notice.title ?? '').isEmpty ||
                noticeNotRead <= 0) {
              return Container();
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                UnreadValue.noticeNotRead.value = 0;
                Adapter.navigatorTo(NoticeList.path);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: myColors.chatInputColor,
                ),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        assetPath('images/talk/gonggao.png'),
                        width: 16,
                        height: 16,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 35,
                        child: Marquee(
                          text: (notice.title ?? '').isNotEmpty
                              ? notice.title!
                              : '',
                          blankSpace: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: myColors.iconThemeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //头部自定义tabBar
  Widget _tabBarContainer() {
    var myColors = ThemeNotifier();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //圈子广场
            ValueListenableBuilder(
              valueListenable: UnreadValue.circleNotRead,
              builder: (context, value, _) {
                return ValueListenableBuilder(
                  valueListenable: UnreadValue.circleApplyNotRead,
                  builder: (context, apply, _) {
                    return ValueListenableBuilder(
                      valueListenable: UnreadValue.circleMyApplyNotRead,
                      builder: (context, myApply, _) {
                        final int circleNotRead = apply.applicationNotRead +
                            value.circleTrendsNotRead +
                            myApply;
                        return GestureDetector(
                          onTap: () {
                            Adapter.navigatorTo(HelpHome.path).then((value) {
                              setState(() {});
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            color: Colors.transparent,
                            child: Badge(
                              isLabelVisible: circleNotRead > 0,
                              offset: const Offset(10, -8),
                              backgroundColor: myColors.redTitle,
                              label: Text(circleNotRead.toString()),
                              largeSize: 14,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  '圈子广场',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            _appBarActions(),
          ],
        ),
      ),
    );
  }

  //头部BarActions组件
  Widget _appBarActions() {
    var myColors = ThemeNotifier();
    return check
        ? TextButton(
            onPressed: () {
              setState(() {
                check = false;
                _choiceIds = [];
              });
            },
            child: Text(
              '取消'.tr(),
              style: TextStyle(
                color: ThemeNotifier().iconThemeColor,
                fontSize: 15,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 同步状态
              ValueListenableBuilder(
                valueListenable: SSEStream.syncing,
                builder: (ctx, value, _) {
                  if (value) {
                    return Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 10),
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: myColors.lineGrey,
                          ),
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
              // const RealisticClock(),
              // IconButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed(IsarData.path);
              //   },
              //   icon: const Icon(Icons.abc),
              // ),
              if (!check) searchWidget(),
              const SizedBox(width: 5),
              if (!check) PopupButton(scan: scanPage, target: true),
              // const SizedBox(
              //   width: 5,
              // ),
            ],
          );
  }

  //搜索按钮
  Widget searchWidget() {
    return InkWell(
      onTap: () {
        Adapter.navigatorTo(SearchPreview.path);
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          assetPath('images/talk/search.png'),
          width: 18,
          height: 18,
          color: ThemeNotifier().iconThemeColor,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) _init();
      AppNetworkNotifier.listenNetwork();
    });
  }

  @override
  void dispose() {
    super.dispose();
    AppNetworkNotifier.listenDispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelListNotifier>(
      builder: (context, data, child) {
        var originList = data.channels;
        // var myColors = context.watch<ThemeNotifier>();
        int topNumber = 0;
        for (var v in originList) {
          if (toInt(v.value.topTime) > 0) topNumber++;
        }
        var topUpperLimit = topNumber > 10;

        List<ValueNotifier<Channel>> list = [];
        int lastIndex = -1;
        if (topUpperLimit && !openTop) {
          bool topLastAdd = false;
          for (var v in originList) {
            var isTop = toInt(v.value.topTime) > 0;
            if (!isTop || (isTop && !topLastAdd)) {
              list.add(v);
              topLastAdd = true;
            }
          }
        } else {
          list = originList;
        }
        // String title =
        //     _channelStatus == ChannelPageStatus.all ? '所有消息'.tr() : '未读消息'.tr();
        // if (check) title = '请选择'.tr();
        return ThemeImage(
          child: Scaffold(
            // extendBodyBehindAppBar: false,
            resizeToAvoidBottomInset: false,
            // appBar: AppBar(
            //   elevation: 0,
            //   // backgroundColor: Colors.transparent,
            //   // leading: _appBarLeading(circleNotRead, topColor),
            //   title: ValueListenableBuilder(
            //     valueListenable: ChatHome.refreshing,
            //     builder: (context, value, _) {
            //       if (value) {
            //         return Row(
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(right: 5),
            //               child: SizedBox(
            //                 width: 15,
            //                 height: 15,
            //                 child: CircularProgressIndicator(
            //                   color: myColors.iconThemeColor,
            //                   strokeWidth: 2,
            //                 ),
            //               ),
            //             ),
            //             Text(
            //               '消息同步中',
            //               style: TextStyle(
            //                 color: myColors.iconThemeColor,
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         );
            //       } else {
            //         return GestureDetector(
            //           behavior: HitTestBehavior.opaque,
            //           onTap: _goTop,
            //           child: Row(
            //             children: [
            //               GestureDetector(
            //                 onTap: _changeChannelStatus,
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     Text(
            //                       title,
            //                       style: TextStyle(
            //                         color: myColors.iconThemeColor,
            //                         fontSize: 20,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                     if (!check)
            //                       Padding(
            //                         padding: const EdgeInsets.only(left: 5),
            //                         child: Icon(
            //                           Icons.sync_alt,
            //                           color: myColors.iconThemeColor,
            //                           size: 18,
            //                         ),
            //                       ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         );
            //       }
            //     },
            //   ),
            //   centerTitle: false,
            //   //  actions:  _appBarActions(),
            //   //im2
            //   actions: [
            //     _appBarActions(),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //   ],
            // ),

            body: SafeArea(
              child: Column(
                children: [
                  _tabBarContainer(),
                  Expanded(
                    child: ThemeBody(
                      topPadding: 0,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ChatHomeNetwork(),
                                ValueListenableBuilder(
                                  valueListenable: ChannelGroupOperator.groups,
                                  builder: (context, targets, _) {
                                    List<String> list = [];
                                    for (var v in targets) {
                                      var str = v
                                          .replaceAll(' ', '')
                                          .replaceAll('\n', '');
                                      if (str.isEmpty) continue;
                                      list.add(v);
                                    }
                                    return _tabs(list);
                                  },
                                ),
                                _appNotice(),
                                if (list.isEmpty) const ChatHomeChannelEmpty(),
                                if (list.isNotEmpty)
                                  Expanded(
                                    flex: 1,
                                    child: Stack(
                                      children: [
                                        ListView.builder(
                                          controller: _controller,
                                          itemCount: list.length,
                                          itemBuilder: (context, i) {
                                            var e = channel2chatItem(
                                              list[i].value,
                                            );
                                            bool last = false;
                                            if (i == list.length - 1) {
                                              last = true;
                                            }
                                            //判断组名
                                            return ChatHomeChannel(
                                              list[i],
                                              last: last,
                                              check: check,
                                              active:
                                                  _choiceIds.contains(e.pairId),
                                              openTop: openTop,
                                              showBottomHeight: last &&
                                                  !(check &&
                                                      _choiceIds.isNotEmpty),
                                              showLimit: topUpperLimit &&
                                                  e.isTop &&
                                                  (!openTop ||
                                                      (openTop &&
                                                          i == lastIndex)),
                                              onLongPress: () {
                                                setState(() {
                                                  check = true;
                                                });
                                              },
                                              onHover: (event) {
                                                if (platformPhone) return;
                                                winPreselectionId = e.pairId!;
                                                setState(() {});
                                              },
                                              onExit: (event) {
                                                winPreselectionId = '';
                                                setState(() {});
                                              },
                                              onTap: () => listTap(e),
                                              onTop: () => _setTop(e),
                                              onMute: (isRemind) =>
                                                  _setMute(e, isRemind),
                                              onDelete: () {
                                                removeTopicConfirm([
                                                  e.pairId ?? '',
                                                ]);
                                              },
                                              onLimit: () {
                                                setState(() {
                                                  openTop = !openTop;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                        if (topUpperLimit)
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: ChatHomeLimitButton(
                                              open: openTop,
                                              onTap: () {
                                                setState(() {
                                                  openTop = !openTop;
                                                });
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (check && _choiceIds.isNotEmpty)
                            ChatHomeBottomEdit(
                              onRead: _read,
                              onRemove: () => removeTopicConfirm(_choiceIds),
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
        // return _body(context, data.channels);
      },
    );
  }
}

// 网络组件
class ChatHomeNetwork extends StatelessWidget {
  const ChatHomeNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return ValueListenableBuilder(
      valueListenable: AppNetworkNotifier.state,
      builder: (context, value, _) {
        if (value == AppNetworkState.link) {
          return Container();
        }
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppNetworkReconnect(),
              ),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: myColors.im2Refuse,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.priority_high,
                  size: 18,
                  color: myColors.white,
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: Text(
                    value.toChar,
                    style: TextStyle(
                      color: myColors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: myColors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 列表空组件
class ChatHomeChannelEmpty extends StatelessWidget {
  const ChatHomeChannelEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath('images/talk/sp_mbg.png'),
            width: 240,
            height: 180,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              '聊天更私密'.tr(),
              style: TextStyle(
                color: myColors.textGrey,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              '消息加密，双向删除，超级大群，定时清理'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: myColors.textGrey,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// channel列表
class ChatHomeChannel extends StatelessWidget {
  final ValueNotifier<Channel> notifier;
  final bool last;
  final Function()? onTap;
  final Function()? onTop;
  final Function(bool)? onMute;
  final Function()? onDelete;
  final Function()? onLimit;
  final Function()? onLongPress;
  final Function(dynamic)? onHover;
  final Function(dynamic)? onExit;
  final bool check;
  final bool active;
  final bool showLimit;
  final bool openTop;
  final bool showBottomHeight;

  const ChatHomeChannel(
    this.notifier, {
    this.last = false,
    this.check = false,
    this.active = false,
    this.showLimit = false,
    this.openTop = false,
    this.showBottomHeight = false,
    this.onTap,
    this.onTop,
    this.onMute,
    this.onDelete,
    this.onLimit,
    this.onLongPress,
    this.onHover,
    this.onExit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                hitTestBehavior: HitTestBehavior.opaque,
                onHover: onHover,
                onExit: onExit,
                child: Row(
                  children: [
                    if (check)
                      AppCheckbox(
                        value: active,
                        paddingLeft: 10,
                      ),
                    Expanded(
                      flex: 1,
                      child: ValueListenableBuilder(
                          valueListenable: notifier,
                          builder: (context, value, _) {
                            final e = channel2chatItem(value);
                            // var nowPairId = ChannelPageNotifier.getPairId();
                            return ChatItem(
                              // onlineStatus: true,
                              onTap: onTap,
                              data: e,
                              titleSize: 17,
                              subtitleFontSize: 15,
                              border: true,
                              showMute: true,
                              // noTip: true,
                              // notReadNumber: 10,
                              onTop: onTop,
                              onMute: () {
                                onMute?.call(!e.doNotDisturb);
                              },
                              onDelete: onDelete,
                              // active: nowPairId == e.pairId,
                              // backgroundColor: winPreselectionId ==
                              //         e.pairId!
                              //     ? winPreselectionColor
                              //     : e.isTop
                              //         ? winPreselectionColor
                              //         : null,
                              textEnd: !e.doNotDisturb
                                  ? null
                                  : Container(
                                      padding: const EdgeInsets.only(right: 5),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        assetPath('images/jingyanzhong.png'),
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              if (showLimit)
                GestureDetector(
                  onTap: onLimit,
                  child: Container(
                    color: myColors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          openTop ? '收起' : '展开',
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                        Icon(
                          openTop ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: myColors.textGrey,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showBottomHeight) const TabBottomHeight(),
      ],
    );
  }
}

// 底部操作栏
class ChatHomeBottomEdit extends StatelessWidget {
  final Function()? onRead;
  final Function()? onRemove;

  const ChatHomeBottomEdit({this.onRead, this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRead,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Text(
                  '标记已读'.tr(),
                  style: TextStyle(
                    color: myColors.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Text(
                  '删除'.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    color: myColors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
        // const TabBottomHeight(),
      ],
    );
  }
}

// 折叠展开、收起按钮
class ChatHomeLimitButton extends StatelessWidget {
  final bool open;
  final Function()? onTap;

  const ChatHomeLimitButton({
    this.open = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Material(
      color: myColors.greenOpacity,
      borderRadius: BorderRadius.circular(40),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            open ? Icons.close_fullscreen : Icons.open_in_full,
            color: myColors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
