import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/help/help_home.dart';
import 'package:provider/provider.dart';

//弹出button框
// ignore: must_be_immutable
class CommentButton extends StatefulWidget {
  List<CommunityButtonData> data;
  final double imageSize;
  final double fontSize;

  CommentButton({
    required this.data,
    this.imageSize = 53,
    this.fontSize = 14,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommentButtonState();
  }
}

class _CommentButtonState extends State<CommentButton> {
  @override
  Widget build(BuildContext context) {
    List<CommunityButtonData> data = widget.data;
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      // alignment: Alignment.center,
      decoration: BoxDecoration(
        color: myColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 34,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < data.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: data[i].onTap,
                    child: Column(
                      children: [
                        Image.asset(
                          data[i].avatar,
                          width: widget.imageSize,
                          height: widget.imageSize,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data[i].title,
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: widget.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 31,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Image.asset(
                        assetPath('images/my/btn_guanbi.png'),
                        fit: BoxFit.cover,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
