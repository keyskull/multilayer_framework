part of '../framework.dart';

final GlobalKey<CustomNavigationRailState> navigationRailKey = GlobalKey();

Function(BuildContext context,
        {required Function() switchNavigatorRailState,
        required Function() switchContactButtonState,
        required bool hiddenNavigation,
        required bool contactButtonExtended,
        Dialog contactButtonDialog}) floatingActionButton =
    defaultFloatingActionButtons;

class NavigationLayer extends StatefulWidget {
  final Widget child;
  final NavigationRailButtons? navigationRailButtons;

  NavigationLayer({Key? key, required this.child, this.navigationRailButtons})
      : super(key: key);

  @override
  NavigationLayerState createState() => NavigationLayerState();
}

class NavigationLayerState extends State<NavigationLayer>
    with SingleTickerProviderStateMixin {
  bool hiddenNavigation = false;
  bool contactButtonExtended = true;

  @override
  void initState() {
    contactButtonExtended = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hiddenNavigation = !ScreenSize.isDesktop(context);
  }

  _switchContactButtonState() {
    setState(() {
      contactButtonExtended = !contactButtonExtended;
    });
  }

  _switchNavigatorRailState() {
    setState(() {
      hiddenNavigation = !hiddenNavigation;
      navigationRailKey.currentState?..extendNavigationRail();
      navigationRailKey.currentState?..closeRail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customNavigationRail = CustomNavigationRail(
      key: navigationRailKey,
      child: widget.child,
      navigationRailButtons:
          widget.navigationRailButtons ?? defaultNavigationRailButtons,
    );

    return Scaffold(
        // key: scaffoldKey,
        primary: true,
        body: RawMaterialButton(
            mouseCursor: SystemMouseCursors.basic,
            onPressed: () => navigationRailKey.currentState?.closeRail(),
            child: customNavigationRail),
        // floatingActionButtonAnimator: ,
        floatingActionButton: floatingActionButton(
          context,
          switchNavigatorRailState: _switchNavigatorRailState,
          switchContactButtonState: _switchContactButtonState,
          hiddenNavigation: hiddenNavigation,
          contactButtonExtended: contactButtonExtended,
        ));
  }
}
