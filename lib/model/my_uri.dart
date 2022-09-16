import 'local_storage.dart';

class MyUri {

  static Uri getUri(String pathTemp) {
    LocalStorage localStorage = LocalStorage();
    // nur damit ein Objekt angelegt.
    Uri uri = Uri(host: "nomadus.ch");
    String lPath =  localStorage.path + pathTemp;
    if (localStorage.port > 0) {
      uri = Uri(
          scheme: localStorage.scheme,
          host: localStorage.host,
          port: localStorage.port,
          path: lPath);
    }
    else {
      // Uri ohne port
      uri = Uri(
          scheme: localStorage.scheme,
          host: localStorage.host,
          path: lPath);
    }
    return uri;
  }
}