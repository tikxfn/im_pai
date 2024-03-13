import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

//靓号筛选
class NumberConditionNotifier with ChangeNotifier {
  static NumberConditionNotifier? _instance;

  factory NumberConditionNotifier() {
    return _instance ??= NumberConditionNotifier._internal();
  }

  NumberConditionNotifier._internal();

  int _numberLength = -1; //靓号长度
  int get numberLength => _numberLength;

  set numberLength(int newData) {
    _numberLength = newData;
    notifyListeners();
  }

  int _endNumber = -1; //尾数
  int get endNumber => _endNumber;

  set endNumber(int newData) {
    _endNumber = newData;
    notifyListeners();
  }

  int _notContain = -1; //不包含
  int get notContain => _notContain;

  set notContain(int newData) {
    _notContain = newData;
    notifyListeners();
  }

  List<int> _amount = []; //售价
  List<int> get amount => _amount;

  set amount(List<int> newData) {
    _amount = newData;
    notifyListeners();
  }

  GUserNumberType _rule = GUserNumberType.NIL;

  GUserNumberType get rule => _rule;

  set rule(GUserNumberType newData) {
    _rule = newData;
    notifyListeners();
  }

  //清除
  clean() {
    endNumber = -1;
    numberLength = -1;
    notContain = -1;
    amount = [];
    rule = GUserNumberType.NIL;
    // leftRule = '';
    // middleRule = '';
    // rightRule = '';
  }
}
