import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../layer_management.dart';

class _StateSetting {
  void Function(Dialog dialog)? showDialog;
  void Function()? destroyDialog;

  _StateSetting({this.showDialog, this.destroyDialog});
}

_StateSetting? _stateSetting;

class DialogLayer extends StatefulWidget with MultiLayer {
  final logger = Logger(printer: CustomLogPrinter('DialogLayer'));

  @override
  createContainer(identity) {
    if (identity is Dialog) {
      _stateSetting?.showDialog?.call(identity);
    }
    logger.i('createContainer executed: ' + identity.toString());
  }

  @override
  destroyContainer(identity) {
    if (identity is Dialog) {
      _stateSetting?.destroyDialog?.call();
    }
    logger.i('destroyContainer executed: ' + identity.toString());
  }

  @override
  final String name = 'DialogLayer';

  @override
  List<OverlayEntry> Function(BuildContext context, Widget? child)
      get overlayEntryBuilder =>
          (context, child) => [OverlayEntry(builder: (context) => this)];

  @override
  State<StatefulWidget> createState() => DialogLayerState();
}

class DialogLayerState extends State<DialogLayer> {
  Dialog? _dialog;

  showDialog_2(Dialog dialog) {
    setState(() {
      showDialog(
          context: context,
          builder: (context) => SimpleDialog(),
          routeSettings: RouteSettings());

      _dialog = dialog;
    });
  }

  destroyDialog() {
    setState(() {
      _dialog = null;
    });
  }

  @override
  void initState() {
    _stateSetting = new _StateSetting(
        showDialog: showDialog_2, destroyDialog: destroyDialog);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [SimpleDialog()],
    );
  }
}
