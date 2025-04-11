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

  Future<void> _deactivateAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _reauthenticateUser(user);
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

  Future<void> _reauthenticateUser(User user) async {
    TextEditingController _passwordController = TextEditingController();
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Re-autenticación'),
          content: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña actual'),
            ),
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

  void _showEditModal(TextEditingController controller, String title, Function() onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.yellow),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
                autofocus: true,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: TextStyle(color: Colors.yellow)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      onSave();
                      Navigator.pop(context);
                    },
                    child: Text('Actualizar', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeactivationAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Desactivar cuenta', style: TextStyle(color: Colors.yellow)),
          content: Text(
            '¿Estás seguro de que deseas desactivar tu cuenta? Esta acción no puede deshacerse.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.yellow)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deactivateAccount();
              },
              child: Text('Desactivar', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
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
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(height: 20),
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
                _buildDataRow('Correo', _correo, Icons.email, () {}),
                _buildDataRow('Contraseña', '********', Icons.lock, () {
                  _showEditModal(_passwordController, 'Editar Contraseña', () {
                    _newPassword = _passwordController.text;
                    _updateUserData();
                  });
                }),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showDeactivationAlert,
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