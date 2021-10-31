import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multilayer_framework/widgets/windows/default_window_frame_widget.dart';
import 'package:multilayer_framework/widgets/windows/window_frame_widget.dart';
import 'package:universal_router/route.dart';
import 'package:universal_router/ui/views/screen/unknown.dart';
import 'package:uuid/uuid.dart';

import '../framework.dart';
import '../layer_management.dart';
import '../widgets/windows/single_window_interface.dart';

final WindowsContainer windowsContainer = WindowsContainer();
final windowLayerLogger = Logger(printer: CustomLogPrinter('WindowLayer'));

final unknown = SingleWindowInterface.buildWithSingleWindowInterface(
    const Uuid().v1(), const Unknown());

WindowFrameWidget Function(SingleWindowWidget child, String id)
    windowFrameWidgetBuilder = (SingleWindowWidget child, String id) =>
        DefaultWindowFrameWidget(child, id);

/// [WindowLayer] is the top layer which is use for managing the widget which
/// implemented [SingleWindowInterfaceMixin] mixin class.

///
/// When the windows queue update the state also need to update.
class WindowLayer extends StatefulWidget with MultiLayer {
  WindowLayer({Key? key}) : super(key: key);
  final String name = 'WindowLayer';

  @override
  _WindowLayerState createState() => _WindowLayerState();

  @override
  destroyContainer(identity) {
    windowsContainer.closeWindow(identity);
  }

  @override
  createContainer(identity) {
    Widget widget = UniversalRouter.getRouteInstance(identity).widget;
    String windowId = 'unknown';
    windowsContainer.openWindow(InstanceBuilder(windowBuilder: (id) {
      windowId = id;
      return widget is SingleWindowWidget
          ? widget
          : SingleWindowInterface.buildWithSingleWindowInterface(id, widget);
    }));

    return windowId;
  }

  @override
  List<OverlayEntry> Function(BuildContext context, Widget? child)
      get overlayEntryBuilder => (context, child) =>
          [OverlayEntry(maintainState: true, builder: (context) => this)];
}

class _WindowLayerState extends State<WindowLayer> {
  List<WindowFrameWidget> instances = [];
  Map<String, SingleWindowWidget> instanceCache = {};

  updateInstances() {
    windowLayerLogger.d('updateInstances executed.');
    windowLayerLogger.v('updateInstances: instances List of windows: [' +
        instances.map((e) => e.id).join(',') +
        ']');
    windowLayerLogger.v('updateInstances: instanceBuilders List of windows: [' +
        windowsContainer.instanceBuilders.map((e) => e.id).join(',') +
        ']');
    setState(() {
      instances.clear();
      for (var index = 0;
          index < windowsContainer.instanceBuilders.length;
          index++) {
        final e = windowsContainer.instanceBuilders[index];

        final singleWindowWidget = instanceCache[e.id] ??
            () {
              instanceCache[e.id] = e.windowBuilder(e.id);

              return instanceCache[e.id]!;
            }();

        windowLayerLogger.d('generating instance: ' + e.id.toString());
        // windowLayerLogger.d('position: [' +
        //     e.position.dx.toString() +
        //     ',' +
        //     e.position.dy.toString() +
        //     ']');

        instances.add(windowFrameWidgetBuilder(
            singleWindowWidget, singleWindowWidget.id));
        // instances.add(windowsContainer.windows.length < index + 1
        //     ? () {
        //         final window = windowFrameWidgetBuilder(
        //             singleWindowWidget, singleWindowWidget.id);
        //         windowsContainer.windows.add(window);
        //         return windowsContainer.windows[index] ??
        //             windowFrameWidgetBuilder(unknown, unknown.id);
        //       }()
        //     : () {
        //         windowsContainer.windowStates[index]
        //             ?.refresh(singleWindowWidget);
        //         return windowsContainer.windows[index] ??
        //             windowFrameWidgetBuilder(unknown, unknown.id);
        //       }());
      }

      windowLayerLogger.v(
          'updateInstances: instances Updated list of windows: [' +
              instances.map((e) => e.id).join(',') +
              ']');

      windowLayerLogger.v('updateInstances: states Updated list of windows: [' +
          windowsContainer.windowStates.map((e) => e.id).join(',') +
          ']');
    });
  }

  @override
  void initState() {
    updateInstances();
    windowsContainer.currentState = this;
    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    super.initState();
  }

  void afterFirstLayout(BuildContext context) {
    // instances.forEach((element) {
    //   element..widgetSetting.refresh?.call(element.singleWindowWidget);
    // });
  }

  @override
  Widget build(BuildContext context) {
    windowLayerLogger.d('build executed.');
    windowLayerLogger.i('list: [' +
        instances.map((e) => e.singleWindowWidget.id).join(',') +
        ']');
    return Stack(
      children: instances,
    );
  }
}

class InstanceBuilder {
  late String id;

  // Offset position = new Offset(100, 100);
  final SingleWindowWidget Function(String id) windowBuilder;

  InstanceBuilder({required this.windowBuilder});
}

///
/// (Fixed) Problem: hasn't have the correct order when closing the windows;
///
class WindowsContainer {
  List<InstanceBuilder> instanceBuilders = [];
  List<WindowFrameWidget> windows = [];
  List<WindowFrameWidgetState> windowStates = [];

  _WindowLayerState? currentState;

  bool isActive(String id) => instanceBuilders.last.id == id;

  List<String> getWindowIdList() => instanceBuilders.map((e) => e.id).toList();

  closeWindow(String id) {
    windowLayerLogger.d('Removing window: ' + id.toString());
    instanceBuilders.removeWhere((e) => e.id == id);
    currentState?.updateInstances();
  }

  openWindow(InstanceBuilder instanceBuilder) {
    final id = new Uuid().v1();
    instanceBuilder.id = id;
    windowLayerLogger.d('Opened window: ' + id);

    instanceBuilders.add(instanceBuilder);
    currentState?.updateInstances();
    windowLayerLogger
        .v('List of windows: [' + getWindowIdList().join(',') + ']');
    windowLayerLogger
        .v('Length of windows: [' + getWindowIdList().length.toString() + ']');
  }

  // TODO: _windowMode unfinished
  activatingWindow(String id) {
    windowLayerLogger.d('Activating window: $id');
    windowLayerLogger.v(
        'activatingWindow: instanceBuilders List of windows: [' +
            getWindowIdList().join(',') +
            ']');

    final index = instanceBuilders.indexWhere((e) => e.id == id);
    windowLayerLogger.d('updated index: $index');

    if (index > -1 && index < instanceBuilders.length - 1) {
      final _ib = instanceBuilders[index];
      instanceBuilders[index] = instanceBuilders.last;
      windowStates[index].refresh(
          instanceBuilders[index].windowBuilder(instanceBuilders[index].id));
      instanceBuilders.last = _ib;
      windowStates.last.refresh(
          instanceBuilders[index].windowBuilder((instanceBuilders[index].id)));
    }

    currentState?.updateInstances();
    windowLayerLogger.v(
        'activatingWindow: instanceBuilders Updated list of windows: [' +
            getWindowIdList().join(',') +
            ']');
  }

// updatePosition(String id, Offset offset) {
//   windowLayerLogger.d('updatePosition: $id');
//
//   final builder = instanceBuilders.firstWhere((element) => element.id == id);
//   builder.position = offset;
//   currentState?.updateInstances();
// }
}
