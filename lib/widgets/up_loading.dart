import 'package:flutter/cupertino.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

//上拉加载loading
class UpLoading extends StatelessWidget {
  final LoadStatus loadStatus;
  final double marginBottom;
  final double marginTop;

  const UpLoading(
    this.loadStatus, {
    this.marginBottom = 30,
    this.marginTop = 30,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom, top: marginTop),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loadStatus == LoadStatus.loading)
            const Padding(
              padding: EdgeInsets.only(right: 5),
              child: CupertinoActivityIndicator(radius: 7),
            ),
          if (loadStatus == LoadStatus.no)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Image.asset(
                assetPath('images/more_logo.png'),
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          Text(
            loadStatus.toChar,
            style: TextStyle(
              color: myColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
