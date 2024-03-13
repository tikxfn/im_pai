import 'package:isar/isar.dart';
part 'mark_up.g.dart';

@collection
class MarkUp {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  String? key;
  int? upId;
}
