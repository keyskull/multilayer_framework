import 'package:flutter/material.dart';

import '../../../framework.dart';

class Window extends StatefulWidget {
  final SingleWindowWidget? singleWindowWidget;

  Window({this.singleWindowWidget});

  @override
  WindowState createState() => WindowState();
}

class WindowState extends State<Window> {
  SingleWindowWidget singleWindowInterface = unknown;

  Function() afterFirstLayoutFunction = () {};

  refresh(SingleWindowWidget singleWindowWidget) {
    final function = () => setState(() {
          if (singleWindowWidget == this.singleWindowInterface)
            this.singleWindowInterface =
                SingleWindowInterface(singleWindowWidget);
          else
            this.singleWindowInterface = singleWindowWidget;
        });
    this.mounted ? function() : afterFirstLayoutFunction = function;
  }

  @override
  void initState() {
    if (widget.singleWindowWidget != null)
      this.singleWindowInterface = widget.singleWindowWidget!;
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
