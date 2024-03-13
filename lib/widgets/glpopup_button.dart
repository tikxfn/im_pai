import 'package:flutter/material.dart';

class GlPopupButton extends StatelessWidget {
  final Function(int index) reload;

  const GlPopupButton({required this.reload(index), super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (index) {
        if (index == 0) {
          //保存图片
          reload(0);
        }
        if (index == 1) {
          //分享
          reload(1);
        }
        if (index == 2) {
          //编辑
          reload(2);
        }
      },
      itemBuilder: (context1) {
        return [
          const PopupMenuItem(
            value: 0,
            child: PopuButtonBox(
              title: '保存图片',
              icons: '',
            ),
          ),
          const PopupMenuItem(
            value: 1,
            child: PopuButtonBox(
              title: '分享',
              icons: '',
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: PopuButtonBox(
              title: '编辑',
              icons: '',
            ),
          ),
        ];
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: const Icon(Icons.more_horiz),
      ),
    );
  }
}

class PopuButtonBox extends StatelessWidget {
  final String? icons;
  final String title;
  const PopuButtonBox({
    super.key,
    this.icons,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          if (icons!.isNotEmpty)
            SizedBox(
              width: 22,
              height: 22,
              // alignment: Alignment.center,
              child: Image.asset(
                icons ?? '',
                fit: BoxFit.contain,
              ),
            ),
          if (icons!.isNotEmpty)
            const SizedBox(
              width: 12,
            ),
          Text(title),
        ],
      ),
    );
  }
}
