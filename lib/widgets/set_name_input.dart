import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:provider/provider.dart';

class SetNameInput extends StatefulWidget {
  //标题
  final String title;
  final String subTitle;

  //取消文字
  final String cancelText;

  //确定文字
  final String enterText;

  //输入框默认值
  final String value;

  //输入框提示文字
  final String hint;

  //输入框底部提示文字
  final String tip;
  //是否是多行文本
  final bool isAppTextarea;

  //输入框底部提示child
  final Widget? tipChild;

  //保存
  final Future<bool> Function(String)? onEnter;

  final int minLines;
  final int? maxLength;
  final double fontSize;

  const SetNameInput({
    this.title = '',
    this.subTitle = '',
    this.cancelText = '取消',
    this.enterText = '确定',
    this.value = '',
    this.hint = '请输入',
    this.tip = '',
    this.minLines = 8,
    this.fontSize = 16,
    this.maxLength,
    this.isAppTextarea = true,
    this.tipChild,
    this.onEnter,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SetNameInputState();
  }
}

class _SetNameInputState extends State<SetNameInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    if (mounted) _controller.text = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color chatInputColor = myColors.chatInputColor;
    return ThemeImage(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title.tr()),
        ),
        body: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.subTitle.tr() != '')
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 17,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: myColors.circleBlueButtonBg,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.subTitle.tr(),
                                    maxLines: 5,
                                    style: TextStyle(
                                      height: 1,
                                      color: textColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: widget.isAppTextarea
                              ? AppTextarea(
                                  controller: _controller,
                                  autofocus: true,
                                  hintText: widget.hint.tr(),
                                  color: chatInputColor,
                                  minLines: widget.minLines,
                                  fontSize: widget.fontSize,
                                  maxLength: widget.maxLength,
                                  showClean: true,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  clear: () {
                                    setState(() {
                                      _controller.clear();
                                    });
                                  },
                                )
                              : AppInput(
                                  controller: _controller,
                                  fontSize: widget.fontSize,
                                  borderTop: false,
                                  autofocus: true,
                                  horizontal: 15,
                                  hintText: widget.hint.tr(),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  clear: () {
                                    setState(() {
                                      _controller.clear();
                                    });
                                  },
                                ),
                        ),
                        if (widget.tip.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text(
                              widget.tip.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                        if (widget.tipChild != null) widget.tipChild!,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: CircleButton(
                      height: 47,
                      radius: 10,
                      title: widget.enterText.tr(),
                      theme: AppButtonTheme.blue,
                      fontSize: 16,
                      onTap: () async {
                        var back = true;
                        if (widget.onEnter != null) {
                          back = await widget.onEnter!(_controller.text);
                        }
                        if (back && mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class _SetNameInputState extends State<SetNameInput> {
//   final TextEditingController _controller = TextEditingController();
//   String roomId = '';
//   String userId = '';
//   bool allowEmpty = false; //是否允许为空
//   bool allowFormat = false; //是否进行格式验证
//   String title = ''; //标题
//
//   //保存
//   save() async {
//     if (allowEmpty) {
//       Navigator.pop(context, _controller.text);
//       return;
//     }
//     if (!allowEmpty) {
//       if (_controller.text.isEmpty) {
//         tipError('名字不能为空');
//         return;
//       }
//       if (allowFormat) {
//         if (!accountFormat(_controller.text)) {
//           tipError('账号输入不正确');
//           return;
//         }
//       }
//       Navigator.pop(context, _controller.text);
//     }
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     dynamic args = ModalRoute.of(context)!.settings.arguments;
//     if (args == null) return;
//     if (args['title'] != null) title = args['title']; //标题
//     if (args['inputName'] != null) _controller.text = args['inputName']; //文本内容
//     if (args['allowempty'] != null) allowEmpty = args['allowempty']; //是否允许为空
//     if (args['allowFormat'] != null) allowFormat = args['allowFormat']; //是否允许为空
//     if (args['roomId'] != null) roomId = args['roomId']; //群id
//     if (args['userId'] != null) userId = args['userId']; //用户id
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text(
//             '取消',
//             style: TextStyle(
//               color: myColors.red,
//             ),
//           ),
//         ),
//         title: Text(title),
//         actions: [
//           TextButton(
//             onPressed: save,
//             child: const Text('保存'),
//           ),
//         ],
//       ),
//       body: KeyboardBlur(
//         child: Column(
//           children: [
//             AppInput(
//               controller: _controller,
//               autofocus: true,
//               horizontal: 15,
//               hintText: '请输入',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
