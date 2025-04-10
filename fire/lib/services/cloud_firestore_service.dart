import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fire/models/big_container.dart';
import 'package:fire/models/container_data.dart';

class CloudFirestoreService {
  static final CloudFirestoreService _instance = CloudFirestoreService._internal();

  final FirebaseFirestore _cloudFirestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realTimeDatabase = FirebaseDatabase.instance;

  factory CloudFirestoreService() {
    return _instance;
  }

  CloudFirestoreService._internal();

  // Stream de contenedores grandes desde Firestore
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

  // Obtener datos de contenedor desde Realtime Database
  Stream<ContainerData?> getContainerData(String containerId) {
    return _realTimeDatabase.ref().child('contenedores/$containerId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return ContainerData(
          distancia: data['distancia'] ?? 0,
          cargaDispositivo: data['carga_dispositivo'] ?? 0,
          estadoConexion: data['estado_conexion'] ?? false,
          nivelGrande: data['nivel_grande'] ?? 0.0,
          nivelPequeno: data['nivel_pequeno'] ?? 0.0,
        );
      }
      return null;
    });
  }

  // Obtener datos de usuario desde Firestore
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

  // Actualizar datos del usuario
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection('usuarios').doc(userId).update(data);
    } catch (e) {
      print("Error actualizando datos del usuario: $e");
    }
  }

  // ✅ Insertar contenedor en Firestore (devuelve el DocumentReference)
  Future<DocumentReference> insertContainer(String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _cloudFirestore.collection(collection).add(data);
      return docRef;
    } catch (e) {
      print("Error insertando contenedor: $e");
      rethrow;
    }
  }

  // Eliminar contenedor de Firestore
  Future<void> deleteContainer(String collection, String docId) async {
    try {
      await _cloudFirestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print("Error eliminando contenedor: $e");
    }
  }

  // Actualizar contenedor en Firestore
  Future<void> updateContainer(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _cloudFirestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      print("Error actualizando contenedor: $e");
    }
  }

  // Insertar datos en Realtime Database
  Future<void> insertContainerData(String containerId, Map<String, dynamic> data) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').set(data);
    } catch (e) {
      print("Error insertando datos en tiempo real: $e");
    }
  }

  // Actualizar datos en Realtime Database
  Future<void> updateContainerData(String containerId, Map<String, dynamic> data) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').update(data);
    } catch (e) {
      print("Error actualizando datos en tiempo real: $e");
    }
  }

  // Eliminar datos en Realtime Database
  Future<void> deleteContainerData(String containerId) async {
    try {
      await _realTimeDatabase.ref().child('contenedores/$containerId').remove();
    } catch (e) {
      print("Error eliminando datos en tiempo real: $e");
    }
  }

  // Sincronizar datos entre Realtime Database y Firestore (sincroniza la distancia)
  Future<void> syncRealtimeDataToFirestore(String containerId) async {
    try {
      // Obtener los datos de Realtime Database
      final containerData = await getContainerData(containerId).first;
      if (containerData != null) {
        // Sincronizamos la distancia con Firestore
        await updateContainer(containerId, containerId, {
          'distancia_sensor': containerData.distancia,
        });
      }
    } catch (e) {
      print("Error sincronizando datos de Realtime Database a Firestore: $e");
    }
  }

  // Escuchar cambios en la distancia del sensor en Realtime Database
  void listenForSensorChanges(String containerId, Function(double) onDistanceChanged) {
    _realTimeDatabase.ref().child('contenedores/$containerId').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map && data.containsKey('distancia')) {
        final nuevaDistancia = (data['distancia'] ?? 0).toDouble();
        onDistanceChanged(nuevaDistancia);
      }
    });
  }
}
