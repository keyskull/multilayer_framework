// class NotificationListener {
//   final bool Function(Notification notification) listenerBuilder;
//   final AnimationController controller;
//
//   NotificationListener(this.listenerBuilder, this.controller);
// }

import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:universal_router/route.dart';

import '../framework.dart';

AppBar Function(double, bool, BuildContext) _appBarBuilder =
    defaultAppBarBuilder;

setAppbarBuilder(
        AppBar Function(double, bool, BuildContext) newAppBarBuilder) =>
    _appBarBuilder = newAppBarBuilder;

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
  final logger = Logger(printer: CustomLogPrinter('DecorationLayer'));
  var _appBarHeight = appBarHeight;
  late bool isRoot;
  @override
  void initState() {
    // decorations = decorations + [LicenseInformationBottomBar()];

    WidgetsBinding.instance.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    isRoot = true;
    UniversalRouter.addRoutePathChangingListeners((routePath) {
      this.setState(() {
        this.isRoot = routePath.path.split('/').length < 3;
        logger.i('router listener run. ' +
            this.isRoot.toString() +
            routePath.path.split('/').length.toString());
        final controller = AnimationController(
            duration: const Duration(milliseconds: 200), vsync: this);
        final animation = Tween<double>(begin: _appBarHeight, end: appBarHeight)
            .animate(controller);

        animation.addListener(() {
          this.setState(() {
            _appBarHeight = animation.value;
          });
        });
        controller.forward();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: _appBarBuilder(_appBarHeight, this.isRoot, context),
      body: Stack(alignment: Alignment.topCenter, children: [
        _notificationListener(widget.child),
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
        if (distance > 0)
          this.setState(() {
            final counted = _appBarHeight - distance;
            _appBarHeight = counted >= 0 ? counted : 0;
          });
        else if (!scrollNotification.metrics.outOfRange &&
            scrollNotification.metrics.pixels !=
                scrollNotification.metrics.maxScrollExtent) {
          final AnimationController controller = AnimationController(
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
    logger.d('globalNotificationListeners:' +
        globalNotificationListeners.keys.join(','));
  }

  void afterFirstLayout(BuildContext context) {
    _registerScrollNotificationListener();
  }

  @override
  void didUpdateWidget(covariant DecorationLayer oldWidget) {
    globalNotificationListeners.remove(oldWidget.hashCode.toString());
    logger.d(
        'Decoration Layer deleted oldWidget:' + oldWidget.hashCode.toString());
    _registerScrollNotificationListener();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    globalNotificationListeners.remove(this.hashCode.toString());
    super.dispose();
  }
}
