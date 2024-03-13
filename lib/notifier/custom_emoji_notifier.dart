import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:openapi/api.dart';

import '../common/interceptor.dart';

class CustomEmojiNotifier with ChangeNotifier {
  static CustomEmojiNotifier? _instance;
  int limit = 100000;

  factory CustomEmojiNotifier() {
    return _instance ??= CustomEmojiNotifier._internal();
  }

  CustomEmojiNotifier._internal();

  List<GUserExpressionModel> _imageData = [];

  List<GUserExpressionModel> get imageData => _imageData;

  set list(List<GUserExpressionModel> newList) {
    _imageData = newList;
    notifyListeners();
  }

  Future<int> refresh({bool init = false}) async {
    final api = UserExpressionApi(apiClient());
    try {
      final res = await api.userExpressionList(V1ListUserExpressionArgs(
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : imageData.length.toString(),
        ),
      ));
      if (res == null) return 0;
      List<GUserExpressionModel> newData = res.list.toList();
      if (init) {
        _imageData = newData;
      } else {
        _imageData.addAll(newData);
      }
      logger.i(_imageData);
      notifyListeners();
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //移动图片顺序
  move(int newIndex, int oldIndex) {
    var item = imageData[oldIndex];
    imageData.removeAt(oldIndex);
    imageData.insert(newIndex, item);
    notifyListeners();
  }

  //通过ids删除
  removeById(List<String> ids) {
    List<GUserExpressionModel> deleteData = [];
    for (var v in _imageData) {
      if (ids.contains(v.id)) {
        deleteData.add(v);
      }
    }
    for (var j in deleteData) {
      _imageData.remove(j);
    }
    notifyListeners();
  }

  //图片保存为自定义表情
  saveCustom(String url, {bool load = false}) async {
    List<GUserExpressionModel> imageData = CustomEmojiNotifier().imageData;
    double sort = 0;
    if (imageData.isNotEmpty) {
      if (imageData[0].sort != null &&
          toDouble(imageData[0].sort!) < imageData.length + 1) {
        sort = imageData.length + 1;
      } else {
        sort = toInt(imageData[0].sort) + 1;
      }
    } else {
      sort = imageData.length + 1;
    }
    if (load) loading();
    final api = UserExpressionApi(apiClient());
    try {
      await api.userExpressionUpdate(V1UpdateUserExpressionArgs(
        link: V1UpdateUserExpressionArgsValue(value: url),
        sort: V1UpdateUserExpressionArgsSort(value: sort),
      ));
      tip('保存成功'.tr());
      refresh(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      if (load) loadClose();
    }
  }
}
