import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'profil.dart';
import 'post_a_request.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pages correspondant aux boutons (sans placeholders vides)
  final List<Widget> _pages = [
    const HomePage(),
    FindDonorPage(),
    const SizedBox.shrink(), // pour le bouton "+" (ne sera jamais affiché)
    const SizedBox.shrink(), // pour notifications si tu veux
    const ProfilPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Bouton "+" ouvre PostRequestForm
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostRequestForm()),
      );
      return; // ne change pas _selectedIndex
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
