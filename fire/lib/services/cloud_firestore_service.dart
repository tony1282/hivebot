import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fire/models/big_container.dart';

class CloudFirestoreService {
  static final CloudFirestoreService _instance = CloudFirestoreService._internal();
  final FirebaseFirestore _cloudFirestore = FirebaseFirestore.instance;
  
  // Referencia a la Realtime Database
  final FirebaseDatabase _realTimeDatabase = FirebaseDatabase.instance;

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

  // Obtiene datos en tiempo real desde la Realtime Database
  Stream<ContainerData> getContainerData(String containerId) {
    return _realTimeDatabase
        .ref() // Aquí cambiamos reference() por ref()
        .child('contenedores/$containerId')  // Ruta del contenedor
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?; // Asegúrate de que el dato sea un Map
      return ContainerData(
        distancia: data?['distancia'] ?? 0,
        cargaDispositivo: data?['carga_dispositivo'] ?? 0,
        estadoConexion: data?['estado_conexion'] ?? false,
      );
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

  // Inserta o actualiza un contenedor en la Realtime Database
  Future<void> updateContainerInRealtimeDatabase(String containerId, Map<String, dynamic> data) {
    return _realTimeDatabase
        .ref() // Cambiar de reference() a ref()
        .child('contenedores/$containerId')  // Ruta del contenedor
        .update(data);
  }
}

// Datos que se leen desde la base de datos en tiempo real
class ContainerData {
  final int distancia;
  final int cargaDispositivo;
  final bool estadoConexion;

  ContainerData({
    required this.distancia,
    required this.cargaDispositivo,
    required this.estadoConexion,
  });
}
