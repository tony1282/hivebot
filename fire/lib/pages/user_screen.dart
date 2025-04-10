import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _newPassword = '';
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Método para cargar los datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await _cloudFirestoreService.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _nombre = userData['nombre'] ?? '';
          _ciudad = userData['ciudad'] ?? '';
          _correo = user.email ?? '';
          _nombreController.text = _nombre;
          _ciudadController.text = _ciudad;
        });
      }
    }
  }

  // Método para actualizar los datos del usuario en Firestore y refrescar el estado local
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

        setState(() {
          _nombre = _nombreController.text;
          _ciudad = _ciudadController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos actualizados')),
        );
      } catch (e) {
        print("Error actualizando datos: $e");
      }
    }
  }

  // Método para desactivar la cuenta del usuario
  Future<void> _deactivateAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Solicitar re-autenticación antes de desactivar la cuenta
        await _reauthenticateUser(user);

        // Si la re-autenticación es exitosa, desactivamos la cuenta
        await _cloudFirestoreService.updateUserData(user.uid, {'estado': false});
        await user.delete();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al desactivar la cuenta: $e')),
        );
      }
    }
  }

  // Método para re-autenticar al usuario
  Future<void> _reauthenticateUser(User user) async {
    // Pedir al usuario su contraseña
    TextEditingController _passwordController = TextEditingController();
    
    // Mostrar un dialogo para que el usuario ingrese su contraseña
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Re-autenticación'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Contraseña actual'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                password = _passwordController.text;
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    // Re-autenticar con la contraseña proporcionada
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('No se pudo re-autenticar: $e');
    }
  }

  // Método para mostrar modal de edición de un dato
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

  // Método para mostrar una alerta de confirmación antes de desactivar la cuenta
  void _showDeactivationAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Desactivar cuenta',
            style: TextStyle(color: Colors.yellow),
          ),
          content: Text(
            '¿Estás seguro de que deseas desactivar tu cuenta? Esta acción no puede deshacerse.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar la alerta
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar la alerta
                _deactivateAccount(); // Desactivar cuenta
              },
              child: Text(
                'Desactivar',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
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
        title: const Text(
          'Perfil de Usuario',
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
            icon: const Icon(Icons.notifications, color: Colors.yellow),
            onPressed: () {
              print("Notificaciones presionadas");
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto de perfil
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  backgroundColor: Colors.grey[300],
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
                _buildDataRow('Contraseña', '********', Icons.lock, () {
                  _showEditModal(_passwordController, 'Editar Contraseña', () {
                    _newPassword = _passwordController.text;
                    _updateUserData();
                  });
                }),

                // BOTÓN PARA DESACTIVAR CUENTA
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showDeactivationAlert, // Mostrar alerta de desactivación
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text('Desactivar cuenta', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir cada fila con datos e ícono de edición
  Widget _buildDataRow(String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 18, color: Colors.white),
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
