import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSpieler {

  // Collection Reference, wenn nicht existiert, dann wird durch DB angelegt
  final CollectionReference spielerCollection =
  Firestore.instance.collection('spieler');

  void createNewSpieler() async {
//    Spieler spieler = Spieler(name: 'spieler1', vorname: 'vor1');
    await spielerCollection
        .document("SP01")
        .setData({
      'name': 'Name 11',
      'vorname': 'Vorname 11'
    });

    DocumentReference ref = await Firestore.instance.collection("spieler")
        .add({
      'name': 'Name 21',
      'vorname': 'Vorname 21'
    });
    print(ref.documentID);
  }


}