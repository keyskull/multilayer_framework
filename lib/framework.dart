import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:localization/generated/l10n.dart';
import 'package:multilayer_framework/multi_layered_app.dart';
import 'package:universal_router/route.dart';

import 'layers/decoration_layer.dart';
import 'layers/navigation_layer.dart';
import 'layers/notification_layer.dart';

export 'layers/decoration_layer.dart';
export 'layers/navigation_layer.dart';
export 'layers/window_layer.dart';
export 'properties/default_navigation_rail_buttons.dart';
export 'widgets/windows/single_window_interface.dart';

void _func() {}

enum ScreenMode {
  window,
  fullScreenWindow,
  onlyFullScreen,
  fixedPositionWindow
}

EdgeInsets edgeInsetsAll = const EdgeInsets.all(20.0);
double articleItemHeight = 133;
CrossAxisAlignment articleItemAlignment = CrossAxisAlignment.start;
EdgeInsets descriptionEdgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0);
double appBarHeight = 50;
Color mainThemeColor = Colors.blue;

class ActionButtonWidget extends StatelessWidget {
  final Function() onPressed;
  final String text;

  ActionButtonWidget({required this.text, this.onPressed = _func});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              text,
              // overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.button,
            )),
      );
}

List<Widget> _actionButtonList = [];

final defaultAppBarBuilder =
    (double appBarHeight, bool isRoot, BuildContext context) => AppBar(
        toolbarHeight: appBarHeight,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Container(
            margin: const EdgeInsets.only(left: 20.0),
            child: isRoot
                ? const Image(image: AssetImage('images/logo.png'))
                : BackButton(
                    onPressed: () => UniversalRouter.pop(),
                  )),
        elevation: 2,
        titleSpacing: 5.0,
        // flexibleSpace: Padding(
        //   padding: EdgeInsets.only(right: 15),
        //   child: Align(
        //       alignment: Alignment.centerRight,
        //       child: IconButton(
        //         iconSize: 35,
        //         icon: Icon(Icons.add_alert_rounded),
        //         onPressed: () {
        //           UniversalRouter.changePath('about-me');
        //         },
        //       )),
        // ),
        title: Text(
          S.of(context).title,
          style: Theme.of(context).textTheme.headline3,
          overflow: TextOverflow.visible,
        ),
        actions: _actionButtonList +
            [
              // ActionButtonWidget(
              //     onPressed: () => UniversalRouter.changePath('about-me'),
              //     text: 'About Me')
              IconButton(
                iconSize: 35,
                icon: Icon(Icons.add_alert_rounded),
                onPressed: () {
                  MultiLayeredApp.layerManagement.createContainer(
                      options.openList,
                      layerName: 'NotificationLayer');

                  // UniversalRouter.changePath('about-me');
                },
              )
            ]);

final Widget Function(Widget child, {Key? key}) defaultNavigationLayer =
    (child, {Key? key}) => NavigationLayer(
          key: key,
          child: child,
        );

final Widget Function(Widget child, {Key? key}) defaultDecorationLayer =
    (child, {Key? key}) => DecorationLayer(
          key: key,
          child: child,
        );

setActionButton(List<Widget> list) => _actionButtonList = list;
