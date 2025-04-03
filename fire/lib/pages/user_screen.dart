import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire/services/cloud_firestore_service.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final CloudFirestoreService _cloudFirestoreService = CloudFirestoreService();
  final _formKey = GlobalKey<FormState>();

  String _nombre = '';
  String _ciudad = '';
  String _correo = '';
  String _estado = '';
  String _newPassword = '';

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await _cloudFirestoreService.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _nombre = userData['nombre'] ?? '';
          _ciudad = userData['ciudad'] ?? '';
          _correo = user.email ?? '';
          _estado = 'Estado: ${userData['estado'] ?? 'N/A'}';
          _nombreController.text = _nombre;
          _ciudadController.text = _ciudad;
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _cloudFirestoreService.updateUserData(user.uid, {
          'nombre': _nombreController.text,
          'ciudad': _ciudadController.text,
        });

        if (_newPassword.isNotEmpty) {
          await user.updatePassword(_newPassword);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contraseña actualizada')),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos actualizados')),
        );
      } catch (e) {
        print("Error actualizando datos: $e");
      }
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _cloudFirestoreService.updateUserData(user.uid, {'estado': false});
      await user.delete();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Método para mostrar modal de edición
  void _showEditModal(TextEditingController controller, String title, Function() onSave) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.yellow)),
          backgroundColor: Colors.black,
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.yellow),
              filled: true,
              fillColor: Colors.white24,
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.yellow)),
            ),
            ElevatedButton(
              onPressed: () {
                onSave();
                Navigator.pop(context);
              },
              child: Text('Actualizar', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  ),
                ),
                SizedBox(height: 20),

                // FILAS CON DATOS E ICONOS
                _buildDataRow('Nombre', _nombre, Icons.edit, () {
                  _showEditModal(_nombreController, 'Editar Nombre', () {
                    _updateUserData();
                  });
                }),

                _buildDataRow('Ciudad', _ciudad, Icons.edit_location, () {
                  _showEditModal(_ciudadController, 'Editar Ciudad', () {
                    _updateUserData();
                  });
                }),

                _buildDataRow('Correo', _correo, Icons.email, () {}), // Sin edición

                _buildDataRow('Estado', _estado, Icons.info, () {}), // Sin edición

                _buildDataRow('Contraseña', '********', Icons.lock, () {
                  _showEditModal(_passwordController, 'Editar Contraseña', () {
                    _newPassword = _passwordController.text;
                    _updateUserData();
                  });
                }),

                // BOTÓN PARA ELIMINAR CUENTA
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    icon: Icon(Icons.delete, color: Colors.black),
                    label: Text('Eliminar cuenta', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir cada fila con datos e icono de edición
  Widget _buildDataRow(String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(icon, color: Colors.yellow),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
