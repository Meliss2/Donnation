import 'mainPage.dart';
import 'package:flutter/material.dart';
import 'profil_donor.dart';
import 'package:Donnation/database_helper.dart';


class FindDonorPage extends StatefulWidget {
  const FindDonorPage({super.key});

  @override
  State<FindDonorPage> createState() => _FindDonorPageState();
}
  final List<Map<String, String>> donors = [
    {
      'name': 'Sarah Benali',
      'location': 'Algiers, Algeria',
      'blood': 'A+',
      'image': 'assets/profile.png',
      'phone': '0661112233'
    },
    {
      'name': 'Yucef Rezgui',
      'location': 'Tizi Ouzou, Algeria',
      'blood': 'B+',
      'image': 'assets/yucef.png',
      'phone': '+213661112233'
    },
    {
      'name': 'Ramy Ghoumari',
      'location': 'Medea, Algeria',
      'blood': 'A-',
      'image': 'assets/ramy.png',
      'phone': '+213661112233'
    },
    {
      'name': 'Mahdi Cheurfa',
      'location': 'Bejaia, Algeria',
      'blood': 'AB+',
      'image': 'assets/amine.png',
      'phone': '+213661112233'
    },
    {
      'name': 'Islam Benali',
      'location': 'Algiers, Algeria',
      'blood': 'O+',
      'image': 'assets/mohamed.png',
      'phone': '+213661112233'
    },
  ];
class _FindDonorPageState extends State<FindDonorPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _search(); // Charger la liste au démarrage
  }

  Future<void> _search() async {
    final query = searchController.text.trim();
    final results = await DatabaseHelper.instance.searchUsers(query);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          },
        ),
        title: const Text(
          'Find Donor/Receiver',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search a Donator...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 📋 Liste des donneurs
            Expanded(
              child: ListView.builder(
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final donor = donors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(donor['image']!),
                        radius: 25,
                      ),
                      title: Text(
                        donor['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(donor['location']!),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(donor['phone'] ?? 'N/A'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donor['blood']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => DonorProfileSheet(donor: donor),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
