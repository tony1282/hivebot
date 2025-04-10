import 'package:fire/pages/user_screen.dart'; // Importa la pantalla de perfil de usuario correctamente
import 'package:fire/pages/ayuda_screen.dart'; // Importa la pantalla de ayuda
import 'package:flutter/material.dart';
import 'package:fire/pages/contenedor_grande_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Solo un contenedor con un containerId específico
  List contenedor = [
    ['Contenedores', Icons.view_comfy, ContenedorGrandeScreen()], // Asegúrate de pasar un containerId válido
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HiveBot',
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
          child: Column(
            children: [
              const SizedBox(height: 50), // Espacio arriba del mensaje de bienvenida
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '¡Bienvenido a HiveBot!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.yellow,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40), // Espacio entre el texto y el contenedor
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => contenedor[0][2],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.yellow[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            contenedor[0][0],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.yellow),
                onPressed: () {
                  print("Inicio presionado");
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.yellow),
                onPressed: () {
                  // Navegar a la pantalla de perfil de usuario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsuarioScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.help, color: Colors.yellow),
                onPressed: () {
                  // Navegar a la pantalla de ayuda
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyudaScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
