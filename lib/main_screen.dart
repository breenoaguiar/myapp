// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'agenda_screen.dart';
import 'patients_screen.dart';
import 'materials_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AgendaScreen(),
    PatientsScreen(),
    MaterialsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color navBarBackground = Theme.of(
      context,
    ).colorScheme.surface.withOpacity(0.9); // Use surface color
    final Color selectedColor = Theme.of(context).colorScheme.primary; // Coral
    final Color unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.7); // Text color on surface

    return Scaffold(
      body: IndexedStack(
        // Use IndexedStack para manter o estado das telas
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
            ), // Icone mais apropriado para Dashboard
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard', // Label mais claro
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Materiais',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        backgroundColor: navBarBackground,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
