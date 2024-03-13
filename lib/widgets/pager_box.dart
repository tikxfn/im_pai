import 'package:flutter/material.dart';
import 'package:unionchat/widgets/up_loading.dart';

import '../common/enum.dart';

class PagerBox<T> extends StatefulWidget {
  final List<Widget> children;
  final int limit;

  //是否显示状态文字
  final bool showStateText;

  //初始化
  final Future<int> Function()? onInit;

  final bool needInitBox;

  //下拉刷新
  final Future<int> Function()? onPullDown;

  //上拉加载
  final Future<int> Function()? onPullUp;

  //页面padding
  final EdgeInsetsGeometry? padding;

  //上拉刷新执行距离
  final double pullBottom;

  const PagerBox({
    required this.children,
    this.limit = 20,
    this.onInit,
    this.needInitBox = false,
    this.onPullDown,
    this.onPullUp,
    this.showStateText = true,
    this.padding,
    this.pullBottom = 0,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PagerBox<T>();
  }
}

class _PagerBox<T> extends State<PagerBox> with TickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  LoadStatus _loadStatus = LoadStatus.nil; //数据加载状态
  late AnimationController animationController;
  late Animation<double> anim;
  double extraPicHeight = 0;
  double loadHeig = 80;

  //初始化加载
  Future<void> _initLoad() async {
    if (widget.onInit == null) return;
    if (widget.needInitBox) {
      if (mounted) {
        setState(() {
          anim = Tween(begin: extraPicHeight, end: loadHeig)
              .animate(animationController)
            ..addListener(() {
              setState(() {
                extraPicHeight = anim.value;
              });
            });
        });
      }
      if (mounted) {
        animationController.forward(from: 0.0);
      }
    }

    setState(() {
      _loadStatus = LoadStatus.loading;
    });

    refreshStatus(await widget.onInit!());
    if (widget.needInitBox) {
      if (mounted) {
        setState(() {
          anim = Tween(begin: extraPicHeight, end: 0.0)
              .animate(animationController)
            ..addListener(() {
              setState(() {
                extraPicHeight = anim.value;
              });
            });
        });
      }
      if (mounted) {
        animationController.forward(from: 0.0);
      }
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initLoad();
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

    //创建动画
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // 停止监听动画
    animationController.stop();

    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _downLoad();
      },
      child: ListView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        children: [
          Container(
            height: extraPicHeight,
            width: double.infinity,
            alignment: Alignment.center,
            child: UpLoading(_loadStatus),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
          if (widget.showStateText) UpLoading(_loadStatus),
        ],
      ),
    );
  }
}
