import 'package:flutter/material.dart';
import 'contenedor_grande_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Solo un contenedor
  List contenedor = [
    ['Contenedores', Icons.view_comfy, ContenedorGrandeScreen()],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con fondo negro y texto amarillo
      appBar: AppBar(
        title: const Text(
          'HiveBot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.yellow, // Amarillo en el texto
          ),
        ),
        backgroundColor: Colors.black, // Fondo negro para el AppBar
        elevation: 0, // Sin sombra
        actions: [
          // Icono de notificaciones con color amarillo
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.yellow),
            onPressed: () {
              // Acción al presionar el icono de notificación
              print("Notificaciones presionadas");
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black, // Fondo negro para el cuerpo
        child: SafeArea(
          child: Column(
            children: [
              // Título o descripción breve en la parte superior con texto amarillo
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '¡Bienvenido a HiveBot!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.yellow, // Texto amarillo
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Colocar el banner para "Contenedor Grande"
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Banner para "Contenedor Grande"
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
                          color: Colors.yellow[700], // Amarillo oscuro
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

              // Espacio entre el banner y el footer
              Expanded(child: Container()),
            ],
          ),
        ),
      ),

      // Footer con iconos reorganizados: Inicio, Usuario, Configuración, Ayuda
      bottomNavigationBar: BottomAppBar(
        color: Colors.black, // Fondo negro para el footer
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribuye los íconos
            children: [
              // Icono de Inicio (ahora al principio)
              IconButton(
                icon: Icon(Icons.home, color: Colors.yellow),
                onPressed: () {
                  print("Inicio presionado");
                },
              ),
              
              // Icono de Usuario
              IconButton(
                icon: Icon(Icons.person, color: Colors.yellow),
                onPressed: () {
                  print("Usuario presionado");
                },
              ),

              // Icono de Configuración
              IconButton(
                icon: Icon(Icons.settings, color: Colors.yellow),
                onPressed: () {
                  print("Configuración presionada");
                },
              ),

              // Icono de Ayuda (ahora al final)
              IconButton(
                icon: Icon(Icons.help, color: Colors.yellow),
                onPressed: () {
                  print("Ayuda presionada");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
