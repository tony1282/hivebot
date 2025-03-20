import 'package:fire/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para guardar datos en Firestore
import 'package:fire/pages/inicio_sesion_usuario_screen.dart'; // Importa la pantalla de inicio de sesión

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  bool isSignUp = false; // Variable para alternar entre registro e inicio de sesión

  // Función para iniciar sesión
  Future<void> _signIn() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Si el inicio de sesión es exitoso, redirige a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomePage()),
        );
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      // Mostrar error si las credenciales son incorrectas
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
    }
  }

  // Función para registrar usuario
  Future<void> _register() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Si el registro es exitoso, guarda los datos adicionales en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
          'nombre_usuario': _nombreController.text,
          'estado': true, // El estado siempre está activo (true)
          'ciudad': _ciudadController.text,
          'correo_usuario': _emailController.text,
          'contrasena_usuario': _passwordController.text,
          'fecha_registro': Timestamp.now(),
        });

        // Después del registro, redirige de nuevo a la página de inicio de sesión
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioSesion()), // Regresa a la página de inicio de sesión
        );
      }
    } catch (e) {
      print('Error al registrar usuario: $e');
      // Mostrar error si algo falla en el registro
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar usuario: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centrar el título
        title: const Text(
          'Inicio de sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.yellow, // Amarillo en el texto
          ),
        ),
        backgroundColor: Colors.black, // Fondo negro para el AppBar
        elevation: 0, // Sin sombra
      ),
      body: Container(
        color: Colors.black, // Fondo negro para el cuerpo
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center( // Centrar el texto
                  child: const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isSignUp) ...[
                  // Campos para registro de usuario (sin el campo de estado)
                  TextField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white), // Color blanco para el texto
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.yellow), // Amarillo para el texto del label
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow), // Amarillo para el borde
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow), // Amarillo cuando está enfocado
                      ),
                    ),
                  ),
                  TextField(
                    controller: _ciudadController,
                    style: const TextStyle(color: Colors.white), // Color blanco para el texto
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      labelStyle: TextStyle(color: Colors.yellow),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                    ),
                  ),
                ],
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white), // Color blanco para el texto
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Colors.yellow),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white), // Color blanco para el texto
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.yellow),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSignUp ? _register : _signIn, // Ejecutar función según el estado (registro o inicio de sesión)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow, // Color de fondo amarillo
                    foregroundColor: Colors.black, // Color del texto negro
                  ),
                  child: Text(isSignUp ? 'Registrarse' : 'Iniciar sesión'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSignUp = !isSignUp; // Cambiar entre registro e inicio de sesión
                    });
                  },
                  child: Text(
                    isSignUp ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.yellow), // Texto amarillo
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
