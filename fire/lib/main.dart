import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fire/pages/inicio_sesion_usuario_screen.dart'; // Importa la pantalla de inicio de sesión

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Inicializar Firebase
  runApp(const MainApp());
  print('Conexión a Firebase establecida');
}



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InicioSesion(),  // Siempre se muestra la pantalla de inicio de sesión
    );
  }
}
