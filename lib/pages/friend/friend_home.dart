import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/user_info_utils.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/friend/friend_new_friends.dart';
import 'package:unionchat/pages/friend/scanpage.dart';
import 'package:unionchat/widgets/chat_item.dart';
// import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/popup_button.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../adapter/adapter.dart';
import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';
import 'friend_group.dart';
import 'friend_label.dart';

class FriendHome extends StatefulWidget {
  const FriendHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FriendHomeState();
  }
}

class _FriendHomeState extends State<FriendHome> {
  String keywords = '';
  String count = '';

  @override
  void initState() {
    super.initState();
    if (mounted) {
      UserInfoUtils.syncFriends();
    }
  }

  //进入二维码扫描
  Future scanPage() async {
    var status = await Permission.camera.request();
    if (status.isGranted && mounted) {
      Navigator.pushNamed(context, ScanPage.path);
      // Navigator.pushNamed(context, ScanPage.path).then((value) => getList());
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color bgColor = myColors.themeBackgroundColor;
    final notifier = context.watch<FriendListNotifier>();
    // double iconSize = 46;
    count = notifier.list.length.toString();
    return ThemeImage(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            '通讯录'.tr(),
            style: TextStyle(
              color: myColors.iconThemeColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            PopupButton(
              // reload: getList,
              scan: scanPage,
            ),
          ],
        ),
        body: SafeArea(
          child: KeyboardBlur(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: SearchInput(
                      height: 45,
                      radius: 30,
                      padding: EdgeInsets.zero,
                      onChanged: (str) {
                        setState(() {
                          keywords = str;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ContactList(
                      showCount: notifier.list.isNotEmpty && keywords == '',
                      count: count,
                      list: [
                        [
                          ContractData(
                            widget: Builder(builder: (context) {
                              return ValueListenableBuilder(
                                valueListenable: UnreadValue.friendNotRead,
                                builder: (context, friendNotRead, _) {
                                  return ValueListenableBuilder(
                                    valueListenable:
                                        UnreadValue.groupApplyNotRead,
                                    builder: (context, groupApply, _) {
                                      return ValueListenableBuilder(
                                        valueListenable:
                                            UnreadValue.groupMyApplyNotRead,
                                        builder: (context, groupMyApply, _) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              bottom: 20,
                                            ),
                                            child: RowList(
                                              rowNumber: 3,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Adapter.navigatorTo(
                                                        FriendNewFriends.path);
                                                  },
                                                  child: itemWidget(
                                                    image:
                                                        'images/new_friend.png',
                                                    title: '新的朋友'.tr(),
                                                    notReadNumber:
                                                        friendNotRead +
                                                            groupMyApply,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Adapter.navigatorTo(
                                                        FriendGroup.path);
                                                  },
                                                  child: itemWidget(
                                                    image:
                                                        'images/my_group.png',
                                                    title: '我的群组'.tr(),
                                                    notReadNumber: groupApply
                                                        .groupApplyNotRead,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Adapter.navigatorTo(
                                                        FriendLabel.path);
                                                  },
                                                  child: itemWidget(
                                                    image:
                                                        'images/btn_biaoqianfenzu.png',
                                                    title: '标签分组'.tr(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          // MenuUl(
                                          //   marginTop: 0,
                                          //   lineSpacing: 8,
                                          //   children: [
                                          //     MenuItemData(
                                          //       arrow: false,
                                          //       icon: assetPath(
                                          //           'images/new_friend.png'),
                                          //       iconSize: iconSize,
                                          //       title: '新的朋友'.tr(),
                                          //       titleSize: 17,
                                          //       notReadNumber: friendNotRead +
                                          //           groupMyApply,
                                          //       onTap: () {
                                          //         Adapter.navigatorTo(
                                          //             FriendNewFriends.path);
                                          //       },
                                          //     ),
                                          //     MenuItemData(
                                          //       arrow: false,
                                          //       icon: assetPath(
                                          //           'images/my_group.png'),
                                          //       iconSize: iconSize,
                                          //       title: '我的群组'.tr(),
                                          //       titleSize: 17,
                                          //       notReadNumber: groupApply
                                          //           .groupApplyNotRead,
                                          //       onTap: () {
                                          //         Adapter.navigatorTo(
                                          //             FriendGroup.path);
                                          //       },
                                          //     ),
                                          //     MenuItemData(
                                          //       arrow: false,
                                          //       icon: assetPath(
                                          //           'images/btn_biaoqianfenzu.png'),
                                          //       iconSize: iconSize,
                                          //       title: '标签分组'.tr(),
                                          //       titleSize: 17,
                                          //       onTap: () {
                                          //         Adapter.navigatorTo(
                                          //             FriendLabel.path);
                                          //       },
                                          //     ),
                                          //   ],
                                          // );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }),
                            name: '我的群组'.tr(),
                            tagIndex: '∧',
                          ),
                        ],
                      ],
                      orderList: [
                        for (var e in notifier.search(keywords))
                          ContractData(
                            name: (e.mark ?? '').isNotEmpty
                                ? e.mark ?? ''
                                : e.nickname ?? '',
                            widget: ChatItem(
                              onlineStatus: true,
                              titleSize: 16,
                              avatarSize: 46,
                              avatarTopPadding: 6,
                              avatarFrameSizeHight: 24,
                              avatarFrameSizeWidth: 14,
                              hasSlidable: false,
                              data: e.toChatItem(),
                              onTap: () {
                                Adapter.navigatorTo(
                                  FriendDetails.path,
                                  arguments: {
                                    'id': e.id,
                                    'removeToTabs': true,
                                    'detail': e.toGUserModel(),
                                    'isFriend': true,
                                  },
                                ).then((value) {
                                  // getList();
                                });
                              },
                              end: Container(
                                width: 30,
                              ),
                            ),
                          )
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

  Widget itemWidget({
    required String image,
    required String title,
    int notReadNumber = 0,
  }) {
    var myColors = ThemeNotifier();
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      alignment: Alignment.center,
      child: Badge(
        isLabelVisible: notReadNumber > 0,
        offset: const Offset(5, -5),
        backgroundColor: myColors.redTitle,
        label: Text(notReadNumber.toString()),
        largeSize: 14,
        child: Column(
          children: [
            Image.asset(
              assetPath(image),
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
