import 'package:flutter/cupertino.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';

class NotesNotifier extends ChangeNotifier {
  // 更新页面中的消息
  List<ValueNotifier<Notes>> get notes => _notes.values.toList();
  // 跟踪数据是否请求中
  ValueNotifier<bool> get loading => _loading;
  // 是否有更多数据
  ValueNotifier<bool> get more => _more;
  static const int _pageSize = 20;

  bool _disposed = false;

  // 向上还有数据
  final ValueNotifier<bool> _more = ValueNotifier<bool>(true);
  // 数据正在请求防止误点
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  // 数据
  Map<int, ValueNotifier<Notes>> _notes = {};

  NotesNotifier._();

  static NotesNotifier? _instances;

  factory NotesNotifier() => _instances ?? NotesNotifier._();

  initPage({
    String? keywords,
    List<String>? tags,
    Function? syncCompleted,
  }) async {
    _more.value = true;
    final result = await NotesUtils.listNotes(
      _pageSize,
      offset: 0,
      keywords: keywords,
      tags: tags,
    );
    if (result.isEmpty || result.length < _pageSize) {
      _more.value = false;
    }
    _notes = {};
    for (var element in result) {
      _notes[element.id] = ValueNotifier(element);
    }
    notifyListeners();
  }

  // 加载更多
  loadMore({
    String? keywords,
    List<String>? tags,
    Function? syncCompleted,
  }) async {
    if (_loading.value) return [];
    _loading.value = true;
    try {
      final result = await NotesUtils.listNotes(
        _pageSize,
        offset: _notes.length,
        keywords: keywords,
        tags: tags,
      );
      if (result.isEmpty || result.length < _pageSize) {
        _more.value = false;
      }
      for (var element in result) {
        _notes[element.id] = ValueNotifier(element);
      }
    } finally {
      notifyListeners();
      _loading.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_disposed) return;
    _disposed = true;
    _loading.dispose();
    _more.dispose();
    for (var element in _notes.values) {
      element.dispose();
    }
    _notes.clear();
    _instances = null;
  }
}
