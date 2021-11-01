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

abstract class WindowFrameWidget extends StatefulWidget {
  final SingleWindowWidget singleWindowWidget;
  final String id;
  final Offset position;

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
  WindowFrameWidgetState createState() => WindowFrameWidgetState();
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
    // widget.widgetSetting.refresh = refresh;
    windowsContainer.windowStates.add(this);
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

  refresh(String id) {
    logger.i('refresh executed.');
    setState(() {
      // final instanceBuilders = windowsContainer
      //     .instanceBuilders[windowsContainer.windowStates.indexOf(this)];

      // if (instanceBuilders.id != this.id) {
      //   final windowStateIndex = windowsContainer.windowStates
      //       .indexWhere((element) => element.id == instanceBuilders.id);
      //   if (windowStateIndex != -1) {
      //     final getState = windowsContainer.windowStates[windowStateIndex];
      //     final newId = getState.id;
      //     final newBuildWidget = getState.buildWidget;
      //     final newSingleWindowWidget = getState.singleWindowWidget;
      //     final newPosition = getState.position;
      //
      //     windowsContainer.windowStates[windowStateIndex].buildWidget =
      //         this.buildWidget;
      //     getState.id = this.id;
      //     getState.singleWindowWidget = this.singleWindowWidget;
      //     getState.position = this.position;
      //
      //     this.buildWidget = newBuildWidget;
      //     this.id = newId;
      //     this.singleWindowWidget = newSingleWindowWidget;
      //     this.position = newPosition;
      //   }
      // }
      this.id = id;
      isActive = windowsContainer.currentState?.isActive(id) ?? false;
    });
  }

  // deactivateWindow() {
  //   setState(() {
  //     // inactiveWidgetBuilder = (Widget child) => RawMaterialButton(
  //     //       onPressed: () {
  //     //         setState(() {
  //     //           activateWindow();
  //     //           windowsContainer.activatingWindow(id);
  //     //         });
  //     //       },
  //     //       child: child,
  //     //     );
  //     isActive = false;
  //   });
  // }
  //
  // activateWindow() {
  //   setState(() {
  //     // inactiveWidgetBuilder = defaultInactiveWidgetBuilder;
  //     isActive = true;
  //   });
  // }

  Widget feedbackWidget = SizedBox(
    width: 200,
    height: 200,
    child: Card(
      child: CircularProgressIndicator(strokeWidth: 10),
    ),
  );

  late final Widget closeButton = ElevatedButton(
      onPressed: () {
        logger.d('closing window: ${widget.id}');
        windowsContainer.currentState?.closeWindow(widget.id);
      },
      child: Icon(Icons.close));

  late final Widget minimizeButton =
      ElevatedButton(onPressed: () {}, child: Icon(Icons.minimize));

  late final Widget maximizeButton =
      ElevatedButton(onPressed: () {}, child: Icon(Icons.add));

  @override
  Widget build(BuildContext context) {
    if (!captured) {
      setState(() {
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
        captured = true;
      });
    }

    return Draggable(
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
            windowsContainer.currentState
                ?.updatePosition(widget.id, details.offset);
          });
        setState(() {
          opacityLevel = 1;
        });
      },
      // childWhenDragging: Opacity(opacity: 0, child: stack),
      child: Opacity(
          opacity: opacityLevel,
          child: PointerInterceptor(
              child: Container(
                  decoration: boxDecoration,
                  child: (RawMaterialButton(
                      mouseCursor: SystemMouseCursors.basic,
                      onPressed: () {
                        if (!isActive) {
                          setState(() {
                            this.isActive = true;
                            windowsContainer.currentState
                                ?.activatingWindow(this.id);
                          });
                        }
                      },
                      child: (Screenshot(
                          controller: screenshotController,
                          child: widget.frameDecorationBuilder(
                              context,
                              this.singleWindowWidget,
                              closeButton,
                              minimizeButton,
                              maximizeButton,
                              isActive)))))))),
      // rootOverlay: true,
    );
  }

  void afterFirstLayout(BuildContext context) {
    afterFirstLayoutFunction();
  }
}
