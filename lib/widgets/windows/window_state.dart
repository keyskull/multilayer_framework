import 'package:flutter/material.dart';

import '../../../framework.dart';

class Window extends StatefulWidget {
  final SingleWindowInterface? singleWindowInterface;

  Window({this.singleWindowInterface});

  @override
  WindowState createState() => WindowState();
}

class WindowState extends State<Window> {
  SingleWindowInterface singleWindowInterface = unknown;

  Function() afterFirstLayoutFunction = () {};

  refresh(SingleWindowInterface singleWindowInterface) {
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
    if (widget.singleWindowInterface != null)
      this.singleWindowInterface = widget.singleWindowInterface!;
    windowsContainer.windowStates.add(this);
    WidgetsBinding.instance!.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => this.singleWindowInterface;

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
