import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/up_loading.dart';
import 'package:provider/provider.dart';

import '../notifier/theme_notifier.dart';

class CommunityBox extends StatefulWidget {
  final Widget header;
  final Widget body;
  final String? backgroundImg; //背景图
  final Function()? setTrendsBackground; //设置背景图
  final bool showImg; //显示背景图
  final bool isMe; //是否是我可以设置背景图
  final bool showInitLoadStatus;
  //初始化
  final Future<int> Function()? onInit;
  final int limit;
  //是否显示状态文字
  final bool showStateText;
  //下拉刷新
  final Future<int> Function()? onPullDown;
  //上拉加载
  final Future<int> Function()? onPullUp;
  //上拉刷新执行距离
  final double pullBottom;

  const CommunityBox({
    required this.header,
    required this.body,
    this.setTrendsBackground,
    this.backgroundImg,
    this.showImg = false,
    this.isMe = false,
    this.showInitLoadStatus = false,
    this.limit = 20,
    this.showStateText = true,
    this.onPullDown,
    this.onPullUp,
    this.pullBottom = 0,
    this.onInit,
    super.key,
  });

  @override
  State<CommunityBox> createState() => _CommunityBoxState();
}

class _CommunityBoxState extends State<CommunityBox>
    with TickerProviderStateMixin {
  double imgHeight = platformPhone ? 200 : 150;
  double extraPicHeight = 0;
  late AnimationController animationController;
  late Animation<double> anim;
  bool imageState = false;

  //初始加载下拉
  late AnimationController initAnimation;
  late Animation<double> initAnim;
  double initBoxHeight = 0;
  double loadHeigt = 80;
  LoadStatus _loadStatus = LoadStatus.nil; //数据加载状态
  final ScrollController _controller = ScrollController();
  bool showStatus = false; //显示状态

  //展开背景图
  runAnimate1() {
    //设置动画让extraPicHeight的值从当前的值渐渐回到 350
    setState(() {
      anim =
          Tween(begin: extraPicHeight, end: 350.0).animate(animationController)
            ..addListener(() {
              setState(() {
                extraPicHeight = anim.value;
                imageState = true;
              });
            });
    });
  }

  //关闭背景图
  runAnimate2() {
    //设置动画让extraPicHeight的值从当前的值渐渐回到 0
    setState(() {
      anim = Tween(begin: extraPicHeight, end: 0.0).animate(animationController)
        ..addListener(() {
          setState(() {
            extraPicHeight = anim.value;
            imageState = false;
          });
        });
    });
  }

  //初始化加载
  Future<void> _initLoad() async {
    if (widget.onInit == null) return;
    if (widget.showInitLoadStatus) initStart();

    setState(() {
      _loadStatus = LoadStatus.loading;
    });
    refreshStatus(await widget.onInit!());

    if (widget.showInitLoadStatus) initEnd();
  }

  //下拉刷新
  Future<void> _downLoad() async {
    if (widget.onPullDown == null) return;
    refreshStatus(await widget.onPullDown!());
  }

  //上拉加载
  Future<void> _upLoad() async {
    if (widget.onPullUp == null) return;
    setState(() {
      _loadStatus = LoadStatus.loading;
    });
    refreshStatus(await widget.onPullUp!());
  }

  //刷新是否有更多数据
  refreshStatus(int num) {
    if (!mounted) return;
    setState(() {
      _loadStatus = num >= widget.limit ? LoadStatus.more : LoadStatus.no;
    });
  }

  //加载开始
  initStart() {
    showStatus = true;
    if (mounted) {
      setState(() {
        initAnim =
            Tween(begin: initBoxHeight, end: loadHeigt).animate(initAnimation)
              ..addListener(() {
                setState(() {
                  initBoxHeight = initAnim.value;
                });
              });
      });
    }
    if (mounted) {
      initAnimation.forward(from: 0.0);
    }
  }

  //加载结束
  initEnd() {
    showStatus = false;
    if (mounted) {
      setState(() {
        initAnim = Tween(begin: initBoxHeight, end: 0.0).animate(initAnimation)
          ..addListener(() {
            setState(() {
              initBoxHeight = initAnim.value;
            });
          });
      });
    }
    if (mounted) {
      initAnimation.forward(from: 0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      double scroll = _controller.position.pixels;
      double maxScroll =
          _controller.position.maxScrollExtent - widget.pullBottom;
      //当滚动到最底部的时候，加载新的数据
      if (scroll >= maxScroll && _loadStatus == LoadStatus.more) _upLoad();
    });
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    anim = Tween(begin: 0.0, end: 0.0).animate(animationController);

    //创建初始加载动画
    initAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initLoad();
  }

  @override
  void dispose() {
    initAnimation.stop();
    initAnimation.dispose();
    super.dispose();
    animationController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    return RefreshIndicator(
      onRefresh: () async {
        await _downLoad();
      },
      child: Listener(
        onPointerUp: imageState
            ? (_) {
                //当手指抬起离开屏幕时
                runAnimate2(); //动画执行
                animationController.forward(from: 0.0); //重置动画
              }
            : null,
        child: Container(
          color: bgColor,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            children: [
              Stack(
                children: [
                  //背景图
                  Container(
                    height: imgHeight + extraPicHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: widget.showImg &&
                              widget.backgroundImg != null &&
                              widget.backgroundImg!.isNotEmpty
                          ? null
                          : DecorationImage(
                              image: AssetImage(assetPath(
                                  'images/friend_circle/weixingbg1.png')),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Stack(
                      children: [
                        widget.showImg &&
                                widget.backgroundImg != null &&
                                widget.backgroundImg!.isNotEmpty
                            ? AppNetworkImage(
                                widget.backgroundImg!,
                                width: double.infinity,
                                imageSpecification:
                                    widget.backgroundImg!.endsWith('.gif')
                                        ? ImageSpecification.nil
                                        : ImageSpecification.w700,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  //透明盒子
                  Column(
                    children: [
                      GestureDetector(
                        onTap: !imageState && widget.showImg
                            ? () {
                                runAnimate1(); //动画执行
                                animationController.forward(from: 0.0); //重置动画
                              }
                            : null,
                        child: Container(
                          height: imgHeight +
                              extraPicHeight -
                              (imageState ? 0 : 20),
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              //是否显示朋友圈背景图  widget.showImg
                              widget.showImg &&
                                      widget.backgroundImg != null &&
                                      widget.backgroundImg!.isNotEmpty
                                  ? AppNetworkImage(
                                      widget.backgroundImg!,
                                      width: double.infinity,
                                      imageSpecification:
                                          widget.backgroundImg!.endsWith('.gif')
                                              ? ImageSpecification.nil
                                              : ImageSpecification.w700,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
                              //动画执行时隐藏header组件
                              !imageState
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 46, 16, 5),
                                      child: widget.header,
                                    )
                                  : Container(),
                              //动画执行时显示更换背景图组件
                              widget.showImg && widget.isMe && imageState
                                  ? Positioned(
                                      right: 10,
                                      bottom: 10,
                                      child: GestureDetector(
                                        onTap: widget.setTrendsBackground,
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons
                                                    .photo_size_select_actual_outlined,
                                                size: 25,
                                                color: myColors.textGrey,
                                              ),
                                              Text(
                                                '换封面'.tr(),
                                                style: TextStyle(
                                                  color: myColors.textGrey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 0),
                        constraints: const BoxConstraints(
                          minHeight: 20,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          children: [
                            AnimatedCrossFade(
                              firstChild: Container(
                                height: initBoxHeight,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: UpLoading(_loadStatus),
                              ),
                              secondChild: Container(),
                              crossFadeState: showStatus
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 300),
                            ),
                            widget.body,
                            if (widget.showStateText) UpLoading(_loadStatus),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
