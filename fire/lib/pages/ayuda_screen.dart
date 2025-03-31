import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayuda',
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
            padding: const EdgeInsets.all(20.0),
            children: [
              Text(
                'Bienvenido a la sección de Ayuda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellow),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Aquí podrás encontrar información sobre cómo usar la aplicación, solucionar problemas comunes y obtener asistencia si es necesario.',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Preguntas Frecuentes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.yellow),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text('¿Cómo cambiar mi contraseña?', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Aquí puedes agregar la lógica para navegar a una sección más detallada de la ayuda.
                  print("¿Cómo cambiar mi contraseña? seleccionado");
                },
              ),
              ListTile(
                title: Text('¿Cómo actualizar mi perfil?', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Lógica similar aquí para mostrar más información
                  print("¿Cómo actualizar mi perfil? seleccionado");
                },
              ),
              ListTile(
                title: Text('¿Cómo solucionar problemas de inicio de sesión?', style: TextStyle(color: Colors.white)),
                onTap: () {
                  print("¿Cómo solucionar problemas de inicio de sesión? seleccionado");
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Acción para contactar con soporte si lo necesitas
                  print("Contactar con soporte presionado");
                },
                child: Text('Contactar con Soporte'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
