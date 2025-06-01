import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';

class ContactDetailsPage extends StatelessWidget {
  static const String routeName = 'details';
  final ContactModel contact;

  const ContactDetailsPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImage(),
          const SizedBox(height: 16),
          if (contact.name.isNotEmpty)
            _buildDetailRow(
              label: contact.name,
              icon: Icons.person,
              color: Colors.purple,
            ),
          if (contact.mobile.isNotEmpty)
            _buildDetailRow(
              label: contact.mobile,
              icon: Icons.phone,
              color: Colors.green,
              onTap: () => _launchUrl('tel:${contact.mobile}'),
            ),
          if (contact.email.isNotEmpty)
            _buildDetailRow(
              label: contact.email,
              icon: Icons.email,
              color: Colors.red,
              onTap: () => _launchUrl('mailto:${contact.email}'),
            ),
          if (contact.address.isNotEmpty)
            _buildDetailRow(
              label: contact.address,
              icon: Icons.location_on,
              color: Colors.purple,
              onTap: () => _launchUrl(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(contact.address)}',
              ),
            ),
          if (contact.website.isNotEmpty)
            _buildDetailRow(
              label: contact.website,
              icon: Icons.web,
              color: Colors.blue,
              onTap: () => _launchUrl(
                contact.website.startsWith('http')
                    ? contact.website
                    : 'https://${contact.website}',
              ),
            ),
          if (contact.company.isNotEmpty)
            _buildDetailRow(
              label: contact.company,
              icon: Icons.business,
              color: Colors.teal,
            ),
          if (contact.designation.isNotEmpty)
            _buildDetailRow(
              label: contact.designation,
              icon: Icons.work,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (contact.imageUrl.isNotEmpty) {
      return Image.network(
        contact.imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
    }
    return const Icon(Icons.person, size: 100, color: Colors.grey);
  }

  Widget _buildDetailRow({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // ignore silently if cannot launch
    }
  }
}
