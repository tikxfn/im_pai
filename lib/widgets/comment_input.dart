import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

//评论框
class CommentInput extends StatefulWidget {
  //键盘点击发送事件
  final Function(String, String, String?)? onSend;
  //动态id
  final String id;
  //评论人id
  final String? commentId;

  const CommentInput({
    required this.id,
    this.onSend,
    this.commentId,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommentInputState();
  }
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool isInputed = false;
  bool showEmojiPicker = false;

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: myColors.white,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: myColors.chatInputColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onEditingComplete: () {
                        Navigator.pop(context);
                        if (widget.onSend == null ||
                            _controller.text.trim() == '') return;
                        widget.onSend!(
                            _controller.text, widget.id, widget.commentId);
                      },
                      onChanged: (value) {
                        if (_controller.text.isEmpty) {
                          isInputed = false;
                        } else {
                          isInputed = true;
                        }
                        setState(() {});
                      },
                      controller: _controller,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 10,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        hintText: '说点什么吧'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: myColors.subIconThemeColor,
                        ),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  //表情按钮
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showEmojiPicker = !showEmojiPicker;
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        assetPath('images/friend_circle/input_emoji.png'),
                        width: 21,
                        height: 21,
                      ),
                    ),
                  ),
                  if (isInputed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          if (widget.onSend == null ||
                              _controller.text.trim() == '') return;
                          widget.onSend!(
                              _controller.text, widget.id, widget.commentId);
                        },
                        child: Icon(
                          Icons.send,
                          size: 21,
                          color: myColors.iconThemeColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          //表情选择
          AnimatedCrossFade(
            firstChild: emojiPickerWidget(),
            secondChild: Container(),
            crossFadeState: showEmojiPicker
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 150),
          ),
        ],
      ),
    );
  }

  //emoji表情组件
  Widget emojiPickerWidget() {
    var myColors = ThemeNotifier();
    return Container(
      color: myColors.tagColor,
      height: 240,
      child: EmojiPicker(
        onEmojiSelected: (cate, emoji) {
          if (_controller.text.isNotEmpty) {
            isInputed = true;
          }
        },
        textEditingController: _controller,
        config: Config(bgColor: myColors.tagColor),
      ),
    );
  }
}
