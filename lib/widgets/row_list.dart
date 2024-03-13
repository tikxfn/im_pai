import 'package:flutter/material.dart';

//瀑布流组件
class RowList extends StatelessWidget {
  //每行个数
  final int rowNumber;

  //组件数组
  final List<Widget> children;

  //列间距
  final double spacing;

  //行间距
  final double lineSpacing;

  const RowList({
    super.key,
    required this.rowNumber,
    required this.children,
    this.spacing = 0.0,
    this.lineSpacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> list = [];
    children.fold<int>(0, (index, element) {
      if (index % rowNumber == 0) {
        int end = index + rowNumber < children.length
            ? index + rowNumber
            : children.length;
        list.add(children.sublist(index, end));
      }
      return index + 1;
    });
    for (List<Widget> element in list) {
      var padding = rowNumber - element.length;
      element.addAll(List.generate(padding, (_) => Container()));
    }
    List<List<Widget>> data = [];
    for (var rows in list) {
      List<Widget> t = [];
      for (var i = 0; i < rows.length; i++) {
        final w = rows[i];
        t.add(Expanded(child: w));
        if (spacing > 0 && i < rows.length - 1) {
          t.add(SizedBox(width: spacing));
        }
      }
      data.add(t);
    }

    return Column(
      children: data
          .map((e) => Container(
                margin: EdgeInsets.only(bottom: lineSpacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: e.map((e) => e).toList(),
                ),
              ))
          .toList(),
    );
  }
}
