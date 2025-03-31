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

  // Método para crear los datos del usuario en Firestore
  Future<void> createUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection('users').doc(uid).set(data);  // Usa .set() para crear el documento si no existe
    } catch (e) {
      print("Error creando datos del usuario: $e");
    }
  }

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
        .ref()
        .child('contenedores/$containerId')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
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
        .ref()
        .child('contenedores/$containerId')
        .update(data);
  }

  // Obtiene los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _cloudFirestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error obteniendo datos del usuario: $e");
      return null;
    }
  }

  // Actualiza los datos del usuario en Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error actualizando datos del usuario: $e");
    }
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
