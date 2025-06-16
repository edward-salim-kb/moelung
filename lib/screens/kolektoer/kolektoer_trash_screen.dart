import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';

import 'dart:io'; // Import for File

class KolektoerTrashScreen extends StatefulWidget {
  final UserModel currentUser;

  const KolektoerTrashScreen({super.key, required this.currentUser});

  @override
  State<KolektoerTrashScreen> createState() => _KolektoerTrashScreenState();
}

class _KolektoerTrashScreenState extends State<KolektoerTrashScreen> {
  File? _imageFile;
  final TextEditingController _incidentController = TextEditingController();

  void _pickImage() {
    // Dummy implementation for image picking
    setState(() {
      _imageFile = File('lib/assets/trash.png'); // Placeholder image
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picked! (Dummy action)')),
    );
  }

  void _reportIncident() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incident reported: ${_incidentController.text} (Dummy action)')),
    );
    _incidentController.clear();
  }

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 1, // Assuming 1 is the index for trash
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Kolektoer Trash Input'),
          Expanded(
            child: SingleChildScrollView( // Added SingleChildScrollView
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.currentUser.name}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('This is where Kolektoer users can input trash details for other users.'),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'User Email/ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement logic to submit trash data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trash data submitted! (Dummy action)')),
                      );
                    },
                    child: const Text('Submit Trash Data'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Photo Evidence',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _imageFile == null
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                          alignment: Alignment.center,
                        )
                      : Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick Image'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Incident Reporting',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _incidentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Incident Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reportIncident,
                      icon: const Icon(Icons.report_problem),
                      label: const Text('Report Incident'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
