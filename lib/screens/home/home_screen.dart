import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../reports/reports_screen.dart';
import '../dashboard_screen.dart';
import '../reports_screen.dart';


class HomeScreen extends StatelessWidget {
  final UserType userType;

  const HomeScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userType == UserType.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Panel de Administrador' : 'Inicio'),
        backgroundColor: isAdmin ? Colors.indigo : Colors.blue,
      ),
      drawer: isAdmin ? _buildAdminDrawer(context) : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Hola, Administrador 👋' : 'Hola, Usuario 👋',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(context, Icons.money, "Préstamos", "Gestionar préstamos", Colors.green, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen(userType: UserType.admin)));
                  }),
                  _buildMenuCard(context, Icons.analytics, "Reportes", "Generar PDF", Colors.red, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  }),
                  if (isAdmin)
                    _buildMenuCard(context, Icons.people, "Clientes", "Gestión completa", Colors.orange, () {}),
                  if (isAdmin)
                    _buildMenuCard(context, Icons.settings, "Configuración", "Ajustes del sistema", Colors.purple, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 70, color: Colors.white),
                Text("Administrador", style: TextStyle(color: Colors.white, fontSize: 22)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text("Préstamos"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen(userType: UserType.admin,)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("Reportes"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar Sesión"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 32, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 40, color: color)),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}