import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:utilities/screen_size.dart';

import '../../framework.dart';

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

  WindowFrame(this.child, this.id, {this.position});

  WindowWidget frameDecorationBuilder(
      BuildContext context,
      Widget child,
      String id,
      Widget closeButton,
      Widget minimizeButton,
      Widget maximizeButton);

  @override
  Widget build(BuildContext context) {
    if (position != null) windowContainer.updatePosition(id, position!);
    final Widget closeButton = ElevatedButton(
        onPressed: () {
          log('closing window: $id}');
          windowContainer.closeWindow(id);
        },
        child: Icon(Icons.close));

    final Widget minimizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.minimize));

    final Widget maximizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.add));
    final frameDecoration = frameDecorationBuilder(
        context, child, id, closeButton, minimizeButton, maximizeButton);

    final builtTitle = Container(
        constraints: BoxConstraints.expand(height: 30),
        child: frameDecoration.windowBar);
    final builtContent = Padding(
        padding: EdgeInsets.only(top: 30),
        child: Container(
            constraints: boxConstraints, child: frameDecoration.content));

    builtChild(Stack contain) => PointerInterceptor(
        child: DefaultTextStyle(
            style: TextStyle(fontSize: 20, color: Colors.black),
            child: Container(
                constraints: boxConstraints,
                decoration: boxDecoration,
                child: contain)));

    final dragWidget = Draggable(
      maxSimultaneousDrags: 1,
      feedback: builtChild(
        Stack(children: [
          builtTitle,
          builtContent,
          PointerInterceptor(
              child: Container(
                  constraints: boxConstraints, color: Colors.transparent))
        ]),
      ),
      onDragEnd: (details) {
        windowContainer.updatePosition(id, details.offset);
        windowContainer.activatingWindow(id);
      },
      childWhenDragging: Container(),
      child: builtChild(windowContainer.isActive(this)
          ? Stack(
              children: [builtTitle, builtContent],
            )
          : Stack(
              children: [
                builtTitle,
                builtContent,
                PointerInterceptor(
                    child: Container(
                  constraints: boxConstraints,
                  color: Colors.transparent,
                  child: SizedBox.expand(
                    child: MaterialButton(
                      onPressed: () => windowContainer.activatingWindow(id),
                    ),
                  ),
                ))
              ],
            )),
      rootOverlay: true,
    );
    return dragWidget;
  }
}

class WindowWidget {
  final Widget windowBar;
  final Widget content;

  WindowWidget({
    required this.windowBar,
    required this.content,
  });
}
