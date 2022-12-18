import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseService{
  late FirebaseFirestore db;
  late Stream<QuerySnapshot> stream;

  Future<void> initializeDb() async {
    db = FirebaseFirestore.instance;
    stream = db.collection("user").snapshots();
  }

  Future<void> removeMusic(String name,String trackName,String id) async {
    return db.collection('track')
    .where('name', isEqualTo: name)
    .where('trackName', isEqualTo: trackName)
    .where('id', isEqualTo: id)
    .get().then((value) => value.docs.first.reference.delete());
  }
  
}