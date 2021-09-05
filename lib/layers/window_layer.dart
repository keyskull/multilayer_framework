part of "../framework.dart";

WindowContainer windowContainer = WindowContainer();

/// [WindowLayer] is the top layer which is use for managing the widget which
/// implemented [SingleWindowInterfaceMixin] mixin class.
class WindowLayer extends StatelessWidget {
  final Widget child;

  WindowLayer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [child, InstanceLayer()],
    );
  }
}

///
/// When the windows queue update the state also need to update.
class InstanceLayer extends StatefulWidget {
  InstanceLayer({Key? key}) : super(key: key);

  @override
  _InstanceLayerState createState() => _InstanceLayerState();
}

class _InstanceLayerState extends State<InstanceLayer> {
  final logger = Logger(printer: CustomLogPrinter('WindowLayer'));

  List<Widget> instances = [];
  Map<String, SingleWindowInterface> instanceCache = {};

  updateInstances() {
    setState(() {
      instances = windowContainer.instanceBuilders.map((e) {
        logger.d("generating instance: " + e.id.toString());
        logger.d("position: [" +
            e.position.dx.toString() +
            ',' +
            e.position.dy.toString() +
            "]");

        /// TODO: Issue impacting: the last excited instance doesn't update the state of active;
        return Positioned(
            left: e.position.dx,
            top: e.position.dy,
            child: instanceCache[e.id] ??
                () {
                  instanceCache[e.id] = e.windowBuilder(e.id);
                  return instanceCache[e.id]!;
                }());
      }).toList();
    });
  }

  @override
  void initState() {
    updateInstances();
    windowContainer.currentState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.i("list: [" + instances.map((e) => e.hashCode).join(',') + ']');
    return Stack(
      children: instances,
    );
  }
}

class InstanceBuilder {
  late String id;
  Offset position = new Offset(100, 100);
  final SingleWindowInterface Function(String id) windowBuilder;

  InstanceBuilder({required this.windowBuilder});
}

///
/// Problem: hasn't have the correct order when closing the windows;
///
class WindowContainer {
  List<InstanceBuilder> instanceBuilders = [];

  _InstanceLayerState? currentState;

  bool isActive(WindowFrame windowFrame) =>
      instanceBuilders.last.id == windowFrame.id;

  List<String> getWindowIdList() => instanceBuilders.map((e) => e.id).toList();

  closeWindow(String id) {
    log("Removing window: " + id.toString(), name: "window_layer");
    instanceBuilders.removeWhere((e) => e.id == id);
    currentState?.updateInstances();
  }

  openWindow(InstanceBuilder instanceBuilder) {
    final id = new Uuid().v1();
    instanceBuilder.id = id;
    log("Opened window: " + id, name: "window_layer");

    instanceBuilders.add(instanceBuilder);
    currentState?.updateInstances();
    log("List of windows: [" + getWindowIdList().join(',') + ']',
        name: "window_layer");
    log("Length of windows: [" + getWindowIdList().length.toString() + ']',
        name: "window_layer");
  }

  // TODO: _windowMode unfinished
  @protected
  activatingWindow(String id) {
    log('Activating window: $id', name: "window_layer");
    log("List of windows: [" + getWindowIdList().join(',') + ']',
        name: "window_layer");

    final index = instanceBuilders.indexWhere((e) => e.id == id);
    log("updated index: $index", name: "WindowLayerState");

    if (index != -1 &&
        index < instanceBuilders.length &&
        index != instanceBuilders.length - 1) {
      final _ib = instanceBuilders[index];
      instanceBuilders[index] = instanceBuilders.last;
      instanceBuilders[instanceBuilders.length - 1] = _ib;
      currentState?.updateInstances();
    }

    // if (_windowMode is WindowFrame) (_windowMode as WindowFrame);
  }

  updatePosition(String id, Offset offset) {
    log('updatePosition: $id', name: "window_layer");

    final builder = instanceBuilders.firstWhere((element) => element.id == id);
    builder.position = offset;
    currentState?.updateInstances();
  }
}
