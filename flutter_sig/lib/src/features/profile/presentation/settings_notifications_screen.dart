import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() => _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState extends State<SettingsNotificationsScreen> {
  bool _exitAlerts = true;
  bool _enterAlerts = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _exitAlerts = prefs.getBool('notifications_exit_alerts') ?? true;
      _enterAlerts = prefs.getBool('notifications_enter_alerts') ?? true;
      _soundEnabled = prefs.getBool('notifications_sound') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Alertas de salida de zona segura', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Recibir aviso cuando un hijo sale', style: TextStyle(fontSize: 12)),
                  value: _exitAlerts,
                  activeColor: const Color(0xFF1A237E),
                  onChanged: (val) {
                    setState(() => _exitAlerts = val);
                    _saveSetting('notifications_exit_alerts', val);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Alertas de entrada a zona segura', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Recibir aviso cuando un hijo entra', style: TextStyle(fontSize: 12)),
                  value: _enterAlerts,
                  activeColor: const Color(0xFF1A237E),
                  onChanged: (val) {
                    setState(() => _enterAlerts = val);
                    _saveSetting('notifications_enter_alerts', val);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Sonido y vibración', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Reproducir sonido en notificaciones', style: TextStyle(fontSize: 12)),
                  value: _soundEnabled,
                  activeColor: const Color(0xFF1A237E),
                  onChanged: (val) {
                    setState(() => _soundEnabled = val);
                    _saveSetting('notifications_sound', val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Notificaciones recientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
          ),
          const SizedBox(height: 16),
          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones recientes',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
