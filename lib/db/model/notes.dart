import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/enum.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:openapi/api.dart';

part 'notes.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
@collection
class Notes {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  int upId = 0;
  String? mark;
  List<NoteItem> items = [];
  int createTime = 0;
  @Index()
  int updateTime = 0;
  @Index()
  int topTime = 0;
  @Index()
  int deleteTime = 0;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get contentWords {
    final Set<String> list = {};
    for (final item in items) {
      final w = item.contentWords;
      if (w.isNotEmpty) {
        list.add(w);
      }
    }
    return list.join(' ');
  }

  // 消息本地发送队列状态
  @JsonKey(includeFromJson: false, includeToJson: false)
  @Index()
  int get taskStatusInt => taskStatus.toInt();

  set taskStatusInt(int index) {
    taskStatus = TaskStatus.values[index];
  }

  // 发送失败原因
  String? reason;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @ignore
  TaskStatus taskStatus = TaskStatus.nil;

  // 标签
  @Index()
  List<String> tags = [];

  Notes();

  Notes.fromModel(GNotesModel data) {
    load(data);
  }

  GNotesModel toModel() {
    final model = GNotesModel();
    model.id = id.toString();
    model.mark = mark;
    model.topTime = topTime.toString();
    model.tags = tags;
    model.items = items.map((e) => e.toModel()).toList();
    return model;
  }

  load(GNotesModel data) {
    id = toInt(data.id);
    upId = toInt(data.upId);
    mark = data.mark;
    createTime = toInt(data.createTime);
    updateTime = toInt(data.updateTime);
    topTime = toInt(data.topTime);
    taskStatus = TaskStatus.success;
    tags = data.tags;
    items = data.items.map((e) => NoteItem.fromModel(e)).toList();
  }

  factory Notes.fromJson(Map<String, dynamic> json) => _$NotesFromJson(json);
  Map<String, dynamic> toJson() => _$NotesToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
@embedded
class NoteItem {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int get typeInt => GNoteType.values.indexOf(type ?? GNoteType.NIL);

  set typeInt(int index) {
    type = GNoteType.values[index];
  }

  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  @ignore
  GNoteType? type;

  String? title;
  String? subTitle;
  String? content;
  String? fontSize;
  bool? fontWeight;
  String? color;

  @ignore
  String get contentWords {
    final List<String> words = [];
    if ((content ?? '').isNotEmpty) {
      words.add(content!);
    }
    if ((title ?? '').isNotEmpty) {
      words.add(title!);
    }
    if ((subTitle ?? '').isNotEmpty) {
      words.add(subTitle!);
    }
    return words.join(' ');
  }

  static GNoteType? _typeFromJson(int? value) {
    if (value == null) return null;
    return GNoteType.values[value];
  }

  static int? _typeToJson(GNoteType? color) {
    return GNoteType.values.indexOf(color ?? GNoteType.NIL);
  }

  NoteItem();

  NoteItem.fromModel(GNotesItemModel data) {
    load(data);
  }

  GNotesItemModel toModel() {
    final model = GNotesItemModel();
    model.type = type;
    model.title = title;
    model.subTitle = subTitle;
    model.content = content;
    model.fontSize = fontSize;
    model.fontWeight = fontWeight;
    model.color = color;
    return model;
  }

  load(GNotesItemModel data) {
    type = data.type;
    title = data.title;
    subTitle = data.subTitle;
    content = data.content;
    fontSize = data.fontSize;
    fontWeight = data.fontWeight;
    color = data.color;
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) =>
      _$NoteItemFromJson(json);
  Map<String, dynamic> toJson() => _$NoteItemToJson(this);
}
