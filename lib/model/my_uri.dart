import 'local_storage.dart';

class MyUri {

  static Uri getUri(String path) {
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        port: localStorage.port,
        path: localStorage.path! + path);
    return uri;
  }
}