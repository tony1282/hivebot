// lib/models/container_data.dart

class ContainerData {
  final int distancia;
  final int cargaDispositivo;
  final bool estadoConexion;

  ContainerData({
    required this.distancia,
    required this.cargaDispositivo,
    required this.estadoConexion,
  });

  factory ContainerData.fromMap(Map<String, dynamic> map) {
    return ContainerData(
      distancia: map['distancia'] ?? 0,
      cargaDispositivo: map['carga_dispositivo'] ?? 0,
      estadoConexion: map['estado_conexion'] ?? false,
    );
  }
}
