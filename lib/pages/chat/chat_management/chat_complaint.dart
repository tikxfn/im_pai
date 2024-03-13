import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class ChatComplaint extends StatefulWidget {
  const ChatComplaint({super.key});

  static const String path = 'chat/chat_management/complaint';

  @override
  State<StatefulWidget> createState() {
    return _ChatComplaintState();
  }
}

class _ChatComplaintState extends State<ChatComplaint> {
  final TextEditingController _controller = TextEditingController();
  String roomId = '';
  //保存
  save() async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomComplaint(
        V1ComplaintRoomArgs(content: _controller.text, roomId: roomId),
      );
      logger.d(_controller.text);
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
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {'roomId': ''};
    roomId = args['roomId'];
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
        title: Text('投诉'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppTextarea(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 10,
                  minLines: 5,
                ),
              ),
              const SizedBox(
                height: 31,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CircleButton(
                  onTap: save,
                  title: '确认提交'.tr(),
                  height: 47,
                  radius: 10,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
