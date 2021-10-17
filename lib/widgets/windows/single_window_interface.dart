part of '../../framework.dart';

enum ScreenMode { window, fullScreen, onlyFullScreen }

class WindowSetting {
  ScreenMode screenMode;
  final String id;
  void Function(VoidCallback fn) _setState = (VoidCallback fn) {};
  ScrollController? scrollController;

  WindowSetting({String? id, ScreenMode? screenMode, this.scrollController})
      : this.id = id ?? 'Unknown Instance',
        this.screenMode = screenMode ?? ScreenMode.onlyFullScreen;
}

final singleWindowInterfaceLogger =
    Logger(printer: CustomLogPrinter('SingleWindowInterface'));

abstract class SingleWindowWidget extends StatefulWidget {
  final WindowSetting windowSetting;

  SingleWindowWidget(
      {Key? key,
      ScreenMode? screenMode,
      String? id,
      ScrollController? controller})
      : windowSetting = WindowSetting(
            id: id, screenMode: screenMode, scrollController: controller),
        super(key: key);

  /// TODO: UniversalSingleChildScrollView have been crash in Flutter 2.5.0, need update
  Widget _scrollview(Widget child) => scrollable()
      ? SingleChildScrollView(
          child: child,
          controller: windowSetting.scrollController,
        )
      : child;

  Widget _framework(Widget child) {
    switch (windowSetting.screenMode) {
      case ScreenMode.onlyFullScreen:
        return _scrollview(child);
      case ScreenMode.window:
        return windowFrameBuilder(_scrollview(child));
      case ScreenMode.fullScreen:
        return windowFrameBuilder(_scrollview(child));
      default:
        return _scrollview(child);
    }
  }

  @protected
  String get id => windowSetting.id;

  @protected
  ScrollController? get scrollController => windowSetting.scrollController;

  @protected
  bool scrollable();

  @protected
  void initState() {}

  @protected
  void setState(VoidCallback fn) {
    windowSetting._setState(fn);
  }

  @protected
  void dispose() {
    windowSetting.scrollController?.dispose();
  }

  WindowFrame windowFrameBuilder(Widget child) => DefaultWindowFrame(child, id);

  void changeScreenMode(ScreenMode screenMode) =>
      windowSetting.screenMode = screenMode;

  @override
  State<StatefulWidget> createState() => SingleWindowWidgetState();

  Widget build(BuildContext context);
}

class SingleWindowWidgetState extends State<SingleWindowWidget> {
  @override
  void initState() {
    widget.initState();
    widget.windowSetting._setState = setState;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) =>
      widget._framework(widget.build(context));

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

class SingleWindowInterface extends SingleWindowWidget {
  final Widget child;
  final bool _scrollable;

  SingleWindowInterface(this.child,
      {Key? key, String? id, bool? scrollable, ScreenMode? screenMode})
      : _scrollable = scrollable ?? false,
        super(
            key: key,
            screenMode: screenMode ?? ScreenMode.onlyFullScreen,
            id: id);

  @override
  Widget build(BuildContext context) => child;

  static SingleWindowWidget buildWithSingleWindowInterface(
          String id, Widget child,
          {bool isScrollable = false,
          ScreenMode screenMode = ScreenMode.window}) =>
      SingleWindowInterface(
        child,
        id: id,
        scrollable: isScrollable,
        screenMode: screenMode,
      );

  @override
  bool scrollable() => _scrollable;
}
