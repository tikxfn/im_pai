import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

import 'triangle_painter.dart';

const double _kMenuScreenPadding = 8.0;

class WPopupMenu extends StatefulWidget {
  const WPopupMenu({
    super.key,
    required this.onValueChanged,
    required this.actions,
    required this.child,
    this.pressType = PressType.longPress,
    this.pageMaxChildCount = 5,
    this.backgroundColor = Colors.black,
    this.menuWidth = 120,
    this.menuHeight = 35,
  });

  final ValueChanged<int> onValueChanged;
  final List<String> actions;
  final Widget child;
  final PressType pressType; // 点击方式 长按 还是单击
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;

  @override
  State<StatefulWidget> createState() {
    return _WPopupMenuState();
  }
}

class _WPopupMenuState extends State<WPopupMenu> {
  double? width;
  double? height;
  late RenderBox button;
  late RenderBox overlay;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      width = context.size?.width ?? 0;
      height = context.size?.height ?? 0;
      button = context.findRenderObject() as RenderBox;
      overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onSecondaryTap: () {
        if (widget.pressType == PressType.longPress) onTap();
      },
      onLongPress: () {
        if (widget.pressType == PressType.longPress) onTap();
      },
    );
  }

  void onTap() {
    Widget menuWidget = _MenuPopWidget(
      context,
      height ?? 0,
      width ?? 0,
      widget.actions,
      widget.pageMaxChildCount,
      widget.backgroundColor,
      widget.menuWidth,
      widget.menuHeight,
      button,
      overlay,
      (index) {
        if (index != -1) widget.onValueChanged(index);
        removeOverlay();
      },
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    if (entry != null) {
      Overlay.of(context).insert(entry!);
    }
  }

  void removeOverlay() {
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double _height;
  final double _width;
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;

  const _MenuPopWidget(
    this.btnContext,
    this._height,
    this._width,
    this.actions,
    this._pageMaxChildCount,
    this.backgroundColor,
    this.menuWidth,
    this.menuHeight,
    this.button,
    this.overlay,
    this.onValueChanged,
  );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  late RelativeRect position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) {
      return Container();
    }
    var myColors = context.watch<ThemeNotifier>();
    // 这里计算出来 当前页的 child 一共有多少个
    int curPageChildCount =
        (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length
            ? widget.actions.length % widget._pageMaxChildCount
            : widget._pageMaxChildCount;

    double curArrowWidth = 0;
    int curArrowCount = 0; // 一共几个箭头

    if (widget.actions.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        curArrowWidth = _arrowWidth;
        curArrowCount = 1;
      } else {
        // 如果不是第一页 则需要也显示左箭头
        curArrowWidth = _arrowWidth * 2;
        curArrowCount = 2;
      }
    }

    double curPageWidth = widget.menuWidth +
        (curPageChildCount - 1 + curArrowCount) * _separatorWidth +
        curArrowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onValueChanged(-1);
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Builder(
          builder: (BuildContext context) {
            var isInverted = (position.top +
                    (MediaQuery.of(context).size.height -
                            position.top -
                            position.bottom) /
                        2.0 -
                    (widget.menuHeight + _triangleHeight)) <
                (widget.menuHeight + _triangleHeight) * 2;
            return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _PopupMenuRouteLayout(
                  position,
                  widget.menuHeight + _triangleHeight,
                  Directionality.of(widget.btnContext),
                  widget._width,
                  widget.menuWidth,
                  widget._height),
              child: SizedBox(
                height: widget.menuHeight + _triangleHeight,
                width: curPageWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isInverted
                          ? CustomPaint(
                              size: Size(curPageWidth, _triangleHeight),
                              painter: TrianglePainter(
                                color: widget.backgroundColor,
                                position: position,
                                isInverted: true,
                                size: widget.button.size,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              child: Container(
                                color: widget.backgroundColor,
                                height: widget.menuHeight,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0
                                    ? Container(
                                        height: widget.menuHeight,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            _curPage--;
                                          });
                                        },
                                        child: SizedBox(
                                          width: _arrowWidth,
                                          height: widget.menuHeight,
                                          child: Icon(
                                            Icons.arrow_left,
                                            color: myColors.white,
                                          ),
                                        ),
                                      ),
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0
                                    ? Container(
                                        height: widget.menuHeight,
                                      )
                                    : Container(
                                        width: 1,
                                        height: widget.menuHeight,
                                        color: Colors.grey,
                                      ),

                                // 中间是ListView
                                _buildList(curPageChildCount, curPageWidth,
                                    curArrowWidth, curArrowCount),

                                // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                                curArrowCount > 0
                                    ? Container(
                                        width: 1,
                                        color: Colors.grey,
                                        height: widget.menuHeight,
                                      )
                                    : Container(
                                        height: widget.menuHeight,
                                      ),
                                curArrowCount > 0
                                    ? InkWell(
                                        onTap: () {
                                          if ((_curPage + 1) *
                                                  widget._pageMaxChildCount <
                                              widget.actions.length) {
                                            setState(() {
                                              _curPage++;
                                            });
                                          }
                                        },
                                        child: SizedBox(
                                          width: _arrowWidth,
                                          height: widget.menuHeight,
                                          child: Icon(
                                            Icons.arrow_right,
                                            color: (_curPage + 1) *
                                                        widget
                                                            ._pageMaxChildCount >=
                                                    widget.actions.length
                                                ? myColors.lineGrey
                                                : myColors.white,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: widget.menuHeight,
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isInverted
                          ? Container()
                          : CustomPaint(
                              size: Size(curPageWidth, _triangleHeight),
                              painter: TrianglePainter(
                                color: widget.backgroundColor,
                                position: position,
                                size: widget.button.size,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    int curPageChildCount,
    double curPageWidth,
    double curArrowWidth,
    int curArrowCount,
  ) {
    var myColors = ThemeNotifier();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: curPageChildCount,
      itemBuilder: (BuildContext context, int index) {
        double width = (curPageWidth -
                curArrowWidth -
                (curPageChildCount - 1 + curArrowCount) * _separatorWidth) /
            curPageChildCount;
        return GestureDetector(
          onSecondaryTap: () {
            widget.onValueChanged(_curPage * widget._pageMaxChildCount + index);
          },
          onTap: () {
            widget.onValueChanged(_curPage * widget._pageMaxChildCount + index);
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: width,
            height: widget.menuHeight,
            child: Center(
              child: Text(
                widget.actions[_curPage * widget._pageMaxChildCount + index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: .5,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Container(
            width: .5,
            color: myColors.lineGrey,
          ),
        );
      },
    );
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double? selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest); //这里要减一个东西，不知道怎么调，本来是下面那样的
    // return BoxConstraints.loose(constraints.biggest -
    //Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0));
    //不过用下面这种方式处理会出界，应该是点击弹窗的下一页显示的边距
    //  return BoxConstraints.loose(Size(constraints.biggest.width-8,constraints.biggest.height-8)
    // );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top +
          (size.height - position.top - position.bottom) / 2.0 -
          selectedItemOffset!;
    }

    // Find the ideal horizontal position.
    double x;

    // 如果menu 的宽度 小于 child 的宽度，则直接把menu 放在 child 中间
    if (childSize.width < width) {
      x = position.left + (width - childSize.width) / 2;
    } else {
      // 如果靠右
      if (position.left > size.width - (position.left + width)) {
        if (size.width - (position.left + width) >
            childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left + width - childSize.width;
        }
      } else if (position.left < size.width - (position.left + width)) {
        if (position.left > childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left;
        }
      } else {
        x = position.right - width / 2 - childSize.width / 2;
      }
    }

    if (y < _kMenuScreenPadding) {
      y = _kMenuScreenPadding;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding) {
      y = size.height - childSize.height;
    } else if (y < childSize.height * 2) {
      y = position.top + height;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
