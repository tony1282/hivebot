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
  bool _notificaciones = false;
  final TextEditingController _feedbackController = TextEditingController();

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
          _notificaciones = userData['notificaciones'] ?? false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta eliminada exitosamente')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificaciones = value;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _cloudFirestoreService.updateUserData(user.uid, {
        'notificaciones': _notificaciones,
      });
    }
  }

  Future<void> _sendFeedback() async {
    String feedback = _feedbackController.text;
    if (feedback.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gracias por tu feedback')),
      );
      _feedbackController.clear();
    }
  }

  Future<void> _showFeedbackDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Envíanos tu Feedback', style: TextStyle(color: Colors.yellow)),
          backgroundColor: Colors.black,
          content: TextField(
            controller: _feedbackController,
            decoration: InputDecoration(labelText: 'Escribe tu feedback', labelStyle: TextStyle(color: Colors.yellow)),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.yellow)),
            ),
            ElevatedButton(
              onPressed: () {
                _sendFeedback();
                Navigator.pop(context);
              },
              child: Text('Enviar Feedback', style: TextStyle(color: Colors.black)),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.yellow,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                  ),
                  SizedBox(height: 10),
                  Text(_nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.yellow)),
                  SizedBox(height: 10),
                  Text(_correo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  SizedBox(height: 10),
                  Text(_ciudad, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  SizedBox(height: 20),

                  SwitchListTile(
                    title: Text('Recibir notificaciones', style: TextStyle(color: Colors.yellow)),
                    value: _notificaciones,
                    onChanged: _toggleNotifications,
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _showFeedbackDialog,
                    child: Text('Enviar Feedback'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _deleteAccount,
                    child: Text('Eliminar Cuenta'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
