import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class DocSending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Submission',
    );
  }
}

class DocumentSubmissionPage extends StatefulWidget {
  @override
  _DocumentSubmissionPageState createState() => _DocumentSubmissionPageState();
}

class _DocumentSubmissionPageState extends State<DocumentSubmissionPage> {
  List<PlatformFile>? _selectedFiles; // To store the selected documents

  // Function to select documents
  Future<void> _selectDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // Specify the file types you want to allow
        allowedExtensions: ['pdf', 'doc', 'docx'], // Example file types
        allowMultiple: true, // Allow multiple document selection
      );

      if (result != null) {
        for (var file in result.files) {
          // Generate a unique file name (e.g., using a timestamp)
          String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              file.name;
          // Reference to Firebase Cloud Storage
          final firebase_storage.Reference reference =
          firebase_storage.FirebaseStorage.instance.ref().child("riders")
          .child(fileName);

          // Upload the file to Firebase Cloud Storage
          await reference.putFile(File(file.path!));

          // Get the download URL of the uploaded file
          String downloadURL = await reference.getDownloadURL();

          // Display the download URL (you can save it to a database)
          print('Uploaded document URL: $downloadURL');
        }

        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      print('Error selecting and uploading documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Submission'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectDocuments,
              child: Text('Select Documents'),
            ),
            if (_selectedFiles != null)
              Column(
                children: [
                  Text('Selected Documents:'),
                  for (var file in _selectedFiles!)
                    Text(file.name),
                ],
              ),

          ],
        ),

      ),

    );
  }
}
