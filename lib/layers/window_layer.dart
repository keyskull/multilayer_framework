import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/ui/views/pages/unknown.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multilayer_framework/widgets/windows/default_window_frame_widget.dart';
import 'package:multilayer_framework/widgets/windows/window_frame_widget.dart';
import 'package:universal_router/route.dart';
import 'package:uuid/uuid.dart';

import '../framework.dart';
import '../layer_management.dart';
import '../widgets/windows/single_window_widget.dart';

final WindowsContainer windowsContainer = WindowsContainer();

final unknown = SingleWindowInterface.buildWithSingleWindowInterface(
    const Uuid().v1(), const Unknown());

WindowFrameWidget Function(SingleWindowWidget child, String id)
    windowFrameWidgetBuilder = (SingleWindowWidget child, String id) =>
        DefaultWindowFrameWidget(child, id);

///
/// (Fixed) Problem: hasn't have the correct order when closing the windows;
///
class WindowsContainer {
  List<WindowFrameWidgetState> windowStates = [];
  WindowLayerState? currentState;
}

/// [WindowLayer] is the top layer which is use for managing the widget which
///
///
/// When the windows queue update the state also need to update.
class WindowLayer extends StatefulWidget with MultiLayer {
  WindowLayer({Key? key}) : super(key: key);
  final String name = 'WindowLayer';

  @override
  WindowLayerState createState() => WindowLayerState();

  @override
  destroyContainer(identity) {
    windowsContainer.currentState?.closeWindow(identity);
  }

  @override
  createContainer(identity) {
    String windowId = 'unknown';
    if (identity is String) {
      Widget widget = UniversalRouter.getRouteInstance(identity).widget;
      windowsContainer.currentState?.openWindow(windowBuilder: (id) {
        windowId = id;
        return widget is SingleWindowWidget
            ? widget
            : SingleWindowInterface.buildWithSingleWindowInterface(id, widget);
      });
    } else if (identity is Widget) {
      windowsContainer.currentState?.openWindow(windowBuilder: (id) {
        windowId = id;
        return identity is SingleWindowWidget
            ? identity
            : SingleWindowInterface.buildWithSingleWindowInterface(
                id, identity);
      });
    }
    return windowId;
  }

  @override
  List<OverlayEntry> Function(BuildContext context, Widget? child)
      get overlayEntryBuilder => (context, child) =>
          [OverlayEntry(maintainState: true, builder: (context) => this)];
}

class PositionedWindow extends StatelessWidget {
  final Widget child;
  final double? left;
  final double? top;
  final String windowId;

  const PositionedWindow(
      {Key? key,
      this.left,
      this.top,
      required this.child,
      required this.windowId})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Positioned(left: left, top: top, child: child);
}

class WindowLayerState extends State<WindowLayer> {
  final windowLayerLogger = Logger(printer: CustomLogPrinter('WindowLayer'));
  List<PositionedWindow> instances = [];

  bool isActive(String id) =>
      instances.isEmpty ? false : instances.last.windowId == id;

  openWindow({required SingleWindowWidget Function(String id) windowBuilder}) {
    final id = new Uuid().v1();
    windowLayerLogger.d('Opened window: ' + id);
    setState(() {
      final windowFrameWidget = windowFrameWidgetBuilder(windowBuilder(id), id);
      this.instances.add(PositionedWindow(
          windowId: windowFrameWidget.id,
          left: windowFrameWidget.position.dx,
          top: windowFrameWidget.position.dy,
          child: windowFrameWidget));
      updateInstances();
    });
  }

  activatingWindow(String id) {
    windowLayerLogger.d('Activating window: $id');

    setState(() {
      final index =
          instances.indexWhere((e) => (e.child as WindowFrameWidget).id == id);
      final windowWidget = instances[index];
      instances.removeAt(index);
      instances.add(PositionedWindow(
          left: windowWidget.left,
          top: windowWidget.top,
          child: windowWidget.child,
          windowId: windowWidget.windowId));
      updateInstances();

      windowLayerLogger.v(
          'updateInstances: instances WindowFrameWidget List of windows: [' +
              instances
                  .map((e) => (e.child as WindowFrameWidget).id)
                  .join(',') +
              ']');
      windowLayerLogger.v('updateInstances: instances List of windows: [' +
          instances.map((e) => e.windowId).join(',') +
          ']');
      windowLayerLogger.v('updateInstances: states Updated list of windows: [' +
          windowsContainer.windowStates.map((e) => e.id).join(',') +
          ']');
    });
  }

  closeWindow(String id) {
    setState(() {
      windowLayerLogger.d('Removing window: ' + id.toString());
      instances.removeWhere((e) => (e.child as WindowFrameWidget).id == id);
      updateInstances();
    });
  }

  updatePosition(String id, Offset offset) {
    setState(() {
      windowLayerLogger.d('updatePosition: $id');

      final index = instances.indexWhere(
          (element) => (element.child as WindowFrameWidget).id == id);
      if (index > -1) {
        instances[index] = PositionedWindow(
            left: offset.dx,
            top: offset.dy,
            child: instances[index].child,
            windowId: instances[index].windowId);
      }
      updateInstances();
    });
  }

  updateInstances() {
    for (var index = 0; index < windowsContainer.windowStates.length; index++) {
      if (instances.length > index)
        windowsContainer.windowStates[index].refresh(instances[index].windowId);
    }
  }

  @override
  void initState() {
    windowsContainer.currentState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowLayerLogger.d('build executed.');
    // windowLayerLogger.i('list: [' +
    //     instances.map((e) => e.singleWindowWidget.id).join(',') +
    //     ']');
    return Stack(
      children: instances,
    );
  }
}
