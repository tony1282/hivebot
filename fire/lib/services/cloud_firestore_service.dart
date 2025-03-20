import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire/models/big_container.dart';

class CloudFirestoreService {
  static final CloudFirestoreService _instance = CloudFirestoreService._internal();
  final FirebaseFirestore _cloudFirestore = FirebaseFirestore.instance;

  factory CloudFirestoreService() {
    return _instance;
  }

  CloudFirestoreService._internal();

  // Obtiene una lista de BigContainers en tiempo real desde Firestore
 Stream<List<BigContainer>> getBigContainers(String collection) {
  return _cloudFirestore.collection(collection).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return BigContainer.fromDocumentSnapshot(doc);
    }).toList();
  });
}


  // Actualiza un BigContainer existente en Firestore
  Future<void> updateContainer(String collection, String docId, Map<String, dynamic> data) {
    return _cloudFirestore.collection(collection).doc(docId).update(data);
  }

  // Elimina un BigContainer de Firestore
  Future<void> deleteContainer(String collection, String docId) {
    return _cloudFirestore.collection(collection).doc(docId).delete();
  }

  // Inserta un nuevo BigContainer en Firestore
  Future<void> insertContainer(String collection, Map<String, dynamic> data) {
    return _cloudFirestore.collection(collection).add(data);
  }
}
