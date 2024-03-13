import 'package:flutter/material.dart';
import 'package:unionchat/pages/call/video_call.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static const String path = 'home';

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('im'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, VideoCall.path);
            },
            child: const Text('视频通话'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('语音通话'),
          ),
        ],
      ),
    );
  }
}
