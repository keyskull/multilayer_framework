// import 'package:flutter/material.dart';
//
// import '../../framework.dart';
// import '../../layers/window_layer.dart';
// import 'default_window_frame_widget.dart';
// import 'window_frame_widget.dart';
//
// WindowFrameWidget Function(Widget child, String id) windowFrameBuilder =
//     (Widget child, String id) => DefaultWindowFrameWidget(child, id);
//
// class Window extends StatefulWidget {
//   final SingleWindowWidget? singleWindowWidget;
//
//   Window({this.singleWindowWidget});
//
//   @override
//   WindowState createState() => WindowState();
// }
//
// class WindowState extends State<Window> {
//   SingleWindowWidget singleWindowInterface = unknown;
//
//   Function() afterFirstLayoutFunction = () {};
//
//   refresh(SingleWindowWidget singleWindowWidget) {
//     final function = () => setState(() {
//           if (singleWindowWidget == this.singleWindowInterface)
//             this.singleWindowInterface =
//                 SingleWindowInterface(singleWindowWidget);
//           else
//             this.singleWindowInterface = singleWindowWidget;
//         });
//     this.mounted ? function() : afterFirstLayoutFunction = function;
//   }
//
//   @override
//   void initState() {
//     if (widget.singleWindowWidget != null)
//       this.singleWindowInterface = widget.singleWindowWidget!;
//     windowsContainer.windowStates.add(this);
//     WidgetsBinding.instance!.endOfFrame.then(
//       (_) => afterFirstLayout(context),
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) => windowFrameBuilder(
//       this.singleWindowInterface, this.singleWindowInterface.id);
//
//   @override
//   void dispose() {
//     windowsContainer.windowStates.remove(this);
//     windowsContainer.windows.removeLast();
//     super.dispose();
//   }
//
//   void afterFirstLayout(BuildContext context) {
//     afterFirstLayoutFunction();
//   }
// }
