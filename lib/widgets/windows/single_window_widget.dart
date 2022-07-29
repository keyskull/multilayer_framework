import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WindowSetting {
  final String id;
  void Function(VoidCallback fn) _setState = (VoidCallback fn) {};
  ScrollController? scrollController;
  bool initialized = false;
  bool refreshable =false;
  WindowSetting({String? id, this.scrollController})
      : this.id = id ?? 'Unknown Instance';
}

// final _singleWindowWidgetLogger =
//     Logger(printer: CustomLogPrinter('SingleWindowInterface'));

// ignore: must_be_immutable
abstract class SingleWindowWidget extends StatefulWidget {
  static BuildContext? currentWindowContext;
  late final Logger windowLogger;
  final WindowSetting windowSetting;
  final bool? scrollable;

  SingleWindowWidget(
      {Key? key, String? id, ScrollController? controller, this.scrollable, bool? refreshable})
      : windowSetting = WindowSetting(id: id, scrollController: controller),
        super(key: key) {
    windowSetting.refreshable = refreshable ?? false;
    windowLogger =
        Logger(printer: CustomLogPrinter(this.runtimeType.toString()));
  }

  String get windowId => windowSetting.id;

  @protected
  ScrollController? get scrollController => windowSetting.scrollController;

  @protected
  void initState() {}

  @protected
  void setState(VoidCallback fn) {
    windowSetting._setState(fn);
  }

  @protected
  void dispose() {}

  @protected
  void deactivate() {}

  @protected
  void reassemble() {}

  @override
  State<StatefulWidget> createState() => SingleWindowWidgetState();

  Widget build(BuildContext context);
}

class SingleWindowWidgetState extends State<SingleWindowWidget> {
  @override
  void initState() {
    widget.windowLogger.i('initState: ' + widget.runtimeType.toString());
    if (!widget.windowSetting.initialized || widget.windowSetting.refreshable) {
      widget.initState();
      widget.windowSetting.initialized = true;
    }
    widget.windowSetting.scrollController = ScrollController();
    widget.windowSetting._setState = setState;
    SingleWindowWidget.currentWindowContext = this.context;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    widget.windowLogger.i('dispose');
    widget.dispose();
    widget.windowSetting.scrollController?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    widget.windowLogger.i('deactivate');
    widget.deactivate();
    super.deactivate();
  }

  @override
  void reassemble() {
    widget.windowLogger.i('reassemble');
    widget.reassemble();
    super.reassemble();
  }
}

class SingleWindowInterface extends SingleWindowWidget {
  final Widget child;

  SingleWindowInterface(this.child, {Key? key, String? id, bool? scrollable})
      : super(key: key, id: id, scrollable: scrollable);

  @override
  Widget build(BuildContext context) => child;

  static SingleWindowWidget buildWithSingleWindowInterface(
          String id, Widget child,
          {bool isScrollable = false}) =>
      SingleWindowInterface(
        child,
        id: id,
        scrollable: isScrollable,
      );
}
