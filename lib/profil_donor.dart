import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notifications.dart';

class DonorProfileSheet extends StatelessWidget {
  final Map<String, dynamic> donor; // Infos dynamiques du donneur

  const DonorProfileSheet({Key? key, required this.donor}) : super(key: key);

  // 🔹 Fonction pour passer un appel avec vérification
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber == "0") {
      debugPrint('❌ Numéro invalide');
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint("❌ Impossible de lancer l'appel vers $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Barre de drag
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Photo du donneur
          CircleAvatar(
            radius: 50,
            backgroundImage: donor['image'] != null
                ? AssetImage(donor['image'])
                : const AssetImage('assets/default_avatar.png'),
          ),
          const SizedBox(height: 10),

          // Nom du donneur
          Text(
            donor['name'] ?? 'Unknown Donor',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),

          // Localisation et type sanguin
          Text(
            'Location: ${donor['location'] ?? 'Unknown'} • Blood Type: ${donor['blood'] ?? '--'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Boutons Call & Request
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // 📞 Lancer l'appel
                  final phone = donor['phone'] ?? '0';
                  _makePhoneCall(phone);
                },
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.bloodtype),
                label: const Text('Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  // 🔔 Ferme le modal et va à la page Notifications
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsPage(
                        receiverId: donor['id'] ?? 0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
