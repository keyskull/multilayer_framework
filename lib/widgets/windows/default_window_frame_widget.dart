import 'package:flutter/material.dart';
import 'package:multilayer_framework/framework.dart';

import 'window_frame_widget.dart';

class DefaultWindowFrameWidget extends WindowFrameWidget {
  DefaultWindowFrameWidget(SingleWindowWidget child, String id)
      : super(child, id);

  @override
  Widget frameDecorationBuilder(context, singleWindowWidget, closeButton,
          minimizeButton, maximizeButton, activated) =>
      ColoredBox(
        color: activated
            ? Theme.of(context).primaryColor
            : Theme.of(context).secondaryHeaderColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                closeButton,
                maximizeButton,
                minimizeButton,
                Text(
                  singleWindowWidget.id,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Container(
                constraints: boxConstraints,
                color: Theme.of(context).cardColor,
                child: singleWindowWidget)
          ],
        ),
        // Container(
        //   color: Colors.transparent,
        //   child: SizedBox.expand(child: MaterialButton(onPressed: () {
        //     state.setState(() {
        //       state.activateWindow();
        //       windowsContainer.activatingWindow(singleWindowWidget.id);
        //     });
        //     // activated = true;
        //   })),
        // ),
      );
}
