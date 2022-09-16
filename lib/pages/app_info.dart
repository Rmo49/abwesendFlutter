import 'package:flutter/material.dart';
import 'package:abwesend/model/globals.dart' as global;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String? datenbank = global.dbName;

  void showAppInfo(BuildContext context) async {
    if (kIsWeb) {
      version = "1.24.0";
      buildNumber = "24";
    } else {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      datenbank = global.dbName;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return SimpleDialog(
            title: const Text("App-Info"),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        });
  }
}
