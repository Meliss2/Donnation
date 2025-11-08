import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile image
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              const SizedBox(height: 20),

              // Profile Card
              Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE57373), Color(0xFFEF5350)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Full Name",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Icon(Icons.edit, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Sarah Benali",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Sexe & Birth Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        InfoTile(title: "Sexe", value: "Female"),
                        InfoTile(title: "Birth Date", value: "22/08/2003"),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Email
                    const InfoTile(
                        title: "Email", value: "Sarah.benali@gmail.com"),
                    const SizedBox(height: 10),

                    // Phone
                    const InfoTile(title: "Phone", value: "05XX XX XX XX"),
                    const SizedBox(height: 10),

                    // Address
                    const InfoTile(title: "Address", value: "Algiers, Algeria"),
                    const SizedBox(height: 10),

                    // Blood Type
                    const InfoTile(title: "Blood Type", value: "A+"),
                    const SizedBox(height: 10),

                    // Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Row(
                          children: [
                            const Text(
                              "Available",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 5),
                            Switch(
                              value: true,
                              onChanged: (val) {},
                              activeColor: Colors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget reusable pour les infos
class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
