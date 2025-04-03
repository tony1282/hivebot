import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  String _language = 'Español';
  int _foodQuantity = 5;
  String _feedingTime = '08:00';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'Español';
      _foodQuantity = prefs.getInt('foodQuantity') ?? 5;
      _feedingTime = prefs.getString('feedingTime') ?? '08:00';
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

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(_feedingTime.split(":")[0]),
      minute: int.parse(_feedingTime.split(":")[1]),
    );
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      setState(() {
        _feedingTime = '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
      });
      _updatePreference('feedingTime', _feedingTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text("Notificaciones"),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
              _updatePreference('notifications', value);
            },
          ),
          ListTile(
            title: Text("Idioma"),
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
              items: ["Español", "Inglés", "Francés"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text("Cantidad de comida a dispensar"),
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
              items: [1, 2, 3, 4, 5].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value unidades'),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text("Hora de alimentación"),
            trailing: Text(_feedingTime),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
    );
  }
}
