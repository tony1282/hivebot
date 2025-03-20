import 'package:cloud_firestore/cloud_firestore.dart';

class BigContainer {
  final String id;
  final String tamano;
  final int capacidad;  // Esto debe ser int
  final String forma;
  final bool estadoConexion;
  final String material;
  final int cargaDispositivo;  // Esto debe ser int
  final int consumoEnergetico;  // Esto debe ser int
  final int nivelAlimento;  // Esto debe ser int

  BigContainer({
    required this.id,
    required this.tamano,
    required this.capacidad,
    required this.forma,
    required this.estadoConexion,
    required this.material,
    required this.cargaDispositivo,
    required this.consumoEnergetico,
    required this.nivelAlimento,
  });

  // Convierte el objeto a un mapa para almacenar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'tamano': tamano,
      'capacidad': capacidad,  // Mantén el tipo int
      'forma': forma,
      'estado_conexion': estadoConexion,
      'material': material,
      'carga_dispositivo': cargaDispositivo,  // Mantén el tipo int
      'consumo_energetico': consumoEnergetico,  // Mantén el tipo int
      'nivel_alimento': nivelAlimento,  // Mantén el tipo int
    };
  }

  // Método fromDocumentSnapshot para crear un objeto BigContainer desde un mapa de Firestore
  factory BigContainer.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return BigContainer(
      id: doc.id,
      tamano: data?['tamano'] ?? '',
      capacidad: data?['capacidad'] ?? 0,  // Asegúrate de que Firestore almacene un int aquí
      forma: data?['forma'] ?? '',
      estadoConexion: data?['estado_conexion'] ?? false,
      material: data?['material'] ?? '',
      cargaDispositivo: data?['carga_dispositivo'] ?? 0,  // Asegúrate de que Firestore almacene un int aquí
      consumoEnergetico: data?['consumo_energetico'] ?? 0,  // Asegúrate de que Firestore almacene un int aquí
      nivelAlimento: data?['nivel_alimento'] ?? 0,  // Asegúrate de que Firestore almacene un int aquí
    );
  }
}
