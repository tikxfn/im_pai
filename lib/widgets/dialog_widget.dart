import 'package:flutter/material.dart';

showDialogWidget({
  required BuildContext context,
  required Widget child,
}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
        child: SafeArea(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                ),
              ),
              child,
            ],
          ),
        ),
      );
    },
  );
}
