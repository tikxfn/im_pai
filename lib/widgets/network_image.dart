import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/enc_network_image_io.dart';
import 'package:provider/provider.dart';

//图片规格
enum ImageSpecification {
  nil,
  w120,
  w230,
  w500,
  w700,
}

extension ImageSpecificationExt on ImageSpecification {
  String get toUrl {
    if (this == ImageSpecification.nil) {
      return '';
    }
    return '-$name';
  }
}

//网络图片组件
class AppNetworkImage extends StatefulWidget {
  //图片url
  // final String url;

  //图片规格
  final ImageSpecification imageSpecification;

  //图片宽度
  final double? width;

  //图片高度
  final double? height;

  //加载高度
  final double? loadHeight;

  //图片最大高度
  final double? maxHeight;

  //图片左边距
  final double marginLeft;

  //图片右边距
  final double marginRight;

  //图片上边距
  final double marginTop;

  //图片下边距
  final double marginBottom;

  //图片拉伸方式
  final BoxFit? fit;

  //圆角
  final BorderRadiusGeometry? borderRadius;

  final bool avatar;

  final Color? loadColor;
  final Color? backgroundColor;

  final ExtendedImageMode mode;

  final ImageProvider imageProvider;

  final bool assets;

  AppNetworkImage(
    String link, {
    this.width = 100,
    this.fit,
    this.height,
    this.loadHeight,
    this.maxHeight,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.borderRadius,
    this.avatar = false,
    this.imageSpecification = ImageSpecification.nil,
    this.loadColor,
    this.backgroundColor,
    super.key,
    this.mode = ExtendedImageMode.none,
    this.assets = false,
  }) : imageProvider =
            _getImageProvider(link, avatar, assets, imageSpecification);

  static ImageProvider _getImageProvider(
    String link,
    bool avatar,
    bool assets,
    ImageSpecification imageSpecification,
  ) {
    if (assets) {
      return AssetImage(link);
    }
    if (link.isEmpty) {
      return AssetImage(
        assetPath('images/${avatar ? 'avatar' : 'image_failed'}.png'),
      );
    }
    if (!urlValid(link)) {
      return FileImage(File(link));
    }
    var fileName = link.split('/').last;
    final fileNames = fileName.split('.');
    final ext = fileNames.last.toLowerCase();
    if (ext != 'bmp' &&
        ext != 'webp' &&
        ext != 'gif' &&
        ext != 'apng' &&
        ext != 'heic' &&
        imageSpecification != ImageSpecification.nil) {
      link = link.replaceAll(
        fileName,
        '${fileNames.first}${imageSpecification.toUrl}.$ext',
      );
      var origin = Uri.parse(link).origin;
      link = link.replaceAll(origin, '$origin/process');
    }
    return EncNetworkImage(link);
  }

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  double? _imageHeight;

  // 加载组件
  Widget _load() {
    var myColors = ThemeNotifier();
    var height = widget.width == double.infinity ? null : widget.width;
    if (widget.loadHeight != null) {
      height = widget.loadHeight;
    }
    return SizedBox(
      width: widget.width,
      height: height,
      child: Center(
        child: SpinKitCircle(
          color: myColors.primary,
          size: widget.avatar ? 20 : 40,
        ),
        // child: Image.asset(
        //   assetPath('images/loading.gif'),
        //   width: widget.avatar ? 20 : 40,
        // ),
      ),
    );
  }

  Widget _bodyWidget() {
    double height = toDouble(widget.height);
    double maxHeight = toDouble(widget.maxHeight);
    double imageHeight = toDouble(_imageHeight);
    if (maxHeight > 0) {
      if (height > maxHeight || height <= 0) {
        height = maxHeight;
      }
      if (imageHeight > 0 && imageHeight < height) height = imageHeight;
    }
    return ExtendedImage(
      image: widget.imageProvider,
      width: widget.width,
      height: height > 0 ? height : null,
      fit: widget.fit,
      mode: widget.mode,
      enableLoadState: true,
      onDoubleTap: (state) {
        // 处理双击
        var pointerDownPosition = state.pointerDownPosition;
        double begin = state.gestureDetails!.totalScale!;
        double end;
        logger.d(begin);
        // 判断是否要放大或缩小
        if (begin < 5.0) {
          end = 5.0;
        } else {
          end = 1.0;
        }
        // 使用动画进行缩放
        state.handleDoubleTap(
          scale: end,
          doubleTapPosition: pointerDownPosition,
        );
      },
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _load();
          case LoadState.failed:
            return Image.asset(
              assetPath(
                  'images/${widget.avatar ? 'avatar' : 'image_failed'}.png'),
              width: widget.width,
              height: height > 0 ? height : null,
              fit: widget.fit,
            );
          case LoadState.completed:
            break;
        }
        return null;
      },
    );
  }

  ImageStreamListener _imageStreamListener() {
    return ImageStreamListener(
      (image, synchronousCall) {
        double imageHeight = toDouble(_imageHeight);
        var img = image.image;
        // logger.d(img.height);
        double rate = 1;
        var w = toDouble(widget.width);
        var h = toDouble(widget.height);
        if (w > 0) {
          rate = w / img.width;
        } else if (h > 0) {
          rate = h / img.height;
        }
        var ih = img.height * rate;
        // logger.d('rate $rate, $ih');
        if (imageHeight <= 0 && ih > 0 && mounted) {
          setState(() {
            _imageHeight = ih;
            // logger.d('设置图片高度：$_imageHeight');
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(_imageStreamListener());
  }

  @override
  void dispose() {
    super.dispose();
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .removeListener(_imageStreamListener());
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    double? width = widget.width;
    double? height = widget.height;
    if (width != null && widget.width != null) {
      width = width > widget.width! ? widget.width : width;
    }
    if (height != null && widget.height != null) {
      height = height > widget.height! ? widget.height : height;
    }
    width = widget.width ?? width;
    height = widget.height ?? height;
    return Container(
      margin: EdgeInsets.only(
        top: widget.marginTop,
        bottom: widget.marginBottom,
        left: widget.marginLeft,
        right: widget.marginRight,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? myColors.readBg,
          ),
          child: _bodyWidget(),
        ),
      ),
    );
  }
}
