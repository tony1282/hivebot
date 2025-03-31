import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'Español';
  int _foodQuantity = 5;  // Configuración para la cantidad de comida
  String _feedingTime = '08:00';  // Configuración para la hora del dispensador

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'Español';
      _foodQuantity = prefs.getInt('foodQuantity') ?? 5;  // Cargar cantidad de comida
      _feedingTime = prefs.getString('feedingTime') ?? '08:00';  // Cargar hora de dispensado
    });
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  // Método para mostrar el selector de hora
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(hour: int.parse(_feedingTime.split(":")[0]), minute: int.parse(_feedingTime.split(":")[1]));
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      setState(() {
        _feedingTime = '${selectedTime.hour}:${selectedTime.minute}';
      });
      _updatePreference('feedingTime', _feedingTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración", style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Configuración para el modo oscuro
            SwitchListTile(
              title: Text("Modo oscuro", style: TextStyle(color: Colors.yellow)),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                });
                _updatePreference('darkMode', value);
              },
            ),
            
            // Configuración para notificaciones
            SwitchListTile(
              title: Text("Notificaciones", style: TextStyle(color: Colors.yellow)),
              value: _notifications,
              onChanged: (bool value) {
                setState(() {
                  _notifications = value;
                });
                _updatePreference('notifications', value);
              },
            ),
            
            // Configuración para el idioma
            ListTile(
              title: Text("Idioma", style: TextStyle(color: Colors.yellow)),
              trailing: DropdownButton<String>(
                value: _language,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _language = newValue;
                    });
                    _updatePreference('language', newValue);
                  }
                },
                items: ["Español", "Inglés", "Francés"].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            ),
            
            // Configuración para la cantidad de comida
            ListTile(
              title: Text("Cantidad de comida a dispensar", style: TextStyle(color: Colors.yellow)),
              trailing: DropdownButton<int>(
                value: _foodQuantity,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _foodQuantity = newValue;
                    });
                    _updatePreference('foodQuantity', newValue);
                  }
                },
                items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value unidades', style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            ),
            
            // Configuración para la hora de alimentación
            ListTile(
              title: Text("Hora de alimentación", style: TextStyle(color: Colors.yellow)),
              trailing: Text(_feedingTime, style: TextStyle(color: Colors.white)),
              onTap: () => _selectTime(context),
            ),
          ],
        ),
      ),
    );
  }
}
