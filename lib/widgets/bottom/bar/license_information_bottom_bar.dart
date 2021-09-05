import 'package:flutter/material.dart';
import 'package:localization/generated/l10n.dart';

class LicenseInformationBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          constraints: BoxConstraints(maxHeight: 20),
          decoration: BoxDecoration(
              color: Colors.white70,
              border: const Border(top: BorderSide(width: 1))),
          child: Text(
            S.of(context).license_announcement,
            style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          )));
}
