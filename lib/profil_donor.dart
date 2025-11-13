import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notifications.dart';

class DonorProfileSheet extends StatelessWidget {
  final Map<String, dynamic> donor;

  const DonorProfileSheet({Key? key, required this.donor}) : super(key: key);

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber == "0") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Numéro invalide')),
      );
      debugPrint('❌ Numéro invalide');
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      await launchUrl(callUri);
      debugPrint('📞 Lancement de l\'appel vers $phoneNumber');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Impossible de lancer l’appel vers $phoneNumber')),
      );
      debugPrint('❌ Impossible de lancer l\'appel vers $phoneNumber: $e');
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
              // Bouton Call
              ElevatedButton.icon(
                onPressed: () {
                  final phone = donor['phone'] ?? '0';
                  _makePhoneCall(context, phone); // ← Appel direct via téléphone
                },
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),

              // Bouton Request
              ElevatedButton.icon(
                icon: const Icon(Icons.bloodtype),
                label: const Text('Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
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
