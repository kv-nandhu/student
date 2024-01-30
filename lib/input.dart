import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:student/database_helper.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  File? _selectedImage;
  final dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry📝'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _insertData(context);
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
          ),
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.deepOrange),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                          'Image not selected',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ))),
            ),
            Column(children: [
              IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: Icon(Icons.photo)),
              IconButton(
                  onPressed: () {
                    _photoImage();
                  },
                  icon: Icon(Icons.camera))
            ])
          ]),
        ],
      ),
    );
  }

  void _insertData(BuildContext context) async {
    final name = nameController.text;
    final age = int.tryParse(ageController.text) ?? 0;
    final address = addressController.text;

    if (name.isNotEmpty &&
        age > 0 &&
        address.isNotEmpty &&
        _selectedImage != null) {
      final imageFileName =
          'student_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile =
          File('${(await getTemporaryDirectory()).path}/$imageFileName');
      await _selectedImage!
          .copy(imageFile.path); 

      final row = {
        'name': name,
        'age': age,
        'address': address,
        'imagePath': imageFile.path,
      };
      dbHelper.insert(row).then((id) {
        setState(() {
          nameController.clear();
          ageController.clear();
          addressController.clear();
          _selectedImage = null;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Fill All Data, Including an Image'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _photoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
  
 
}



