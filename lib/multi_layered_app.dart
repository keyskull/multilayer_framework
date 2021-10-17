import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/generated/l10n.dart';
import 'package:logger/logger.dart';
import 'package:universal_router/route.dart';

import 'framework.dart';

void _func(BuildContext context) {}

class MultiLayeredApp extends StatelessWidget {
  final void Function(BuildContext context) initProcess;
  final Widget Function(Widget child, {Key? key})? navigationLayerBuilder;
  final Widget Function(Widget child, {Key? key})? decorationLayerBuilder;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  static final universalRouter = UniversalRouter.initialize();
  static changePath(String path) => UniversalRouter.changePath(path);
  MultiLayeredApp(
      {Key? key,
      this.initProcess = _func,
      this.navigationLayerBuilder,
      this.decorationLayerBuilder,
      this.theme,
      this.darkTheme,
      this.themeMode = ThemeMode.system})
      : super(key: key);

  final logger = Logger(printer: CustomLogPrinter('MultiLayeredApp'));

  @override
  Widget build(BuildContext context) {
    final navigationLayerBuilder =
        this.navigationLayerBuilder ?? defaultNavigationLayer;
    final decorationLayerBuilder =
        this.decorationLayerBuilder ?? defaultDecorationLayer;
    return MaterialApp.router(
      theme: theme ?? ThemeData.light(),
      darkTheme: darkTheme ?? ThemeData.dark(),
      themeMode: themeMode,
      routerDelegate: MultiLayeredApp.universalRouter.routerDelegate,
      routeInformationProvider:
          MultiLayeredApp.universalRouter.routeInformationProvider,
      routeInformationParser:
          MultiLayeredApp.universalRouter.routerInformationParser,
      builder: (context, Widget? child) {
        ScreenSize.initScreenSize(context);
        initProcess(context);
        logger.d('Started initial process.');

        return Overlay(
          initialEntries: [
            OverlayEntry(
                builder: (context) => navigationLayerBuilder(
                    decorationLayerBuilder(
                        child ?? UniversalRouter.unknownPage.getPage().child))),
            OverlayEntry(
                maintainState: true, builder: (context) => WindowLayer())
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
    );
  }
}
