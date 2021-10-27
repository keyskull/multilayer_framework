import 'package:flutter/material.dart';

import 'window_frame_widget.dart';

class DefaultWindowFrameWidget extends WindowFrameWidget {
  DefaultWindowFrameWidget(Widget child, String id) : super(child, id);

  @override
  WindowWidget frameDecorationBuilder(context, child, id, closeButton,
          minimizeButton, maximizeButton, activated) =>
      WindowWidget(context,
          windowBar: Container(
              color: activated
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).secondaryHeaderColor,
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
