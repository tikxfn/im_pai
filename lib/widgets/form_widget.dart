import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../notifier/theme_notifier.dart';

//复选框
class AppCheckbox extends StatelessWidget {
  final bool value;
  final double size;
  final double paddingLeft;
  final double paddingRight;
  final bool disabled;

  const AppCheckbox({
    required this.value,
    this.size = 20,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.disabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    var color = value ? myColors.circleBlueButtonBg : myColors.lineGrey;
    if (disabled) color = myColors.grey;
    return Padding(
      padding: EdgeInsets.only(
        right: paddingRight,
        left: paddingLeft,
      ),
      child: Icon(
        value ? Icons.check_circle : Icons.circle_outlined,
        color: color,
        size: size,
      ),
    );
  }
}

//选择框
class AppSelect extends StatelessWidget {
  final String? title;
  final String text;
  final Widget? leading;
  final bool borderTop;
  final bool borderBottom;
  final double horizontal;
  final Function()? onTap;

  const AppSelect({
    this.title,
    this.text = '',
    this.leading,
    this.borderTop = true,
    this.borderBottom = true,
    this.horizontal = 0,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 50),
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        decoration: BoxDecoration(
          // color: myColors.white,
          border: Border(
            top: borderTop
                ? BorderSide(
                    color: myColors.lineGrey,
                    width: .5,
                  )
                : BorderSide.none,
            bottom: borderBottom
                ? BorderSide(
                    color: myColors.lineGrey,
                    width: .5,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            if (title != null && title!.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(right: 20),
                child: Text(title!),
              ),
            if (leading != null) leading!,
            Expanded(
              flex: 1,
              child: Text(text),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

//输入框
class AppInput extends StatelessWidget {
  final String? title;
  final String? labelText;
  final String? hintText;
  final Widget? leading;
  final bool borderTop;
  final bool borderBottom;
  final bool obscureText;
  final double horizontal;
  final TextInputType? keyboardType;
  final Widget? action;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? color;
  final Color? labelColor;
  final double? fontSize;
  final ValueChanged<String>? onChanged;
  final Function()? clear;
  final bool readOnly;
  final bool showClean;

  const AppInput({
    this.title,
    this.labelText,
    this.hintText,
    this.leading,
    this.borderTop = true,
    this.borderBottom = true,
    this.obscureText = false,
    this.readOnly = false,
    this.horizontal = 0,
    this.keyboardType,
    this.action,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.labelColor,
    this.fontSize = 14,
    this.onChanged,
    this.clear,
    this.showClean = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          // constraints: const BoxConstraints(minHeight: 50),
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          decoration: BoxDecoration(
            color: color,
            border: Border(
              top: borderTop
                  ? BorderSide(
                      color: myColors.lineGrey,
                      width: .5,
                    )
                  : BorderSide.none,
              bottom: borderBottom
                  ? BorderSide(
                      color: myColors.lineGrey,
                      width: .5,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              if (title != null && title!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(title!),
                ),
              if (leading != null) leading!,
              Expanded(
                flex: 1,
                child: SizedBox(
                  // color: myColors.black,
                  height: 30,
                  child: TextFormField(
                    readOnly: readOnly,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    onChanged: onChanged,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: showClean && controller!.text.isNotEmpty
                          ? InkWell(
                              onTap: clear,
                              child: Container(
                                // padding: const EdgeInsets.only(left: 0),
                                alignment: Alignment.centerRight,
                                width: 16,
                                height: 16,
                                child: Image.asset(
                                  assetPath('images/talk/sp_guanbi2.png'),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : null,
                      // labelText: labelText,
                      // labelStyle: TextStyle(color: labelColor),
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 0,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 5),
          height: 20,
          child: Text(
            labelText ?? '',
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

//多行输入框
class AppTextarea extends StatelessWidget {
  final TextEditingController? controller;
  final int? maxLength; //最大输入字数
  final bool autofocus;
  final Color? color;
  final int minLines;
  final int maxLines;
  final double fontSize;
  final double radius;
  final String hintText;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final Function()? clear;

  final bool showClean;

  const AppTextarea({
    this.controller,
    this.maxLength = 500,
    this.autofocus = false,
    this.radius = 0,
    this.color,
    this.minLines = 3,
    this.maxLines = 10,
    this.fontSize = 14,
    this.hintText = '请输入',
    this.readOnly = false,
    this.onChanged,
    this.clear,
    this.showClean = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color inputColor = myColors.chatInputColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color ?? inputColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            readOnly: readOnly,
            controller: controller,
            autofocus: autofocus,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              filled: true,
              fillColor: color ?? inputColor,
              hintText: hintText.tr(),
              helperStyle: TextStyle(
                color: textColor,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffix: showClean && controller!.text.isNotEmpty
                  ? InkWell(
                      onTap: clear,
                      child: Container(
                        // padding: const EdgeInsets.only(left: 0),
                        alignment: Alignment.centerRight,
                        width: 16,
                        height: 16,
                        child: Image.asset(
                          assetPath('images/talk/sp_guanbi2.png'),
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

//开关
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return CupertinoSwitch(
      value: value,
      activeColor: myColors.circleSelectCircleTagTitle,
      onChanged: onChanged,
    );
  }
}

//输入框
class AppInputBox extends StatelessWidget {
  final String? title;
  final String? labelText;
  final String? hintText;
  final Widget? leading;
  final double radius;
  final Widget? prefixIcon;
  final Widget? action;
  final bool obscureText;
  final double horizontal;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? color;
  final Color? fontColor;
  final Color? labelColor;
  final Color? hintColor;
  final double? fontSize;
  final double? labelSize;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const AppInputBox({
    this.title,
    this.labelText,
    this.hintText,
    this.leading,
    this.radius = 15,
    this.prefixIcon,
    this.action,
    this.obscureText = false,
    this.readOnly = false,
    this.horizontal = 0,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.fontColor,
    this.labelColor,
    this.hintColor,
    this.fontSize = 14,
    this.labelSize = 14,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: readOnly,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  cursorColor: fontColor,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: fontColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: prefixIcon,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: hintColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 10,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
        if (labelText != null && labelText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(top: 10),
            // height: 20,
            child: Text(
              labelText ?? '',
              style: TextStyle(
                color: labelColor ?? myColors.imRed,
                fontSize: labelSize,
              ),
            ),
          ),
      ],
    );
  }
}

//图片选择
// ignore: must_be_immutable
class AppImagePicker extends StatefulWidget {
  //已选择图片列表
  List<XFile> selectedAssets;
  final Function()? addImages;

  AppImagePicker({
    super.key,
    required this.selectedAssets,
    this.addImages,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppImagePickerState();
  }
}

class _AppImagePickerState extends State<AppImagePicker> {
  //图片最大选取数量
  int maxAssets = 9;

  //是否开始拖拽
  bool isDragNow = false;

  //是否将要删除
  bool isWillRemove = false;

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    double size = (MediaQuery.of(context).size.width - 40) / 3;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: myColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final asset in widget.selectedAssets)
                _imagesBox(asset, size), //图片项
              if (widget.selectedAssets.length < maxAssets)
                _addButton(size), //添加按钮
            ],
          ),
        ],
      ),
    );
  }

//图片项
  Widget _imagesBox(XFile asset, double size) {
    return Draggable<XFile>(
      //此可拖动对象将拖放的数据
      data: asset,

      //当可拖动对象开始被拖动时调用
      onDragStarted: () {
        setState(() {
          isDragNow = true;
        });
      },
      //当可拖动对象被放下时调用
      onDragEnd: (details) {
        setState(() {
          isDragNow = false;
          // isWillOrder = false;
        });
      },
      //当draggable 被放置并被[DragTarget]接受时调用
      onDragCompleted: () {
        // isWillRemove = true;
      },
      //当draggable 被放置但未被[DragTarget]接受时调用
      onDraggableCanceled: (velocity, offset) {
        isDragNow = false;
        // isWillOrder = false;
      },
      //拖动进行显示在指针下方的小部件
      feedback: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
        ),
        child: Image.file(
          File(asset.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
      //当正在进行的一个或多个拖动时显示的小组件而不是[child]
      childWhenDragging: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
        ),
        child: Image.file(
          File(asset.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(0.5),
        ),
      ),
      child: DragTarget<XFile>(
        builder: (context, candidateData, rejectedData) {
          return Image.file(
            File(asset.path),
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        },
        onAccept: (data) {
          //从队列中删除拖拽对象，
          final int index = widget.selectedAssets.indexOf(data);
          widget.selectedAssets.removeAt(index);
          //将拖拽对象插入到目标对象之前
          final int targetIndex = widget.selectedAssets.indexOf(asset);
          widget.selectedAssets.insert(targetIndex, data);
          setState(() {
            // isWillOrder = false;
            // targetAssetId = "";
          });
        },
      ),
    );
  }

//添加按钮
  GestureDetector _addButton(double size) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: widget.addImages,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: myColors.pageBackground,
        ),
        child: Icon(
          Icons.add,
          size: 30,
          color: myColors.lineGrey,
        ),
      ),
    );
  }
}
