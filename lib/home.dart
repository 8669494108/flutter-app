import 'package:flutter/material.dart';
import 'package:pagenation_api/localalization.dart';
// import 'app_localizations.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).translate('message')),
      ),
    );
  }
}
