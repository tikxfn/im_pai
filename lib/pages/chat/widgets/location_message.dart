import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class LocationMessage extends StatelessWidget {
  final String name;
  final String desc;

  const LocationMessage({
    required this.name,
    required this.desc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: myColors.im2CircleIcon,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.location_on,
              color: myColors.white,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: myColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
