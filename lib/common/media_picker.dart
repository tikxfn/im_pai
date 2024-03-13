import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaPicker {
  //pc选择图片
  static Future<String> _pcPickerImage() async {
    var path = '';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return '';
      return result.files[0].path ?? '';
    } catch (e) {
      logger.e(e);
    }
    return path;
  }

  // 选择图片
  static Future<List<File>> image(
    BuildContext context, {
    int maxLength = 9,
    bool edit = false,
  }) async {
    List<File> files = [];
    try {
      if (platformPhone) {
        if (Platform.isAndroid) {
          await androidStorage();
        }
        List<AssetEntity>? assetEntities;
        if (context.mounted) {
          assetEntities = await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              requestType: RequestType.image,
              maxAssets: maxLength,
              textDelegate: edit ? EditAssetPickerTextDelegate() : null,
            ),
          );
        }
        if (assetEntities == null || assetEntities.isEmpty) return [];
        for (var v in assetEntities) {
          var file = await v.originFile;
          if (file != null) files.add(file);
        }
      } else {
        var path = await _pcPickerImage();
        if (path.isNotEmpty) files.add(File(path));
      }
    } catch (e) {
      logger.e(e);
    }
    return files;
  }

  //pc选择视频
  static Future<String> _pcPickerVideo() async {
    var path = '';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return '';
      return result.files[0].path ?? '';
    } catch (e) {
      logger.e(e);
    }
    return path;
  }

  // 选择视频
  static Future<List<File>> video(
    BuildContext context, {
    int maxLength = 9,
  }) async {
    List<File> files = [];
    try {
      if (platformPhone) {
        List<AssetEntity>? assetEntities = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            requestType: RequestType.video,
            maxAssets: maxLength,
          ),
        );
        if (assetEntities == null || assetEntities.isEmpty) return [];
        for (var v in assetEntities) {
          var file = await v.file;
          if (file != null) files.add(file);
        }
      } else {
        var path = await _pcPickerVideo();
        if (path.isNotEmpty) files.add(File(path));
      }
    } catch (e) {
      logger.e(e);
    }
    return files;
  }
}

class EditAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '编辑';
}
