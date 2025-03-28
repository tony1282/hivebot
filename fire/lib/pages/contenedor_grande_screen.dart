import 'package:flutter/material.dart';
import 'package:fire/services/cloud_firestore_service.dart';
import 'package:fire/models/big_container.dart';

class ContenedorGrandeScreen extends StatefulWidget {
  @override
  _ContenedorGrandeScreenState createState() => _ContenedorGrandeScreenState();
}

class _ContenedorGrandeScreenState extends State<ContenedorGrandeScreen> {
  final CloudFirestoreService _cloudFirestoreService = CloudFirestoreService();

  // Variables para el formulario de agregar/editar
  final _formKey = GlobalKey<FormState>();
  String _tamano = '';
  int _capacidad = 0;
  String _forma = '';
  bool _estadoConexion = false;
  String _material = '';
  int _cargaDispositivo = 0;
  int _consumoEnergetico = 0;
  int _nivelAlimento = 0;

  // Función para eliminar un contenedor con confirmación
  void _deleteContainer(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Contenedor', style: TextStyle(color: Colors.yellow)),
          backgroundColor: Colors.black,
          content: Text('¿Estás seguro de que deseas eliminar este contenedor?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.yellow)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _cloudFirestoreService.deleteContainer('contenedores', id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el formulario de agregar/editar
  void _showForm({String? docId, BigContainer? container}) {
    if (container != null) {
      // Si estamos editando, precargamos los valores en el formulario
      _tamano = container.tamano;
      _capacidad = container.capacidad;
      _forma = container.forma;
      _estadoConexion = container.estadoConexion;
      _material = container.material;
      _cargaDispositivo = container.cargaDispositivo;
      _consumoEnergetico = container.consumoEnergetico;
      _nivelAlimento = container.nivelAlimento;
    } else {
      // Si estamos agregando, vaciamos los valores
      _tamano = '';
      _capacidad = 0;
      _forma = '';
      _estadoConexion = false;
      _material = '';
      _cargaDispositivo = 0;
      _consumoEnergetico = 0;
      _nivelAlimento = 0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Agregar Contenedor' : 'Editar Contenedor'),
          backgroundColor: Colors.black,
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _tamano,
                  decoration: InputDecoration(labelText: 'Tamaño', labelStyle: TextStyle(color: Colors.yellow)),
                  onSaved: (value) => _tamano = value!,
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _capacidad.toString(),
                  decoration: InputDecoration(labelText: 'Capacidad', labelStyle: TextStyle(color: Colors.yellow)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _capacidad = int.parse(value!),
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _forma,
                  decoration: InputDecoration(labelText: 'Forma', labelStyle: TextStyle(color: Colors.yellow)),
                  onSaved: (value) => _forma = value!,
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _material,
                  decoration: InputDecoration(labelText: 'Material', labelStyle: TextStyle(color: Colors.yellow)),
                  onSaved: (value) => _material = value!,
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _cargaDispositivo.toString(),
                  decoration: InputDecoration(labelText: 'Carga Dispositivo', labelStyle: TextStyle(color: Colors.yellow)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _cargaDispositivo = int.parse(value!),
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _consumoEnergetico.toString(),
                  decoration: InputDecoration(labelText: 'Consumo Energético', labelStyle: TextStyle(color: Colors.yellow)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _consumoEnergetico = int.parse(value!),
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: _nivelAlimento.toString(),
                  decoration: InputDecoration(labelText: 'Nivel de Alimento', labelStyle: TextStyle(color: Colors.yellow)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _nivelAlimento = int.parse(value!),
                  style: TextStyle(color: Colors.white),
                ),
                SwitchListTile(
                  title: Text('Estado de Conexión', style: TextStyle(color: Colors.yellow)),
                  value: _estadoConexion,
                  onChanged: (bool value) {
                    setState(() {
                      _estadoConexion = value;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text(docId == null ? 'Agregar' : 'Editar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed: () {
                    _formKey.currentState?.save();
                    Map<String, dynamic> data = {
                      'tamano': _tamano,
                      'capacidad': _capacidad,
                      'forma': _forma,
                      'estado_conexion': _estadoConexion,
                      'material': _material,
                      'carga_dispositivo': _cargaDispositivo,
                      'consumo_energetico': _consumoEnergetico,
                      'nivel_alimento': _nivelAlimento,
                    };

                    if (docId == null) {
                      // Si no hay docId, es un contenedor nuevo
                      _cloudFirestoreService.insertContainer('contenedores', data);
                    } else {
                      // Si hay docId, es un contenedor existente
                      _cloudFirestoreService.updateContainer('contenedores', docId, data);
                    }

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contenedores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.yellow,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.yellow),
            onPressed: () {
              print("Notificaciones presionadas");
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Lista de Contenedores Disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.yellow),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<BigContainer>>(
                  stream: _cloudFirestoreService.getBigContainers('contenedores'),
                  builder: (context, firestoreSnapshot) {
                    if (firestoreSnapshot.hasError) {
                      return Center(child: Text('Error: ${firestoreSnapshot.error}', style: TextStyle(color: Colors.white)));
                    }
                    if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.yellow));
                    }
                    if (!firestoreSnapshot.hasData || firestoreSnapshot.data!.isEmpty) {
                      return Center(child: Text('No hay contenedores disponibles.', style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      itemCount: firestoreSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final container = firestoreSnapshot.data![index];

                        // Obtener datos en tiempo real de la base de datos en tiempo real
                        return StreamBuilder<ContainerData>(
                          stream: _cloudFirestoreService.getContainerData(container.id), // Obtiene datos dinámicos de Realtime Database
                          builder: (context, realtimeSnapshot) {
                            if (realtimeSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: Colors.yellow));
                            }
                            if (realtimeSnapshot.hasError) {
                              return Center(child: Text('Error: ${realtimeSnapshot.error}', style: TextStyle(color: Colors.white)));
                            }

                            // Combinar los datos de Firestore y Realtime Database
                            final realtimeData = realtimeSnapshot.data;

                            return GestureDetector(
                              onTap: () {
                                print('Contenedor seleccionado: ${container.tamano}');
                              },
                              child: Card(
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
                                      Text('Carga de Dispositivo: ${container.cargaDispositivo}', style: TextStyle(color: Colors.black)),
                                      Text('Consumo Energético: ${container.consumoEnergetico}', style: TextStyle(color: Colors.black)),
                                      Text('Nivel de Alimento: ${container.nivelAlimento}', style: TextStyle(color: Colors.black)),
                                      Text('Estado de Conexión: ${container.estadoConexion ? 'Activo' : 'Inactivo'}', style: TextStyle(color: Colors.black)),
                                      if (realtimeData != null)
                                        Column(
                                          children: [
                                            Text('Distancia: ${realtimeData.distancia}', style: TextStyle(color: Colors.black)),
                                            Text('Carga Dispositivo: ${realtimeData.cargaDispositivo}', style: TextStyle(color: Colors.black)),
                                            Text('Estado Conexión: ${realtimeData.estadoConexion ? 'Activo' : 'Inactivo'}', style: TextStyle(color: Colors.black)),
                                          ],
                                        ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.black),
                                            onPressed: () {
                                              _showForm(docId: container.id, container: container);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteContainer(container.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
