import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fire/models/big_container.dart';
import 'package:fire/models/container_data.dart'; // Asegúrate de que esta línea esté presente

class CloudFirestoreService {
  static final CloudFirestoreService _instance = CloudFirestoreService._internal();

  final FirebaseFirestore _cloudFirestore = FirebaseFirestore.instance; // Inicialización de Firestore
  final FirebaseDatabase _realTimeDatabase = FirebaseDatabase.instance;

  factory CloudFirestoreService() {
    return _instance;
  }

  CloudFirestoreService._internal();

  // Obtiene una lista de BigContainers desde Firestore en tiempo real
  Stream<List<BigContainer>> getBigContainers(String collection) {
    return _cloudFirestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return BigContainer.fromDocumentSnapshot(doc);
        } catch (e) {
          print('Error en documento ${doc.id}: $e');
          return null;
        }
      }).whereType<BigContainer>().toList();
    });
  }

  // Obtiene datos en tiempo real desde la Realtime Database
  Stream<ContainerData?> getContainerData(String containerId) {
    return _realTimeDatabase.ref().child('contenedores/$containerId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return ContainerData(
          distancia: data['distancia'] ?? 0,
          cargaDispositivo: data['carga_dispositivo'] ?? 0,
          estadoConexion: data['estado_conexion'] ?? false,
        );
      }
      return null;
    });
  }

  // Obtiene los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _cloudFirestore.collection('usuarios').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error obteniendo datos del usuario: $e");
    }
    return null;
  }

  // Actualiza los datos del usuario en Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection('usuarios').doc(userId).update(data);
    } catch (e) {
      print("Error actualizando datos del usuario: $e");
    }
  }

  // Inserta un nuevo contenedor en Firestore
  Future<void> insertContainer(String collection, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection(collection).add(data);
    } catch (e) {
      print("Error insertando contenedor: $e");
    }
  }

  // Elimina un contenedor de Firestore
  Future<void> deleteContainer(String collection, String docId) async {
    try {
      await _cloudFirestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print("Error eliminando contenedor: $e");
    }
  }

  // Actualiza un contenedor en Firestore
  Future<void> updateContainer(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      print("Error actualizando contenedor: $e");
    }
  }

  // Inserta datos en tiempo real para un contenedor específico
  Future<void> insertContainerData(String containerId, Map<String, dynamic> data) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').set(data);
    } catch (e) {
      print("Error insertando datos en tiempo real: $e");
    }
  }

  // Actualiza datos en tiempo real para un contenedor específico
  Future<void> updateContainerData(String containerId, Map<String, dynamic> data) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').update(data);
    } catch (e) {
      print("Error actualizando datos en tiempo real: $e");
    }
  }

  // Elimina datos en tiempo real para un contenedor específico
  Future<void> deleteContainerData(String containerId) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').remove();
    } catch (e) {
      print("Error eliminando datos en tiempo real: $e");
    }
  }
}
