import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:abwesend/model/globals.dart' as global;

class AppInfo {
  void showAppInfo(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String datenbank = global.dbname;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return SimpleDialog(
              title: new Text("App-Info"),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('App-Name: $appName'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Package-Name: $packageName'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Version: $version'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Build-Number: $buildNumber'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Datenbank: $datenbank'),
                ),
              ]);
        });
  }
}
