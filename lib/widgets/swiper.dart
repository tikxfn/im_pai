import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:provider/provider.dart';

//轮播图
class AppSwiper extends StatefulWidget {
  final double height;
  final List<String> list;
  final Function(int)? onTap;
  final double appNetworkImageHeight;
  final double appNetworkImageWidth;

  const AppSwiper({
    required this.list,
    this.height = 200,
    this.onTap,
    super.key,
    this.appNetworkImageHeight = double.infinity,
    this.appNetworkImageWidth = double.infinity,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppSwiperState();
  }
}

class _AppSwiperState extends State<AppSwiper> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      color: myColors.white,
      child: Column(
        // alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              onPageChanged: (i, _) {
                setState(() => index = i);
              },
              viewportFraction: 0.4,
              height: widget.height,
            ),
            items: widget.list.map((e) {
              return GestureDetector(
                onTap: () {
                  if (widget.onTap != null) widget.onTap!(index);
                },
                child: AppNetworkImage(
                  e,
                  width: widget.appNetworkImageWidth,
                  height: widget.appNetworkImageHeight,
                  marginLeft: 6.5,
                  marginRight: 6.5,
                  borderRadius: BorderRadius.circular(15),
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
          // Positioned(
          //   child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.list.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index = i;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(7, 7, 0, 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == i ? myColors.primary : myColors.textGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
            ],
          ),
          // ),
        ],
      ),
    );
  }
}

//轮播图tab
class AppSwiperTab extends StatefulWidget {
  final List<Widget> list;
  const AppSwiperTab({
    required this.list,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppSwiperTabState();
  }
}

class _AppSwiperTabState extends State<AppSwiperTab> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      color: myColors.white,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: false,
              onPageChanged: (i, _) {
                setState(() => index = i);
              },
              viewportFraction: 1,
            ),
            items: widget.list.map((e) {
              return e;
            }).toList(),
          ),
        ],
      ),
    );
  }
}
