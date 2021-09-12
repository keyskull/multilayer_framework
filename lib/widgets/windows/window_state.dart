import 'package:flutter/material.dart';

import '../../../framework.dart';

class Window extends StatefulWidget {
  final SingleWindowInterface? singleWindowInterface;

  Window({this.singleWindowInterface});

  @override
  WindowState createState() => WindowState(singleWindowInterface ?? unknown);
}

class WindowState extends State<Window> {
  SingleWindowInterface singleWindowInterface;

  WindowState(this.singleWindowInterface);

  Function() afterFirstLayoutFunction = () {};

  refresh(SingleWindowInterface singleWindowInterface) {
    if (singleWindowInterface == this.singleWindowInterface) {}

    final function = () => setState(() {
          if (singleWindowInterface == this.singleWindowInterface)
            this.singleWindowInterface =
                new SingleWindowInterface(child: singleWindowInterface);
          else
            this.singleWindowInterface = singleWindowInterface;
        });
    this.mounted ? function() : afterFirstLayoutFunction = function;
  }

  @override
  void initState() {
    windowsContainer.windowStates.add(this);
    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => singleWindowInterface;

  @override
  void dispose() {
    windowsContainer.windowStates.remove(this);
    windowsContainer.windows.removeLast();
    super.dispose();
  }

  void afterFirstLayout(BuildContext context) {
    afterFirstLayoutFunction();
  }
}
