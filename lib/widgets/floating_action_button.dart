import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../multi_layered_app.dart';

final defaultFloatingActionButtons = (context,
        {required Function() switchNavigatorRailState,
        required Function() switchContactButtonState,
        required bool hiddenNavigation,
        required bool contactButtonExtended,
        Dialog contactButtonDialog = const Dialog()}) =>
    Opacity(
      opacity: 0.7,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
              padding: EdgeInsets.only(
                  right: ScreenSize.getFlashScreenSize(context).width - 85),
              child: PointerInterceptor(
                  child: FloatingActionButton(
                onPressed: () {
                  switchNavigatorRailState();
                },
                child: hiddenNavigation
                    ? Icon(Icons.arrow_forward_ios_outlined)
                    : Icon(Icons.arrow_back_ios_outlined),
                heroTag: 'hidden',
              ))),
          PointerInterceptor(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              mini: true,
              onPressed: () {
                switchContactButtonState();
                launch('mailto:contact@numflurry.ml');
              },
              child: contactButtonExtended
                  ? Icon(Icons.email)
                  : Icon(Icons.email_outlined),
              heroTag: 'btn2',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              mini: true,
              onPressed: () {
                switchContactButtonState();
                MultiLayeredApp.layerManagement.createContainer(
                    'blog/使用免费网络源创建个人网站的多种方法和实现过程',
                    layerName: 'WindowLayer');
                // windowsContainer.openWindow(InstanceBuilder(
                //     windowBuilder: (id) =>
                //         SingleWindowInterface.buildWithSingleWindowInterface(
                //           id,
                //           // MarkdownEditor()
                //           Container(
                //             color: Colors.blue.withRed(Random().nextInt(255)),
                //             child: Text('[' +
                //                 windowsContainer.getWindowIdList().join(',') +
                //                 ']'),
                //           ),
                //         )));
              },
              child: contactButtonExtended
                  ? Icon(Icons.message)
                  : Icon(Icons.message_outlined),
            )
          ]))
        ],
      ),
    );
