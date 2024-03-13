import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

class MoreMenuItem {
  final String title;
  final String icon;
  final int notRead;

  MoreMenuItem({
    required this.title,
    this.icon = '',
    this.notRead = 0,
  });
}

class MoreMenu extends StatelessWidget {
  final List<MoreMenuItem> list;
  final Function(int)? onTap;
  final IconData? icon;

  const MoreMenu({
    required this.list,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return PopupMenuButton<int>(
      onSelected: onTap,
      itemBuilder: (context) {
        return list.map((e) {
          return PopupMenuItem(
            value: list.indexOf(e),
            child: Row(
              children: [
                if (e.icon.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Image.asset(
                      e.icon,
                      fit: BoxFit.contain,
                      width: 22,
                      height: 22,
                    ),
                  ),
                badges.Badge(
                  showBadge: e.notRead > 0,
                  badgeContent: Text(
                    '',
                    style: TextStyle(
                      color: myColors.red,
                      fontSize: 12,
                    ),
                  ),
                  child: Text(e.title),
                ),
              ],
            ),
          );
        }).toList();
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(icon),
      ),
    );
  }
}
