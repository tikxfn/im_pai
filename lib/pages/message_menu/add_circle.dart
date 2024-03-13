import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/friend/friend_search.dart';
import 'package:unionchat/pages/message_menu/list_data.dart';
import 'package:provider/provider.dart';

class AddCirclePages extends StatefulWidget {
  const AddCirclePages({Key? key}) : super(key: key);
  static const String path = 'addFriends/page';

  @override
  State<AddCirclePages> createState() => _AddCirclePagesState();
}

class _AddCirclePagesState extends State<AddCirclePages> {
  bool showQr = false;

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.backGroundColor,
      appBar: AppBar(
        title: const Text('添加朋友'),
        backgroundColor: myColors.backGroundColor,
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    var myColors = ThemeNotifier();
    return Column(children: [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, FriendSearch.path);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: myColors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_sharp),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '账号/手机号',
                    style: TextStyle(fontSize: 17),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () {
          setState(() {
            showQr = !showQr;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '我的账号：${Global.user!.account!}',
              style: TextStyle(fontSize: 15, color: myColors.textBlack),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              Icons.qr_code,
              size: 20,
              color: myColors.primary,
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      if (!showQr)
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              return createItem(index);
            },
            itemCount: listAddFiendsData.length,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(height: 1.0, color: myColors.backGroundColor),
          ),
        ),
    ]);
  }

  Widget createItem(int index) {
    var myColors = ThemeNotifier();
    return Container(
      color: myColors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ListTile(
          //其次再来分析这个return，这里它的作用是，每次返回改变后的值赋给tempList
          leading: Container(
            width: 60,
            height: 60,
            //超出部分，可裁剪
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(listAddFiendsData[index]['imageUrl']),
          ),
          title: Text(listAddFiendsData[index]['title']),
          subtitle: Text(listAddFiendsData[index]['author']),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            tip(listAddFiendsData[index]['title']);
          },
        ),
      ),
    );
  }
}
