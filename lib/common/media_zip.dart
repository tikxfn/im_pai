import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:unionchat/global.dart';
import 'package:video_compress/video_compress.dart';

class MediaZip {
  // 压缩视频
  static Future<String> video(String path) async {
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
    );
    // logger.d(b2size(toDouble(await mediaInfo?.file?.length())));
    return mediaInfo?.path ?? '';
  }

  // 获取视频封面
  static Future<String> videoCoverPc(String path) async {
    final plugin = FcNativeVideoThumbnail();
    try {
      var pattern = Platform.isWindows ? '\\' : '/';
      var fileName = path.split(pattern).last;
      var name = fileName.split('.').first;
      var ext = 'jpeg';
      var coverPath = '${Global.temporaryDirectory}/$name.$ext';
      await plugin.getVideoThumbnail(
        srcFile: path,
        destFile: coverPath,
        srcFileUri: Platform.isAndroid,
        width: 300,
        height: 300,
        keepAspectRatio: true,
        format: ext,
        quality: 90,
      );
      return coverPath;
    } catch (err) {
      logger.e(err);
      return '';
    }
  }

  // 获取视频封面
  static Future<String> videoCover(String path) async {
    try {
      File file = await VideoCompress.getFileThumbnail(
        path,
        quality: 70,
      );
      return file.path;
    } catch (e) {
      logger.e(e);
      return '';
    }
  }

  // 获取视频宽高
  static Future<Map<String, int>?> videoSize(String path) async {
    try {
      MediaInfo info = await VideoCompress.getMediaInfo(path);
      info.width;
      info.height;
      if (info.width == null || info.height == null) return null;
      return {
        'w': info.width!,
        'h': info.height!,
      };
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  // 压缩图片
  static Future<String> image(String path) async {
    var fileName = path.split('/').last;
    var ext = fileName.split('.').last.toLowerCase();
    var name = fileName.split('.').first;
    var format = CompressFormat.png;
    var formatName = ext;
    if (ext == 'jpg' || ext == 'jpeg') {
      format = CompressFormat.jpeg;
    } else if (ext == 'png') {
      format = CompressFormat.png;
    } else if (ext == 'bmp') {
      formatName = 'png';
      format = CompressFormat.png;
    } else if (ext == 'webp') {
      format = CompressFormat.webp;
    } else {
      return path;
    }
    var targetPath = '${Global.temporaryDirectory}$name.$formatName';
    XFile? file = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 50,
      format: format,
    );
    // logger.d(b2size(toDouble(await file?.length())));
    return file?.path ?? '';
  }
}
