import 'package:flutter/material.dart';

import '../../framework.dart';
import 'window_frame.dart';

class DefaultWindowFrame extends WindowFrame {
  DefaultWindowFrame(Widget child, String id) : super(child, id);

  @override
  WindowWidget frameDecorationBuilder(
          context, child, id, closeButton, minimizeButton, maximizeButton) =>
      WindowWidget(
          windowBar: Container(
              color: windowContainer.isActive(this)
                  ? Colors.blue
                  : Colors.lightBlueAccent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  closeButton,
                  maximizeButton,
                  minimizeButton,
                  Text(
                    id,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )),
          content: child);
}
