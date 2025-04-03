import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire/services/cloud_firestore_service.dart';
import 'package:fire/models/big_container.dart';
import 'package:fire/models/container_data.dart'; // Asegúrate de que esta línea esté presente

class ContenedorGrandeScreen extends StatefulWidget {
  @override
  _ContenedorGrandeScreenState createState() => _ContenedorGrandeScreenState();
}

class _ContenedorGrandeScreenState extends State<ContenedorGrandeScreen> {
  final CloudFirestoreService _cloudFirestoreService = CloudFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contenedores',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: _buildContentWidget(),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return StreamBuilder<List<BigContainer>?>(  
      stream: _cloudFirestoreService.getBigContainers('contenedores'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay contenedores disponibles.', style: TextStyle(color: Colors.white)));
        }

        final containers = snapshot.data!;
        return ListView.builder(
          itemCount: containers.length,
          itemBuilder: (context, index) {
            final container = containers[index];
            return _buildContainerCard(container);
          },
        );
      },
    );
  }

  Widget _buildContainerCard(BigContainer container) {
    return Card(
      color: Colors.yellow[700],
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tamaño: ${container.tamano}', style: TextStyle(color: Colors.black)),
            Text('Capacidad: ${container.capacidad}', style: TextStyle(color: Colors.black)),
            Text('Forma: ${container.forma}', style: TextStyle(color: Colors.black)),
            Text('Material: ${container.material}', style: TextStyle(color: Colors.black)),
            Text('Consumo Energético: ${container.consumoEnergetico}W', style: TextStyle(color: Colors.black)),
            Text('Nivel de Alimento: ${container.nivelAlimento}%', style: TextStyle(color: Colors.black)),
            Text('Sensor Ultrasonico: ${container.sensorUltrasonico}', style: TextStyle(color: Colors.black)),
            Text('Estado de Conexión: ${container.estadoConexion ? '✅ Conectado' : '❌ Desconectado'}', style: TextStyle(color: Colors.black)),
            _buildRealtimeData(container.id),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    // Lógica para editar
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _cloudFirestoreService.deleteContainer('contenedores', container.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeData(String containerId) {
    return StreamBuilder<ContainerData?>(  
      stream: _cloudFirestoreService.getContainerData(containerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error en datos en tiempo real', style: TextStyle(color: Colors.white));
        }
        if (!snapshot.hasData) {
          return Text('Esperando datos...', style: TextStyle(color: Colors.white));
        }

        final realtimeData = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📏 Distancia: ${realtimeData.distancia} cm', style: TextStyle(color: Colors.black)),
            Text('🔋 Carga del Dispositivo: ${realtimeData.cargaDispositivo}%', style: TextStyle(color: Colors.black)),
            Text('🌐 Estado de Conexión: ${realtimeData.estadoConexion ? '✅ Conectado' : '❌ Desconectado'}', style: TextStyle(color: Colors.black)),
          ],
        );
      },
    );
  }
}
