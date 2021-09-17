import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../framework.dart';

final logger = Logger(printer: CustomLogPrinter('WindowFrame'));

final boxConstraints = BoxConstraints(
    minHeight: 200,
    minWidth: 200,
    maxWidth: ScreenSize.getScreenSize.width * 0.8,
    maxHeight: ScreenSize.getScreenSize.height * 0.8);
final boxDecoration =
    BoxDecoration(color: Colors.white, border: Border.all(width: 2));

abstract class WindowFrame extends StatelessWidget {
  final Widget child;
  final String id;
  final Offset? position;

  WindowFrame(this.child, this.id, {this.position}) {
    if (position != null) windowsContainer.updatePosition(id, position!);
  }

  WindowWidget frameDecorationBuilder(
      BuildContext context,
      Widget child,
      String id,
      Widget closeButton,
      Widget minimizeButton,
      Widget maximizeButton,
      bool activated);

  @override
  Widget build(BuildContext context) {
    final Widget closeButton = ElevatedButton(
        onPressed: () {
          windowLayerLogger.d('closing window: $id}');
          windowsContainer.closeWindow(id);
        },
        child: Icon(Icons.close));

    final Widget minimizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.minimize));

    final Widget maximizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.add));
    final frameDecoration = frameDecorationBuilder(
        context,
        child,
        id,
        closeButton,
        minimizeButton,
        maximizeButton,
        windowsContainer.isActive(id));

    builtChild(Stack contain) => PointerInterceptor(
        child: DefaultTextStyle(
            style: TextStyle(fontSize: 20, color: Colors.black),
            child: Container(
                constraints: boxConstraints,
                decoration: boxDecoration,
                child: contain)));

    final List<Widget> contentWidget = [
      frameDecoration.windowBar,
      frameDecoration.content
    ];

    final inactiveWidget = Stack(
        children: contentWidget +
            [
              PointerInterceptor(
                child: Container(
                  constraints: boxConstraints,
                  color: Colors.transparent,
                  child: SizedBox.expand(child: MaterialButton(onPressed: () {
                    windowsContainer.activatingWindow(id);
                    // activated = true;
                  })),
                ),
              )
            ]);

    final dragWidget = Draggable(
      maxSimultaneousDrags: 1,
      feedback: builtChild(inactiveWidget),
      onDragEnd: (details) {
        windowsContainer.updatePosition(id, details.offset);
      },
      childWhenDragging: Container(),
      child: builtChild(windowsContainer.isActive(id)
          ? Stack(children: contentWidget)
          : inactiveWidget),
      // rootOverlay: true,
    );
    return dragWidget;
  }
}

class WindowWidget {
  late final Widget windowBar;
  late final Widget content;

  WindowWidget({
    required windowBar,
    required content,
  }) {
    this.windowBar = Container(
        constraints: BoxConstraints.expand(height: 30), child: windowBar);
    this.content = Padding(
        padding: EdgeInsets.only(top: 30),
        child: Container(constraints: boxConstraints, child: content));
  }
}
