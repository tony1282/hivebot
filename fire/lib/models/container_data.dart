class ContainerData {
  final int distancia;
  final int cargaDispositivo;
  final bool estadoConexion;
  final double nivelGrande;   // Añadido para el nivel_grande
  final double nivelPequeno;  // Añadido para el nivel_pequeno

  ContainerData({
    required this.distancia,
    required this.cargaDispositivo,
    required this.estadoConexion,
    required this.nivelGrande,   // Añadido para el nivel_grande
    required this.nivelPequeno,  // Añadido para el nivel_pequeno
  });

  factory ContainerData.fromMap(Map<String, dynamic> map) {
    return ContainerData(
      distancia: map['distancia'] ?? 0,
      cargaDispositivo: map['carga_dispositivo'] ?? 0,
      estadoConexion: map['estado_conexion'] ?? false,
      nivelGrande: map['nivel_grande'] ?? 0.0,    // Obtener el nivel_grande
      nivelPequeno: map['nivel_pequeno'] ?? 0.0,  // Obtener el nivel_pequeno
    );
  }
}
