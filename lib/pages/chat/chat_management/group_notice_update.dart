import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class GroupNoticeUpdate extends StatefulWidget {
  const GroupNoticeUpdate({super.key});

  static const String path = 'chat/chat_management/group_notice_update';

  @override
  State<StatefulWidget> createState() {
    return _GroupNoticeUpdateState();
  }
}

class _GroupNoticeUpdateState extends State<GroupNoticeUpdate> {
  final TextEditingController _controller = TextEditingController();
  String roomId = '';

  //保存公告
  save() async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          notice: V1UpdateRoomInfoArgsValue(value: _controller.text),
        ),
      );
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['notice'] != null) _controller.text = args['notice'];
    if (args['roomId'] != null) roomId = args['roomId'];
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('群公告'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: ThemeNotifier().themeBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      AppTextarea(
                        radius: 10,
                        controller: _controller,
                        autofocus: true,
                        minLines: 10,
                      ),
                    ],
                  ),
                ),
              ),
              BottomButton(
                title: '完成'.tr(),
                onTap: save,
              )
            ],
          ),
        ),
      ),
    );
  }
}
