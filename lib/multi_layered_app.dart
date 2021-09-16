import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/generated/l10n.dart';
import 'package:logger/logger.dart';
import 'package:universal_router/init_router_base.dart';
import 'package:universal_router/route.dart';

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
  static final universalRouter = UniversalRouter();

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
  _MultiLayeredAppAppState createState() => _MultiLayeredAppAppState();
}

class _MultiLayeredAppAppState extends State<MultiLayeredApp> {
  final logger = Logger(printer: CustomLogPrinter('MultiLayeredApp'));

  String title = '';

  @override
  void initState() {
    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget Function(Widget child) navigationLayerBuilder =
        widget.navigationLayerBuilder ?? defaultNavigationLayer;
    final Widget Function(Widget child) decorationLayerBuilder =
        widget.decorationLayerBuilder ??
            (child) => Stack(
                  children: [child, LicenseInformationBottomBar()],
                );
    return MaterialApp.router(
      theme: widget.theme ?? ThemeData.light(),
      darkTheme: widget.darkTheme ?? ThemeData.dark(),
      title: title,
      themeMode: widget.themeMode,
      routerDelegate: MultiLayeredApp.universalRouter.routerDelegate,
      routeInformationProvider:
          MultiLayeredApp.universalRouter.routeInformationProvider,
      routeInformationParser:
          MultiLayeredApp.universalRouter.routerInformationParser,
      builder: (context, Widget? child) {
        ScreenSize.initScreenSize(context);
        widget.initProcess(context);
        logger.d('Started initial process.');
        return Overlay(
          initialEntries: [
            OverlayEntry(
                maintainState: true,
                builder: (context) {
                  return decorationLayerBuilder(navigationLayerBuilder(
                      child ?? InitRouterBase.unknownPage.getPage().child));
                }),
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

  void afterFirstLayout(BuildContext context) {
    setState(() {
      title = S.current.title;
    });
  }
}
