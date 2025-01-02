import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for utf8 encoding
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart'; // Import crypto package

void main() {
  runApp(const GravatarProfileApp());
}

class GravatarProfileApp extends StatelessWidget {
  const GravatarProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravatar Profile Card',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfileFormPage(),
    );
  }
}

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({Key? key}) : super(key: key);

  @override
  _ProfileFormPageState createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();

  Map<String, dynamic>? _profileData;

  // Function to fetch the Gravatar profile data
  Future<void> _fetchGravatarProfile(String email) async {
    final emailHash = md5Hash(email.trim().toLowerCase());
    final url = 'https://www.gravatar.com/$emailHash.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body)['entry'][0];
        });
      } else {
        setState(() {
          _profileData = null;
        });
      }
    } catch (e) {
      setState(() {
        _profileData = null;
      });
    }
  }

  // Function to calculate MD5 hash
  String md5Hash(String input) {
    var bytes = utf8.encode(input); // data being hashed
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  // Form submission function
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _fetchGravatarProfile(_emailController.text);
    }
  }

  // Widget to build the profile card
  Widget _buildProfileCard() {
    if (_profileData == null) return const SizedBox();

    final profileImage = _profileData?['thumbnailUrl'] ?? '';
    final gravatarName = _profileData?['displayName'] ?? _nameController.text;
    final gravatarLocation =
        _profileData?['currentLocation'] ?? _locationController.text;
    final gravatarBio = _profileData?['aboutMe'] ?? _bioController.text;

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : const AssetImage('assets/placeholder.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Name: $gravatarName', style: const TextStyle(fontSize: 18.0)),
            Text('Username: ${_usernameController.text}',
                style: const TextStyle(fontSize: 18.0)),
            Text('Location: $gravatarLocation',
                style: const TextStyle(fontSize: 18.0)),
            const Divider(),
            Text('Contact: ${_emailController.text}',
                style: const TextStyle(fontSize: 16.0)),
            Text('Phone: ${_phoneController.text}',
                style: const TextStyle(fontSize: 16.0)),
            const Divider(),
            Text('Bio: $gravatarBio', style: const TextStyle(fontSize: 16.0)),
            const Divider(),
            GestureDetector(
              onTap: () async {
                final url = _websiteController.text;
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                'Website: ${_websiteController.text}',
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gravatar Profile Card')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Email is required' : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextFormField(
                  controller: _websiteController,
                  decoration:
                      const InputDecoration(labelText: 'Website/Social URL'),
                ),
                TextFormField(
                  controller: _bioController,
                  decoration:
                      const InputDecoration(labelText: 'Bio/Short Description'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 20.0),
                _buildProfileCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
