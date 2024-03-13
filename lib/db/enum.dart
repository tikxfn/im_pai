// 消息本地发送队列状态
class TaskStatus {
  const TaskStatus._(this.value);

  final String value;

  @override
  String toString() => value;
  // 空
  static const nil = TaskStatus._(r'NIL');
  // 发送中
  static const sending = TaskStatus._(r'SENDING');
  // 发送成功
  static const success = TaskStatus._(r'SUCCESS');
  // 发送失败
  static const fail = TaskStatus._(r'FAIL');

  static const values = <TaskStatus>[
    nil,
    sending,
    success,
    fail,
  ];

  int toInt() => values.indexOf(this);
}
