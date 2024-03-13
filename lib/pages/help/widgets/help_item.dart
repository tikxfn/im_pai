import 'package:flutter/material.dart';
import 'package:unionchat/widgets/network_image.dart';

import '../../../notifier/theme_notifier.dart';

//帮助内容组件
class HelpItem extends StatelessWidget {
  final HelpItemData data;
  final Function()? onTap;

  const HelpItem({required this.data, this.onTap, super.key});

  //浏览量等数据组件
  countItem(IconData icon, int num) {
    var myColors = ThemeNotifier();
    return Container(
      alignment: Alignment.center,
      height: 40,
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        children: [
          Icon(
            icon,
            color: myColors.textGrey,
            size: 16,
          ),
          const SizedBox(width: 2),
          Text(
            num.toString(),
            style: TextStyle(
              color: myColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double spacing = 15;
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing, left: spacing, right: spacing),
        decoration: BoxDecoration(
          color: myColors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 1,
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //封面
                  Stack(
                    children: [
                      AppNetworkImage(
                        data.cover,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: myColors.primary,
                          ),
                          child: Text(
                            data.coverTarget,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: myColors.textBlack,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      // color: myColors .textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '标签：',
                        style: TextStyle(
                          fontSize: 12,
                          color: myColors.textGrey,
                        ),
                      ),
                      if (data.targets != null && data.targets!.isNotEmpty)
                        for (var i = 0; i < data.targets!.length; i++)
                          Text(
                            '#${data.targets![i]} ',
                            style: TextStyle(
                              fontSize: 12,
                              color: myColors.primary,
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: myColors.lineGrey,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: myColors.textGrey,
                    ),
                  ),
                  Row(
                    children: [
                      countItem(Icons.remove_red_eye, data.view),
                      countItem(Icons.favorite, data.like),
                      countItem(Icons.comment, data.comment),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//帮助列表数据modal
class HelpItemData {
  //封面
  final String cover;

  //封面标签
  final String coverTarget;

  //标题
  final String title;

  //内容
  final String detail;

  //标签
  final List<String>? targets;

  //日期
  final String date;

  //浏览量
  final int view;

  //点赞量
  final int like;

  //评论量
  final int comment;

  HelpItemData({
    required this.cover,
    required this.coverTarget,
    required this.title,
    required this.detail,
    required this.targets,
    required this.date,
    required this.view,
    required this.like,
    required this.comment,
  });
}
