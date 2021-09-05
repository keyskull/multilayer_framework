import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:localization/generated/l10n.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:universal_router/route.dart';
import 'package:universal_scroll_view/universal_single_child_scroll_view.dart';
import 'package:utilities/custom_log_printer.dart';
import 'package:utilities/screen_size.dart';
import 'package:uuid/uuid.dart';

import 'widgets/custom_navigation_rail.dart';
import 'widgets/floating_action_button.dart';
import 'widgets/windows/default_window_frame.dart';
import 'widgets/windows/window_frame.dart';

part 'layers/decoration_layer.dart';
part 'layers/navigation_layer.dart';
part 'layers/window_layer.dart';
part 'properties/default_navigation_rail_buttons.dart';
part 'widgets/windows/single_window_interface.dart';

void _func() {}

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
              style: const TextStyle(fontWeight: FontWeight.w400),
            )),
      );
}

List<ActionButtonWidget> _actionButtonList = [];

final defaultAppBarBuilder = (double appBarHeight, BuildContext context) =>
    AppBar(
        toolbarHeight: appBarHeight,
        backwardsCompatibility: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Container(
            margin: const EdgeInsets.only(left: 20.0),
            child: ((globalNavigatorKey.currentState?.widget.pages.first.key
                            as ValueKey)
                        .value as RouteData)
                    .isRoot()
                ? const Image(image: AssetImage("images/logo.png"))
                : BackButton(
                    onPressed: () => globalNavigatorKey.currentState?.pop(),
                  )),
        elevation: 2,
        titleSpacing: 5.0,
        title: Text(
          S.of(context).title,
          // style: const TextStyle(color: Colors.black),
          overflow: TextOverflow.visible,
        ),
        actions: _actionButtonList +
            [
              ActionButtonWidget(
                  onPressed: () =>
                      Provider.of<PathHandler>(context, listen: false)
                          .changePath("about-me"),
                  text: 'About Me')
            ]);

final Widget Function(Widget child) defaultNavigationLayer =
    (child) => NavigationLayer(
          child: child,
        );

AppBar Function(double, BuildContext) _appBarBuilder = defaultAppBarBuilder;

setAppbarBuilder(AppBar Function(double, BuildContext) newAppBarBuilder) =>
    _appBarBuilder = newAppBarBuilder;

setActionButton(List<ActionButtonWidget> list) => _actionButtonList = list;
