import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
part 'channel_group.g.dart';

@collection
class ChannelGroup {
  Id id = Isar.autoIncrement;
  List<String>? groups;
}

class ChannelGroupOperator {
  static ValueNotifier<List<String>> get groups => _groups;
  static final ValueNotifier<List<String>> _groups =
      ValueNotifier<List<String>>([]);

  static Future<void> save(Isar isar, List<String> groups) async {
    final v = ChannelGroup();
    v.groups = groups;
    v.id = 1;
    _groups.value = groups;
    await isar.channelGroups.put(v);
  }

  static Future<List<String>> get(Isar isar) async {
    final v = await isar.channelGroups.where().idEqualTo(1).findFirst();
    if (v == null) return [];
    _groups.value = v.groups ?? [];
    return v.groups ?? [];
  }
}
