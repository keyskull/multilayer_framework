import 'package:flutter/material.dart';
import 'package:localization/generated/l10n.dart';
import 'package:logger/logger.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:universal_router/route.dart';
import 'package:utilities/custom_log_printer.dart';
import 'package:utilities/screen_size.dart';

import '../framework.dart';

/// This is the stateful widget that the main application instantiates.
class CustomNavigationRail extends StatefulWidget {
  final Widget child;
  final NavigationRailButtons navigationRailButtons;
  final int defaultIndex;

  CustomNavigationRail(
      {required Key key,
      required this.child,
      required this.navigationRailButtons,
      this.defaultIndex = 0})
      : super(key: key);

  @override
  CustomNavigationRailState createState() => CustomNavigationRailState();
}

/// This is the private State class that goes with MyStatefulWidget.
class CustomNavigationRailState extends State<CustomNavigationRail>
    with SingleTickerProviderStateMixin {
  final logger = Logger(printer: CustomLogPrinter('CustomNavigationRail'));

  late AnimationController _controller;

  int _selectedIndex = 0;
  bool _extend = false;
  bool _hidden = false;
  double _width = 83;
  String path = "";

  // var _appBarHeight = AppBarHeight;
  // late bool Function(Notification) function;

  _updateState() {
    setState(() {
      _extend = !_extend;
    });
  }

  closeRail() {
    setState(() {
      _extend = false;
    });
  }

  bool extendNavigationRail() {
    setState(() {
      _hidden = !_hidden;
    });
    _hidden ? _controller.forward() : _controller.reverse();
    return _hidden;
  }

  @override
  void initState() {
    _selectedIndex = widget.defaultIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // globalNotificationListeners.remove(this.hashCode.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.initScreenSize(context);
    final navigationRailSize = Size(_width, ScreenSize.getScreenSize.height);
    final _curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );

    final __contentRelativeRectFromSize_1 = RelativeRect.fromSize(
        Rect.fromLTWH(_width, 0, ScreenSize.getScreenSize.width - _width,
            ScreenSize.getScreenSize.height),
        ScreenSize.getScreenSize);

    final __contentRelativeRectFromSize_2 = RelativeRect.fromSize(
        Rect.fromLTWH(0, 0, ScreenSize.getScreenSize.width,
            ScreenSize.getScreenSize.height),
        ScreenSize.getScreenSize);

    final __navigationRailRelativeRectFromSize_1 = RelativeRect.fromSize(
        Rect.fromLTWH(0, 0, _width, ScreenSize.getScreenSize.height),
        navigationRailSize);

    final __navigationRailRelativeRectFromSize_2 = RelativeRect.fromSize(
        Rect.fromLTWH(-_width, 0, _width, ScreenSize.getScreenSize.height),
        navigationRailSize);

    final _animationContent = ScreenSize.isDesktop(context)
        ? RelativeRectTween(
                begin: __contentRelativeRectFromSize_1,
                end: __contentRelativeRectFromSize_2)
            .animate(_curveAnimation)
        : RelativeRectTween(
            begin: __contentRelativeRectFromSize_2,
            end: __contentRelativeRectFromSize_1,
          ).animate(_curveAnimation);

    final _animationNavigationRail = ScreenSize.isDesktop(context)
        ? RelativeRectTween(
            begin: __navigationRailRelativeRectFromSize_1,
            end: __navigationRailRelativeRectFromSize_2,
          ).animate(_curveAnimation)
        : RelativeRectTween(
                begin: __navigationRailRelativeRectFromSize_2,
                end: __navigationRailRelativeRectFromSize_1)
            .animate(_curveAnimation);

    return AnimatedContainer(
        duration: Duration(seconds: 1),
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            PositionedTransition(rect: _animationContent, child: widget.child),
            PositionedTransition(
                rect: _animationNavigationRail,
                child: Row(
                  children: [
                    Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: PointerInterceptor(
                          child: NavigationRailTheme(
                            data: NavigationRailThemeData(
                                unselectedLabelTextStyle:
                                    TextStyle(color: Colors.white)),
                            child: NavigationRail(
                                unselectedIconTheme:
                                    IconThemeData(color: Colors.white),
                                selectedIconTheme:
                                    IconThemeData(color: Colors.white),
                                backgroundColor: Colors.black54,
                                extended: _extend,
                                selectedIndex: _selectedIndex,
                                onDestinationSelected: (int index) {
                                  logger.d('onDestinationSelected');
                                  setState(() {
                                    final key = (((globalNavigatorKey
                                                .currentState!
                                                .widget
                                                .pages
                                                .first
                                                .key as ValueKey)
                                            .value) as RouteData)
                                        .path
                                        .substring(1);
                                    if (key !=
                                        widget.navigationRailButtons
                                            .buttonPaths[index]) {
                                      globalNavigatorKey.currentState!
                                          .pushNamed(widget
                                              .navigationRailButtons
                                              .buttonPaths[index]);
                                    }
                                    _selectedIndex = index;
                                  });
                                },
                                labelType: NavigationRailLabelType.none,
                                leading: Stack(
                                  children: [
                                    Container(
                                        width: _width,
                                        height: 30,
                                        alignment: Alignment(0, 0.2),
                                        child: SizedBox.expand(
                                            child: Semantics(
                                                button: true,
                                                label: S
                                                    .of(context)
                                                    .home_page_name,
                                                child: IconButton(
                                                  iconSize: 25,
                                                  icon: Icon(
                                                    Icons.dehaze,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: _updateState,
                                                )))),
                                  ],
                                ),
                                destinations: new List.generate(
                                    widget.navigationRailButtons.buttonNames
                                        .length,
                                    (index) => NavigationRailDestination(
                                          icon: widget.navigationRailButtons
                                              .buttonIcons[index],
                                          selectedIcon: widget
                                              .navigationRailButtons
                                              .buttonSelectedIcons[index],
                                          label: Text(widget
                                              .navigationRailButtons
                                              .buttonNames[index]),
                                        ))),
                          ),
                        )),
                    VerticalDivider(thickness: 1, width: 1),
                    // This is the main content.
                  ],
                ))
          ],
        ));
  }

// @override
// void afterFirstLayout(BuildContext context) {
//   globalNotificationListeners[this.hashCode.toString()] =
//       (scrollNotification) {
//     if (scrollNotification is ScrollUpdateNotification) {
//       final distance = (scrollNotification.scrollDelta ?? 0);
//       log('ScrollUpdateNotification: ' + distance.toString(),
//           name: 'ml.numflurry.custom_navigation_rail');
//       if (distance > 0)
//         this.setState(() {
//           final counted = _appBarHeight - distance;
//           _appBarHeight = counted >= 0 ? counted : 0;
//         });
//       else
//         this.setState(() {
//           _appBarHeight = AppBarHeight;
//         });
//     }
//     return true;
//   };
// }
}
