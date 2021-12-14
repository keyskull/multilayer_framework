import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WindowSetting {
  final String id;
  void Function(VoidCallback fn) _setState = (VoidCallback fn) {};
  ScrollController? scrollController;

  WindowSetting({String? id, this.scrollController})
      : this.id = id ?? 'Unknown Instance';
}

final _singleWindowInterfaceLogger =
    Logger(printer: CustomLogPrinter('SingleWindowInterface'));


abstract class SingleWindowWidget extends StatefulWidget {
  static BuildContext? currentWindowContext;
  final WindowSetting windowSetting;
  final bool? scrollable;

  SingleWindowWidget(
      {Key? key, String? id, ScrollController? controller, this.scrollable})
      : windowSetting = WindowSetting(id: id, scrollController: controller),
        super(key: key);

  String get id => windowSetting.id;

  @protected
  ScrollController? get scrollController => windowSetting.scrollController;

  @protected
  void initState() {
    if (this.scrollController == null)
      windowSetting.scrollController = ScrollController();

  }

  @protected
  void setState(VoidCallback fn) {
    windowSetting._setState(fn);
  }

  @protected
  void dispose() {
    windowSetting.scrollController?.dispose();
  }

  @override
  State<StatefulWidget> createState() => SingleWindowWidgetState();

  Widget build(BuildContext context);
}

class SingleWindowWidgetState extends State<SingleWindowWidget> {
  @override
  void initState() {
    widget.initState();
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
    widget.dispose();
    super.dispose();
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
