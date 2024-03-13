import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

import 'network_image.dart';

//收藏列表组件
class NoteItemPro extends StatelessWidget {
  final NoteItemData data;
  final double marginBottom;
  final double vertical;
  final double horizontal;
  final double titleSize;
  final double textSize;
  final Widget? imageWidget;
  final Color? color;
  final Function()? onTap;
  final Function()? edit;
  final Function()? delete;
  final Function()? collect;
  final bool iscollect; //收藏状态
  final bool canRemarks; //可以备注
  final bool isMessage; //是否是消息
  final bool isNote; //可以备注
  final Function()? saveRemarks; //保存备注
  final Widget? statusWidget;

  const NoteItemPro(
    this.data, {
    this.marginBottom = 10,
    this.vertical = 10,
    this.horizontal = 10,
    this.titleSize = 15,
    this.textSize = 14,
    this.color,
    this.onTap,
    this.imageWidget,
    super.key,
    this.edit,
    this.delete,
    this.collect,
    this.saveRemarks,
    this.iscollect = false,
    this.canRemarks = false,
    this.isNote = true,
    this.isMessage = false,
    this.statusWidget,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    var text = data.text.trim().replaceAll('\n', '');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        decoration: BoxDecoration(
          color: color ?? myColors.tagColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: vertical,
                left: vertical,
                right: vertical,
              ),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageWidget != null) imageWidget!,
                  if (imageWidget == null &&
                      (data.image.isNotEmpty || data.cover.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AppNetworkImage(
                        data.image.isNotEmpty ? data.image : data.cover,
                        imageSpecification: data.image.isNotEmpty
                            ? ImageSpecification.w120
                            : ImageSpecification.nil,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //标题行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (data.title.isNotEmpty)
                              Expanded(
                                flex: 1,
                                child: Text(
                                  data.title.trim().replaceAll('\n', ''),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: text.isNotEmpty ? 1 : 2,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                  ),
                                ),
                              ),
                            if (!isMessage)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: GestureDetector(
                                  onTap: collect,
                                  child: Image.asset(
                                    assetPath(iscollect
                                        ? 'images/my/xingbiao.png'
                                        : 'images/my/xingbiao_1.png'),
                                    color: myColors.isDark && !iscollect
                                        ? myColors.iconThemeColor
                                        : null,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (text.isNotEmpty)
                          //内容行
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: textSize,
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (data.time.isNotEmpty && !isMessage)
              Container(
                padding: EdgeInsets.only(left: horizontal),
                child: Row(
                  children: [
                    if (statusWidget != null) statusWidget!,
                    Expanded(
                      flex: 1,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: data.time,
                            ),
                            if (data.meta.isNotEmpty)
                              const TextSpan(text: ' | '),
                            TextSpan(text: data.meta),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        openSheetMenu(context, list: [
                          iscollect ? '取消置顶' : '置顶',
                          '备注',
                          if (isNote) '编辑',
                          '删除',
                        ], onTap: (i) {
                          if (i == 0) collect?.call();
                          if (i == 1) saveRemarks?.call();
                          if (i == 2) {
                            if (isNote) {
                              edit?.call();
                            } else {
                              delete?.call();
                            }
                          }
                          if (i == 3) delete?.call();
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 40,
                        // color: myColors.red,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.more_horiz,
                          color: myColors.textGrey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isMessage)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: myColors.grey,
                      width: .5,
                    ),
                  ),
                ),
                margin: EdgeInsets.only(
                  top: horizontal,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 5,
                ),
                child: Text(
                  '笔记',
                  style: TextStyle(
                    color: myColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NoteItemData {
  String title;
  String text;
  String meta;
  String image;
  String cover;
  String time;

  List? imageArr;
  String target;
  bool note;

  NoteItemData({
    this.title = '',
    this.text = '',
    this.meta = '',
    this.image = '',
    this.cover = '',
    this.time = '',
    this.imageArr,
    this.target = '',
    this.note = true,
  });
}
