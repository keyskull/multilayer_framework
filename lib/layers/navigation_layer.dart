part of '../framework.dart';

class NavigationLayer extends StatefulWidget {
  final Widget child;
  final GlobalKey<CustomNavigationRailState> navigationRailKey = GlobalKey();
  final int defaultNavigationSelectedIndex;
  final NavigationRailButtons? navigationRailButtons;

  NavigationLayer(
      {Key? key,
      required this.child,
      this.defaultNavigationSelectedIndex = 0,
      this.navigationRailButtons})
      : super(key: key);

  @override
  NavigationLayerState createState() => NavigationLayerState(
      child,
      navigationRailKey,
      defaultNavigationSelectedIndex,
      navigationRailButtons ?? defaultNavigationRailButtons);
}

class NavigationLayerState extends State<NavigationLayer>
    with TickerProviderStateMixin {
  final Widget child;
  final GlobalKey<CustomNavigationRailState> navigationRailKey;
  final int defaultNavigationSelectedIndex;
  final NavigationRailButtons navigationRailButtons;

  NavigationLayerState(this.child, this.navigationRailKey,
      this.defaultNavigationSelectedIndex, this.navigationRailButtons);

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
      child: child,
      navigationRailButtons: navigationRailButtons,
      defaultIndex: defaultNavigationSelectedIndex,
    );

    return Scaffold(
        // key: scaffoldKey,
        backgroundColor: Colors.black87,
        body: WindowLayer(
            child: RawMaterialButton(
                mouseCursor: SystemMouseCursors.basic,
                onPressed: () => navigationRailKey.currentState?..closeRail(),
                child: customNavigationRail)),
        // floatingActionButtonAnimator: ,
        floatingActionButton: defaultFloatingActionButtons(
          context,
          switchNavigatorRailState: _switchNavigatorRailState,
          switchContactButtonState: _switchContactButtonState,
          hiddenNavigation: hiddenNavigation,
          contactButtonExtended: contactButtonExtended,
        ));
  }
}
