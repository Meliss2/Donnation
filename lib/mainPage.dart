import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'profil.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    const HomePage(),
    FindDonorPage(),
    Container(), // Placeholder pour le bouton "+"
    Container(), // Placeholder pour notifications
    const ProfilPage(),
  ];

  void _onItemTapped(int index) {
    // Si c'est le bouton central "+" on peut ouvrir un modal ou page
    if (index == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Action"),
          content: const Text("Vous avez appuyé sur +"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
      return; // Ne change pas la page
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 2 ? _selectedIndex : _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
