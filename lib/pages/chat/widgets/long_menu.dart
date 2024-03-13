import 'package:flutter/material.dart';

import '../../../notifier/theme_notifier.dart';

class LongMenu extends StatefulWidget {
  final Widget child;
  final List<LongMenuItem> menuItems;

  const LongMenu({
    required this.child,
    required this.menuItems,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LongMenuState();
}

class _LongMenuState extends State<LongMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: () {
        _showMenu(context, widget.menuItems);
      },
      onLongPress: () {
        _showMenu(context, widget.menuItems);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        // decoration: BoxDecoration(
        //   boxShadow:
        // ),
        // color: _isSelected ? Colors.blue : Colors.transparent,
        child: widget.child,
      ),
    );
  }

  void _showMenu(BuildContext context, List<LongMenuItem> menuItems) {
    var myColors = ThemeNotifier();
    setState(() {});
    final overlayContext = Overlay.of(context).context;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final RenderBox screenBox = overlayContext.findRenderObject() as RenderBox;
    final keyboardHeight = MediaQuery.of(overlayContext).viewInsets.bottom;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: screenBox);
    final screenHeight = screenBox.size.height - keyboardHeight;
    final screenWidth = screenBox.size.width;
    // 总长度
    final totalWidth = _menuConfig.itemWidth + _menuConfig.horizontal * 2;
    // 总高度
    final totalHeight = _menuConfig.itemHeight * menuItems.length +
        _menuConfig.vertical * 2 +
        _menuConfig.lineHeight * (menuItems.length - 1);

    OverlayEntry? overlayEntry;

    final List<Widget> items = [];

    for (int i = 0; i < menuItems.length; i++) {
      final e = menuItems[i];
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            e.onTap?.call();
            overlayEntry?.remove();
            if (mounted) setState(() {});
          },
          child: Container(
            width: _menuConfig.itemWidth,
            height: _menuConfig.itemHeight,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    e.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  e.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (i != menuItems.length - 1) {
        items.add(
          Container(
            width: _menuConfig.itemWidth,
            height: _menuConfig.lineHeight,
            color: myColors.textGrey1,
          ),
        );
      }
    }

    Widget overlayWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _menuConfig.horizontal,
        vertical: _menuConfig.vertical,
      ),
      decoration: BoxDecoration(
        color: myColors.black,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        children: [
          Column(
            children: items,
          )
        ],
      ),
    );
    final p = calculatePosition(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      itemWidth: size.width,
      itemHeight: size.height,
      itemX: position.dx,
      itemY: position.dy,
      totalWidth: totalWidth,
      totalHeight: totalHeight,
    );
    overlayWidget = Positioned(
      top: p.top,
      left: p.left,
      child: overlayWidget,
    );
    overlayEntry = OverlayEntry(
      builder: (_) => SizedBox(
        width: screenWidth,
        height: screenWidth,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  overlayEntry?.remove();
                  setState(() {});
                },
              ),
            ),
            overlayWidget,
          ],
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class SizeConfig {
  final double itemWidth;
  final double itemHeight;
  final double horizontal;
  final double vertical;
  final double lineHeight;
  final double arrowSize;

  SizeConfig({
    required this.itemWidth,
    required this.itemHeight,
    required this.horizontal,
    required this.vertical,
    required this.lineHeight,
    required this.arrowSize,
  });
}

final SizeConfig _menuConfig = SizeConfig(
  itemWidth: 100,
  itemHeight: 40,
  horizontal: 10,
  vertical: 5,
  lineHeight: 0.3,
  arrowSize: 10,
);

class MenuPosition {
  final double top;
  final double left;

  MenuPosition(this.top, this.left);
}

// 计算位置
MenuPosition calculatePosition({
  required double screenWidth,
  required double screenHeight,
  required double itemWidth,
  required double itemHeight,
  required double itemX,
  required double itemY,
  required double totalWidth,
  required double totalHeight,
}) {
  bool isTop = itemY + itemHeight > screenHeight / 1.8;
  bool isLeft = itemX < screenWidth / 2;
  bool isCenter = itemHeight > 200;
  double top = 0;
  if (isCenter) {
    top = itemY + itemHeight / 2 - totalHeight / 2;
  } else {
    top = isTop ? itemY - totalHeight - 5 : itemY + itemHeight + 5;
  }
  var left = isLeft ? itemX : itemX - totalWidth + itemWidth;
  int mark = 0;
  if (top < 60) {
    mark = -1;
    // 顶部超出屏幕
    top = 60;
  } else if (top + totalHeight > screenHeight - 40) {
    mark = 1;
    // 底部超出屏幕
    top = screenHeight - totalHeight - 40;
  }
  if (isCenter) {
    left = isLeft ? left + 15 : left - 15;
  }

  if (mark != 0) {
    if (mark == -1) {
      // 超过顶部
      if (top + totalHeight < itemY + 40) {
        top = itemY - totalHeight + 40;
      }
    } else if (mark == 1) {
      // 超过底部
      if (top > itemY + itemHeight - 40) {
        top = itemY + itemHeight - 40;
      }
    }
  }
  // 如果完全挡住item
  final isBlock = itemX >= left &&
      itemX + itemWidth <= left + totalWidth &&
      itemY >= top &&
      itemY + itemHeight <= top + totalHeight;
  if (isBlock) {
    if (isLeft) {
      left += 25;
    } else {
      left -= 25;
    }
  }
  return MenuPosition(
    top,
    left,
  );
}

class LongMenuItem {
  final IconData? icon;
  final String label;
  Function? onTap;

  LongMenuItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}
