part of '../../framework.dart';

enum ScreenMode { window, fullScreen, onlyFullScreen }

final singleWindowInterfaceLogger =
    Logger(printer: CustomLogPrinter('SingleWindowInterface'));

class SingleWindowInterface extends StatelessWidget {
  final Widget child;

  const SingleWindowInterface({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  static SingleWindowInterface buildWithSingleWindowInterface(
          String id, Widget child,
          {bool isScrollable = false,
          ScreenMode screenMode = ScreenMode.window}) =>
      new _InstanceSingleWindowInterface(id, child)
          .buildSingleWindowInterface();
}

class WindowPattern {
  ScreenMode screenMode;
  String id;
  WindowPattern(
      {this.id = 'Unknown Instance',
      this.screenMode = ScreenMode.onlyFullScreen});
}

mixin SingleWindowInterfaceMixin on Widget {
  final WindowPattern windowPattern = WindowPattern();

  /// TODO: UniversalSingleChildScrollView have been crash in Flutter 2.5.0, need update
  Widget _scrollview(Widget child) =>
      scrollable() ? SingleChildScrollView(child: child) : child;

  Widget _framework(Widget child) {
    switch (windowPattern.screenMode) {
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
  String getId() => windowPattern.id;

  bool scrollable();

  void initWindow() {}

  WindowFrame windowFrameBuilder(Widget child) =>
      DefaultWindowFrame(child, getId());

  void setScreenMode(ScreenMode screenMode) =>
      windowPattern.screenMode = screenMode;

  @protected
  SingleWindowInterface buildSingleWindowInterface() {
    initWindow();
    return SingleWindowInterface(child: _framework(this));
  }
}

class _InstanceSingleWindowInterface extends StatelessWidget
    with SingleWindowInterfaceMixin {
  final Widget child;
  final String id;
  final ScreenMode screenMode;
  final bool isScrollable;

  _InstanceSingleWindowInterface(this.id, this.child,
      {this.isScrollable = false, this.screenMode = ScreenMode.window}) {
    this.windowPattern.id = id;
  }

  @override
  Widget build(BuildContext context) => this.child;

  @override
  void initWindow() => this.setScreenMode(this.screenMode);

  @override
  bool scrollable() => this.isScrollable;
}
