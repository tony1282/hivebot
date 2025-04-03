import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  // Función para mostrar el modal de contacto
  void _mostrarModalSoporte(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contacto de Soporte',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email, color: Colors.black),
                title: Text('soporte@miapp.com'),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.black),
                title: Text('+1 234 567 8900'), // Número de teléfono de soporte
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
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

              _buildFAQItem(
                '¿Cómo cambiar mi contraseña?',
                'Para cambiar tu contraseña, ve a tu perfil, toca el icono de edición en "Contraseña" e ingresa una nueva contraseña.',
              ),
              _buildFAQItem(
                '¿Cómo actualizar mi perfil?',
                'Puedes actualizar tu perfil tocando los iconos de edición junto a tu nombre y ciudad en la sección de perfil.',
              ),
              _buildFAQItem(
                '¿Cómo solucionar problemas de inicio de sesión?',
                'Asegúrate de que tu correo y contraseña sean correctos. Si olvidaste la contraseña, puedes restablecerla en la pantalla de inicio de sesión.',
              ),

              SizedBox(height: 20),

              // Botón para abrir el modal de contacto
              Center(
                child: ElevatedButton(
                  onPressed: () => _mostrarModalSoporte(context),
                  child: Text('Contactar con Soporte', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para crear un ítem de Preguntas Frecuentes
  Widget _buildFAQItem(String question, String answer) {
    return Card(
      color: Colors.white12,
      child: ExpansionTile(
        title: Text(question, style: TextStyle(color: Colors.white)),
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(answer, style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
