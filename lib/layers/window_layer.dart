part of '../framework.dart';

final WindowsContainer windowsContainer = WindowsContainer();
final windowLayerLogger = Logger(printer: CustomLogPrinter('WindowLayer'));

final unknown = SingleWindowInterface.buildWithSingleWindowInterface(
    new Uuid().v1(), Unknown());

/// [WindowLayer] is the top layer which is use for managing the widget which
/// implemented [SingleWindowInterfaceMixin] mixin class.

///
/// When the windows queue update the state also need to update.
class WindowLayer extends StatefulWidget {
  WindowLayer({Key? key}) : super(key: key);

  @override
  _WindowLayerState createState() => _WindowLayerState();
}

class _WindowLayerState extends State<WindowLayer> {
  List<Positioned> instances = [];
  Map<String, SingleWindowWidget> instanceCache = {};

  updateInstances() {
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
        windowLayerLogger.d('position: [' +
            e.position.dx.toString() +
            ',' +
            e.position.dy.toString() +
            ']');

        instances.add(Positioned(
            left: e.position.dx,
            top: e.position.dy,
            child: windowsContainer.windows.length < index + 1
                ? () {
                    final window =
                        Window(singleWindowWidget: singleWindowWidget);
                    windowsContainer.windows.add(window);
                    return windowsContainer.windows[index] ??
                        Window(singleWindowWidget: unknown);
                  }()
                : () {
                    windowsContainer.windowStates[index]
                        ?.refresh(singleWindowWidget);
                    return windowsContainer.windows[index] ??
                        Window(singleWindowWidget: unknown);
                  }()));
      }
    });
  }

  @override
  void initState() {
    updateInstances();
    windowsContainer.currentState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowLayerLogger.i('list: [' +
        instances
            .map((e) => (e.child as Window).singleWindowWidget.hashCode)
            .join(',') +
        ']');
    return Stack(
      children: instances,
    );
  }
}

class InstanceBuilder {
  late String id;
  Offset position = new Offset(100, 100);
  final SingleWindowWidget Function(String id) windowBuilder;

  InstanceBuilder({required this.windowBuilder});
}

///
/// Problem: hasn't have the correct order when closing the windows;
///
class WindowsContainer {
  List<InstanceBuilder> instanceBuilders = [];
  List<WindowState?> windowStates = [];
  List<Window?> windows = [];

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
    windowLayerLogger
        .v('List of windows: [' + getWindowIdList().join(',') + ']');

    final index = instanceBuilders.indexWhere((e) => e.id == id);
    windowLayerLogger.d('updated index: $index');

    if (index != -1 &&
        index < instanceBuilders.length &&
        index != instanceBuilders.length - 1) {
      final _ib = instanceBuilders[index];
      instanceBuilders[index] = instanceBuilders.last;
      instanceBuilders[instanceBuilders.length - 1] = _ib;
    }
    currentState?.updateInstances();
  }

  updatePosition(String id, Offset offset) {
    windowLayerLogger.d('updatePosition: $id');

    final builder = instanceBuilders.firstWhere((element) => element.id == id);
    builder.position = offset;
    currentState?.updateInstances();
  }
}
