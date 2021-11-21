import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../layer_management.dart';

class _StateSetting {
  void Function(Widget dialog) showDialog;
  void Function() destroyDialog;

  _StateSetting(this.showDialog, this.destroyDialog);
}

_StateSetting? _stateSetting;

final logger = Logger(printer: CustomLogPrinter('DialogLayer'));

class DialogLayer extends StatefulWidget with MultiLayer {
  @override
  createContainer(identity) {
    if (identity is Widget) {
      _stateSetting?.showDialog(identity);
    }
    logger.i('createContainer executed: ' + identity.toString());
  }

  @override
  destroyContainer(identity) {
    _stateSetting?.destroyDialog();
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
  late Widget _dialog;

  showDialog(Widget dialog) {
    setState(() {
      logger.i('showDialog executed: ');
      this._dialog = Stack(fit: StackFit.expand, children: [
        GestureDetector(
            onTap: () {
              setState(() {
                _dialog = Container();
              });
            },
            child: ColoredBox(
              color: Colors.black.withOpacity(0.5),
            )),
        dialog
      ]);
    });
  }

  destroyDialog() {
    setState(() {
      _dialog = Container();
    });
  }

  @override
  void initState() {
    _stateSetting = _StateSetting(showDialog, destroyDialog);
    _dialog = Container();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _dialog);
  }
}
