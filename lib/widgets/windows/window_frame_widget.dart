import 'dart:typed_data';

import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:screenshot/screenshot.dart';

import '../../layers/window_layer.dart';
import 'single_window_interface.dart';

final logger = Logger(printer: CustomLogPrinter('WindowFrameWidget'));

final boxConstraints = BoxConstraints(
    minHeight: 200,
    minWidth: 200,
    maxWidth: ScreenSize.getScreenSize.width * 0.8,
    maxHeight: ScreenSize.getScreenSize.height * 0.8);
final boxDecoration =
    BoxDecoration(color: Colors.white, border: Border.all(width: 2));

class WindowFrameWidgetSetting {
  void Function(SingleWindowWidget singleWindowWidget)? refresh;
}

abstract class WindowFrameWidget extends StatefulWidget {
  final SingleWindowWidget singleWindowWidget;
  final String id;
  final Offset position;
  final WindowFrameWidgetSetting widgetSetting = WindowFrameWidgetSetting();

  WindowFrameWidget(this.singleWindowWidget, this.id, {Offset? position})
      : position = position ?? const Offset(100, 100);

  Widget frameDecorationBuilder(
      BuildContext context,
      SingleWindowWidget singleWindowWidget,
      Widget closeButton,
      Widget minimizeButton,
      Widget maximizeButton,
      bool activated);

  @override
  State<StatefulWidget> createState() => WindowFrameWidgetState();
}

class WindowFrameWidgetState extends State<WindowFrameWidget> {
  SingleWindowWidget singleWindowWidget = unknown;
  late String id;
  late Offset position;
  late Widget Function(Widget child) inactiveWidgetBuilder;

  WindowFrameWidgetState();

  final ScreenshotController screenshotController = ScreenshotController();
  final Widget Function(Widget child) defaultInactiveWidgetBuilder =
      (child) => child;

  Function() afterFirstLayoutFunction = () {};
  bool isActive = true;
  double opacityLevel = 1;
  bool captured = false;

  @override
  void initState() {
    this.singleWindowWidget = widget.singleWindowWidget;
    this.id = singleWindowWidget.id;
    this.position = widget.position;
    this.inactiveWidgetBuilder = defaultInactiveWidgetBuilder;
    widget.widgetSetting.refresh = refresh;
    windowsContainer.windowStates.add(this);
    windowsContainer.windowStates.forEach((element) {
      element.refresh(this.singleWindowWidget);
    });

    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    super.initState();
  }

  @override
  void dispose() {
    windowsContainer.windowStates.remove(this);
    super.dispose();
  }

  refresh(SingleWindowWidget singleWindowWidget) {
    logger.i('refresh executed.');
    setState(() {
      if (singleWindowWidget != this.singleWindowWidget) {
        this.singleWindowWidget = singleWindowWidget;

        final getIsActive =
            windowsContainer.isActive(this.singleWindowWidget.id);
        if (getIsActive != isActive) {
          isActive = getIsActive;
          isActive ? activateWindow() : deactivateWindow();
        }
        this.id = this.singleWindowWidget.id;
      }
    });
  }

  deactivateWindow() {
    setState(() {
      inactiveWidgetBuilder = (Widget child) => RawMaterialButton(
            onPressed: () {
              setState(() {
                activateWindow();
                windowsContainer.activatingWindow(id);
              });
            },
            child: child,
          );
      isActive = false;
    });
  }

  activateWindow() {
    setState(() {
      inactiveWidgetBuilder = defaultInactiveWidgetBuilder;
      isActive = true;
    });
  }

  Widget feedbackWidget = SizedBox(
    width: 200,
    height: 200,
    child: Card(
      child: CircularProgressIndicator(strokeWidth: 10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Widget closeButton = ElevatedButton(
        onPressed: () {
          windowLayerLogger.d('closing window: ${widget.id}');
          windowsContainer.closeWindow(widget.id);
        },
        child: Icon(Icons.close));

    final Widget minimizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.minimize));

    final Widget maximizeButton =
        ElevatedButton(onPressed: () {}, child: Icon(Icons.add));
    final Widget frameDecoration = Screenshot(
        controller: screenshotController,
        child: widget.frameDecorationBuilder(context, widget.singleWindowWidget,
            closeButton, minimizeButton, maximizeButton, isActive));

    builtChild(Widget contain) => PointerInterceptor(
        child: DefaultTextStyle(
            style: TextStyle(fontSize: 20, color: Colors.black),
            child: Container(decoration: boxDecoration, child: contain)));

    Widget stack = Opacity(
        opacity: opacityLevel,
        child: builtChild(inactiveWidgetBuilder(frameDecoration)));

    if (!captured) {
      screenshotController.capture(delay: Duration(seconds: 1)).then((value) {
        setState(() {
          feedbackWidget = Image.memory(value ?? Uint8List(0));
        });
      }).onError((error, stackTrace) {
        setState(() {
          feedbackWidget =
              Image.asset('images/4ddce98e9381ffa68cf9967919669e4.png');
        });
      });
      setState(() {
        captured = true;
      });
    }

    final dragWidget = Draggable(
      maxSimultaneousDrags: 1,
      feedback: feedbackWidget,
      onDragStarted: () {
        screenshotController.capture().then((value) {
          setState(() {
            if (value != null) feedbackWidget = Image.memory(value);
          });
        });
        setState(() {
          opacityLevel = 0.5;
        });
      },
      onDragEnd: (details) {
        if (position.dy != details.offset.dy ||
            position.dx != details.offset.dx)
          setState(() {
            position = details.offset;
            // windowsContainer.updatePosition(widget.id, details.offset);
          });
        setState(() {
          opacityLevel = 1;
        });
      },
      // childWhenDragging: Opacity(opacity: 0, child: stack),
      child: stack,
      // rootOverlay: true,
    );
    return Positioned(left: position.dx, top: position.dy, child: dragWidget);
  }

  void afterFirstLayout(BuildContext context) {
    afterFirstLayoutFunction();
  }
}
