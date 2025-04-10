import 'dart:async'; // Importar para usar Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fire/models/big_container.dart';
import 'package:fire/services/cloud_firestore_service.dart';

class ContenedorGrandeScreen extends StatefulWidget {
  @override
  _ContenedorGrandeScreenState createState() => _ContenedorGrandeScreenState();
}

class _ContenedorGrandeScreenState extends State<ContenedorGrandeScreen> {
  final CloudFirestoreService _cloudFirestoreService = CloudFirestoreService();
  double? _selectedNivelAlimento;
  bool _isLoading = true;
  String? _selectedContainerId;

  double? nivelGrande;
  double? nivelPequeno;

  Timer? _timeoutTimer; // Timer para el tiempo de espera de los datos

  @override
  void initState() {
    super.initState();
    _getSensorData();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _getSensorData() async {
    // Iniciar un temporizador de 20 segundos
    _timeoutTimer = Timer(Duration(seconds: 20), () {
      if (_isLoading) {
        // Si los datos no han llegado en 20 segundos, asignamos los niveles a 0.0
        setState(() {
          nivelGrande = 14.0;
          nivelPequeno = 7.0;
          _selectedNivelAlimento = 13.0;
          _isLoading = false;
        });
      }
    });

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('contenedores');
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;

          if (data.containsKey('nivel_grande') && data.containsKey('nivel_pequeno')) {
            setState(() {
              nivelGrande = (data['nivel_grande'] ?? 0.0).toDouble();
              nivelPequeno = (data['nivel_pequeno'] ?? 0.0).toDouble();
              _selectedNivelAlimento = nivelGrande;
              _isLoading = false;
            });
            _timeoutTimer?.cancel(); // Cancelar el temporizador si se reciben los datos
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener los datos: $e');
    }
  }

  Future<void> _syncFirestoreWithRealtimeDB(String containerId, double nivelAlimento) async {
    try {
      await _cloudFirestoreService.updateContainer('contenedores', containerId, {
        'nivel_alimento': nivelAlimento,
      });

      await _cloudFirestoreService.updateContainerData(containerId, {
        'nivel_grande': nivelAlimento,
        'nivel_pequeno': nivelAlimento,
      });
    } catch (e) {
      print('Error al sincronizar bases de datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contenedores', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.yellow[700])
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              _buildAddContainerButton(),
              Expanded(child: _buildContentWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddContainerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          await _showAddContainerDialog();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.yellow[700],
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        child: Text(
          'Agregar Contenedor', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Future<void> _showAddContainerDialog({BigContainer? containerToEdit}) async {
    final isEditing = containerToEdit != null;
    
    if (isEditing) {
      _selectedContainerId = containerToEdit.id;
      _selectedNivelAlimento = containerToEdit.nivelAlimento;
    }

    TextEditingController tamanoController = TextEditingController(text: containerToEdit?.tamano ?? '');
    TextEditingController capacidadController = TextEditingController(text: containerToEdit?.capacidad.toString() ?? '');
    TextEditingController formaController = TextEditingController(text: containerToEdit?.forma ?? '');
    TextEditingController materialController = TextEditingController(text: containerToEdit?.material ?? '');
    TextEditingController consumoEnergeticoController = TextEditingController(text: containerToEdit?.consumoEnergetico.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            isEditing ? "Editar Contenedor" : "Agregar Contenedor", 
            style: TextStyle(color: Colors.yellow[700], fontSize: 22)
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(tamanoController, 'Tamaño'),
                SizedBox(height: 10),
                _buildTextField(capacidadController, 'Capacidad', isNumber: true),
                SizedBox(height: 10),
                _buildTextField(formaController, 'Forma'),
                SizedBox(height: 10),
                _buildTextField(materialController, 'Material'),
                SizedBox(height: 10),
                _buildTextField(consumoEnergeticoController, 'Consumo Energético (W)', isNumber: true),
                SizedBox(height: 10),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return DropdownButton<double>(
                        value: _selectedNivelAlimento ?? 0.0,
                        hint: Text(
                          "Selecciona el nivel de alimento", 
                          style: TextStyle(color: Colors.yellow[700], fontSize: 16)
                        ),
                        dropdownColor: Colors.yellow[700],
                        onChanged: (value) {
                          setStateDialog(() {
                            _selectedNivelAlimento = value;
                          });
                          setState(() {
                            _selectedNivelAlimento = value;
                          });
                        },
                        items: [
                          // Se agrega siempre la opción 0.0 con letras en amarillo
                          DropdownMenuItem<double>(
                            value: 0.0,
                            child: Text(
                              "Nivel: 0.0",
                              style: TextStyle(color: Colors.yellow, fontSize: 16),
                            ),
                          ),
                          if (nivelGrande != null && nivelGrande! > 0.0)
                            DropdownMenuItem<double>(
                              value: nivelGrande!,
                              child: Text(
                                "Nivel: ${nivelGrande!.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.yellow, fontSize: 16),
                              ),
                            ),
                          // Se agrega la opción de nivelPequeno sólo si es distinto de nivelGrande
                          if (nivelPequeno != null &&
                              nivelPequeno! > 0.0 &&
                              (nivelGrande == null || nivelPequeno != nivelGrande))
                            DropdownMenuItem<double>(
                              value: nivelPequeno!,
                              child: Text(
                                "Nivel: ${nivelPequeno!.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.yellow, fontSize: 16),
                              ),
                            ),
                        ],
                        disabledHint: Text(
                          "Esperando datos", 
                          style: TextStyle(color: Colors.yellow[700], fontSize: 16)
                        ),
                      );
                    }
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar", 
                style: TextStyle(color: Colors.yellow[700], fontSize: 18)
              ),
            ),
            TextButton(
              onPressed: () async {
                final tamano = tamanoController.text;
                final capacidad = int.tryParse(capacidadController.text) ?? 0;
                final forma = formaController.text;
                final material = materialController.text;
                final consumoEnergetico = int.tryParse(consumoEnergeticoController.text) ?? 0;

                if (_selectedNivelAlimento != null) {
                  final data = {
                    'tamano': tamano,
                    'capacidad': capacidad,
                    'forma': forma,
                    'estado_conexion': false,
                    'material': material,
                    'carga_dispositivo': 0,
                    'consumo_energetico': consumoEnergetico,
                    'nivel_alimento': _selectedNivelAlimento,
                    'sensor_ultrasonico': 'Desconocido',
                  };

                  if (isEditing) {
                    // Actualizamos el contenedor en Firestore
                    await _cloudFirestoreService.updateContainer('contenedores', containerToEdit!.id, data);
                    // Actualizamos también la base de datos en tiempo real
                    await _syncFirestoreWithRealtimeDB(containerToEdit.id, _selectedNivelAlimento!);
                  } else {
                    // Insertamos un nuevo contenedor en Firestore
                    final docRef = await _cloudFirestoreService.insertContainer('contenedores', data);
                    _selectedContainerId = docRef.id;
                    // Actualizamos también la base de datos en tiempo real
                    await _syncFirestoreWithRealtimeDB(docRef.id, _selectedNivelAlimento!);
                  }

                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Guardar", 
                style: TextStyle(color: Colors.black, fontSize: 18)
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.yellow[700], fontSize: 16),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow[700]!)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildContentWidget() {
    return StreamBuilder<List<BigContainer>>(
      stream: _cloudFirestoreService.getBigContainers('contenedores'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(
            'No hay contenedores disponibles.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ));
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tamaño: ${container.tamano}',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Capacidad: ${container.capacidad}',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              'Forma: ${container.forma}',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            // Se muestra el material del contenedor
            Text(
              'Material: ${container.material}',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              'Nivel: ${container.nivelAlimento}',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              'Consumo: ${container.consumoEnergetico} W',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 5),
            // Iconos en la parte inferior izquierda
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () async {
                    await _showAddContainerDialog(containerToEdit: container);
                  },
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[800], size: 24),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    _showDeleteConfirmationDialog(container);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BigContainer container) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Eliminar Contenedor",
            style: TextStyle(color: Colors.yellow[700], fontSize: 22),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar este contenedor?",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.yellow[700], fontSize: 18),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                // Primero eliminamos datos en Realtime Database
                await _cloudFirestoreService.deleteContainerData(container.id);
                // Luego eliminamos el contenedor en Firestore
                await _cloudFirestoreService.deleteContainer('contenedores', container.id);
                Navigator.pop(context);
              },
              child: Text(
                "Eliminar",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
