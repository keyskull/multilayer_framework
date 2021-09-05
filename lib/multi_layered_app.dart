import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:universal_router/init_router_base.dart';
import 'package:universal_router/route.dart';
import 'package:utilities/screen_size.dart';

import 'framework.dart';
import 'widgets/bottom/bar/license_information_bottom_bar.dart';

void _func(BuildContext context) {}

class MultiLayeredApp extends StatefulWidget {
  final void Function(BuildContext context) initProcess;
  final Widget Function(Widget child)? navigationLayerBuilder;
  final Widget Function(Widget child)? decorationLayerBuilder;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  MultiLayeredApp(
      {Key? key,
      this.initProcess = _func,
      this.navigationLayerBuilder,
      this.decorationLayerBuilder,
      this.theme,
      this.darkTheme,
      this.themeMode = ThemeMode.system})
      : super(key: key);

  @override
  _MultiLayeredAppAppState createState() => _MultiLayeredAppAppState(
      initProcess,
      navigationLayerBuilder ?? defaultNavigationLayer,
      decorationLayerBuilder ??
          (child) => Stack(
                children: [child, LicenseInformationBottomBar()],
              ),
      theme ?? ThemeData.light(),
      darkTheme ?? ThemeData.dark(),
      this.themeMode);
}

class _MultiLayeredAppAppState extends State<MultiLayeredApp> {
  final void Function(BuildContext context) initProcess;
  final Widget Function(Widget child) navigationLayerBuilder;
  final Widget Function(Widget child) decorationLayerBuilder;
  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  _MultiLayeredAppAppState(this.initProcess, this.navigationLayerBuilder,
      this.decorationLayerBuilder, this.theme, this.darkTheme, this.themeMode);

  String title = '';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PathHandler()),
        ChangeNotifierProvider(create: (context) => PathHandler()),
      ],
      child: MaterialApp.router(
        theme: theme,
        darkTheme: darkTheme,
        title: title,
        themeMode: themeMode,
        routerDelegate: RouterDelegateInherit(),
        routeInformationParser: RouteInformationParserInherit(),
        builder: (context, Widget? child) {
          ScreenSize.initScreenSize(context);
          this.initProcess(context);
          final unknown =
              (InitRouterBase.unknownPage.getPage() as MaterialPage).child;
          log("${child.runtimeType.toString()}");

          return Overlay(
            initialEntries: [
              OverlayEntry(
                  maintainState: true,
                  builder: (context) => decorationLayerBuilder(
                      navigationLayerBuilder(child ?? unknown))),
            ],
          );
        },
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      title = S.current.title;
    });
  }
}
