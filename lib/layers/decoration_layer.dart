part of '../framework.dart';

Map<String, bool Function(Notification notification)>
    globalNotificationListeners = {};

class DecorationLayer extends StatefulWidget {
  final Widget child;
  final List<Widget> decorations;

  DecorationLayer({Key? key, required this.child, this.decorations = const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DecorationLayerState();
}

class DecorationLayerState extends State<DecorationLayer>
    with TickerProviderStateMixin {
  final logger = Logger(printer: CustomLogPrinter('RouterDelegateInherit'));

  var _appBarHeight = appBarHeight;
  AppBar? appBar;

  @override
  void initState() {
    // decorations = decorations + [LicenseInformationBottomBar()];
    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    MultiLayeredApp.universalRouter.routerDelegate.addListener(() {
      setState(() {
        logger.i('router listener run.');
        this.appBar = _appBarBuilder(_appBarHeight, context);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.appBar = _appBarBuilder(_appBarHeight, context);
    return Scaffold(
      appBar: this.appBar,
      body: Stack(alignment: Alignment.topCenter, children: [
        _notificationListener((widget.child is SingleWindowInterfaceMixin)
            ? ((widget.child as SingleWindowInterfaceMixin)
                  ..setScreenMode(ScreenMode.onlyFullScreen))
                .buildSingleWindowInterface()
            : widget.child),
        ...widget.decorations
      ]),
    );
  }

  _notificationListener(child) => NotificationListener<Notification>(
      onNotification: (notification) {
        return !globalNotificationListeners.values
            .map((e) => e(notification))
            .contains(false);
      },
      child: child);

  _registerScrollNotificationListener() {
    globalNotificationListeners[this.hashCode.toString()] =
        (scrollNotification) {
      if (scrollNotification is ScrollUpdateNotification) {
        final distance = (scrollNotification.scrollDelta ?? 0);
        // log('ScrollUpdateNotification: ' + distance.toString(),
        //     name: 'ml.numflurry.appbar');
        if (distance > 0)
          this.setState(() {
            final counted = _appBarHeight - distance;
            _appBarHeight = counted >= 0 ? counted : 0;
          });
        else if (!scrollNotification.metrics.outOfRange &&
            scrollNotification.metrics.pixels !=
                scrollNotification.metrics.maxScrollExtent) {
          final controller = AnimationController(
              duration: const Duration(milliseconds: 200), vsync: this);
          final animation =
              Tween<double>(begin: _appBarHeight, end: appBarHeight)
                  .animate(controller);
          animation.addListener(() {
            this.setState(() {
              _appBarHeight = animation.value;
            });
          });
          controller.forward();
        }
      }
      return true;
    };
    log(
        'globalNotificationListeners:' +
            globalNotificationListeners.keys.join(','),
        name: 'globalNotificationListeners');
  }

  void afterFirstLayout(BuildContext context) {
    _registerScrollNotificationListener();
  }

  @override
  void didUpdateWidget(covariant DecorationLayer oldWidget) {
    globalNotificationListeners.remove(oldWidget.hashCode.toString());
    log('Decoration Layer deleted oldWidget:' + oldWidget.hashCode.toString());
    _registerScrollNotificationListener();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    globalNotificationListeners.remove(this.hashCode.toString());
    super.dispose();
  }
}
