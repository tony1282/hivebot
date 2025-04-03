import 'package:cloud_firestore/cloud_firestore.dart';

class BigContainer {
  final String id;
  final String tamano;
  final int capacidad;
  final String forma;
  final bool estadoConexion;
  final String material;
  final int cargaDispositivo;
  final int consumoEnergetico;
  final int nivelAlimento;
  final String sensorUltrasonico;

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
    required this.sensorUltrasonico,
  });

  factory BigContainer.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BigContainer(
      id: doc.id,
      tamano: data['tamano'] ?? 'Desconocido',
      capacidad: (data['capacidad'] ?? 0).toInt(),
      forma: data['forma'] ?? 'N/A',
      estadoConexion: data['estado_conexion'] ?? false,
      material: data['material'] ?? 'N/A',
      cargaDispositivo: (data['carga_dispositivo'] ?? 0).toInt(),
      consumoEnergetico: (data['consumo_energetico'] ?? 0).toInt(),
      nivelAlimento: (data['nivel_alimento'] ?? 0).toInt(),
      sensorUltrasonico: data['sensor_ultrasonico'] ?? 'Desconocido',
    );
  }
}
