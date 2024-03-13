import 'package:flutter/material.dart';

class Notfound extends StatelessWidget {
  const Notfound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final path = ModalRoute.of(context)?.settings.name ?? '';
    return SafeArea(
        child: Center(
      child: Column(
        children: [
          const Text('Notfound page'),
          Text(path),
        ],
      ),
    ));
  }
}
