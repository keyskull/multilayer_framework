import 'dart:collection';

import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/overlay.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../framework.dart';
import '../layer_management.dart';

enum options { openList }

class StateSetting {
  void Function(VoidCallback fn)? setState;
  BuildContext? context;
  void Function(String text)? addNotificationCard;
  void Function()? openNotificationList;
}

final LinkedHashMap<String, Widget> notificationList = LinkedHashMap();
final StateSetting stateSetting = StateSetting();

class NotificationLayer extends StatefulWidget with MultiLayer {
  final logger = Logger(printer: CustomLogPrinter('NotificationLayer'));

  final BuildContext context;

  NotificationLayer(this.context);

  @override
  createContainer(identity) {
    if (identity is options) {
      switch (identity) {
        case options.openList:
          stateSetting.openNotificationList != null
              ? stateSetting.openNotificationList!()
              : {};
          break;
      }
    } else if (identity is String) {
      stateSetting.addNotificationCard != null
          ? stateSetting.addNotificationCard!(identity)
          : {};
    }
    logger.i('createContainer executed: ' + identity);
  }

  @override
  destroyContainer(identity) {}

  @override
  final String name = 'NotificationLayer';

  @override
  OverlayEntry Function(BuildContext context, Widget? child)
      get overlayEntryBuilder =>
          (context, child) => OverlayEntry(builder: (context) => this);

  @override
  State<StatefulWidget> createState() => NotificationLayerState();
}

class NotificationLayerState extends State<NotificationLayer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    widget.logger.i('initState');
    stateSetting.setState = setState;
    stateSetting.context = context;
    stateSetting.addNotificationCard = addNotificationCard;
    stateSetting.openNotificationList = openNotificationList;
    super.initState();
  }

  @override
  void dispose() {
    stateSetting.setState = null;
    stateSetting.context = null;
    stateSetting.addNotificationCard = null;
    stateSetting.openNotificationList = null;
    super.dispose();
  }

  void addNotificationCard(String text) {
    this.setState(() {
      final uuid = Uuid().v1();
      TweenAnimationBuilder tweenAnimationBuilder =
          TweenAnimationBuilder<double>(
        duration: Duration(seconds: 15),
        tween: Tween<double>(begin: 1, end: 0),
        builder: (BuildContext context, double size, Widget? child) =>
            Opacity(opacity: size, child: child),
        child: Card(
            margin: EdgeInsets.all(10),
            color: Theme.of(context).secondaryHeaderColor,
            child: ListTile(
              title: Text(text),
              trailing: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  this.setState(() {
                    notificationList.remove(uuid);
                  });
                },
              ),
            )),
      );

      notificationList[uuid] = (tweenAnimationBuilder);
      Future.delayed(Duration(seconds: 10), () {
        this.setState(() {
          notificationList.remove(uuid);
        });
      });
    });
  }

  consistNotificationList(BuildContext context) => Padding(
      padding: EdgeInsets.only(top: appBarHeight + 10, right: 15),
      child: Container(
        constraints: BoxConstraints(minHeight: 0, maxHeight: 500),
        width: 300,
        child: Card(
            child: ListView(
          children: [
            ColoredBox(
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        'Notification',
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider()
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(),
            )
          ],
        )),
      ));

  openNotificationList() {
    this.setState(() {
      this.stack = Stack(
        alignment: Alignment.topRight,
        children: [
          consistNotificationList(context),
          Padding(
              padding: EdgeInsets.only(top: appBarHeight + 15, right: 15),
              child: Container(
                constraints: BoxConstraints(minHeight: 0, maxHeight: 500),
                width: 300,
                child: SingleChildScrollView(
                  child: Column(children: notificationList.values.toList()),
                ),
              ))
        ],
      );
    });
  }

  closeNotificationList() {
    this.setState(() {
      this.stack = Stack(alignment: Alignment.topRight, children: [
        Padding(
            padding: EdgeInsets.only(top: appBarHeight + 15, right: 15),
            child: Container(
              constraints: BoxConstraints(minHeight: 0, maxHeight: 500),
              width: 300,
              child: SingleChildScrollView(
                child: Column(children: notificationList.values.toList()),
              ),
            ))
      ]);
    });
  }

  Widget stack = Stack();

  @override
  Widget build(BuildContext context) {
    stateSetting.context = context;
    stateSetting.setState = setState;
    closeNotificationList();
    return this.stack;
  }
}
