import 'dart:io';
// ignore: unused_import
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:student/database_helper.dart';
import 'package:student/detail.dart';
import 'package:student/input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  final dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('STUDENT DETAILS 👨‍🎓'),actions: [
        IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: Icon(Icons.refresh),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search Students',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    // Clear the search field
                    searchController.clear();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.searchAll(searchController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        showtData(data[index], context);
                      },
                      leading: CircleAvatar(
                        backgroundImage: data[index]['imagePath'] != null
                            ? FileImage(File(data[index]['imagePath']))
                            : null,
                      ),
                      title: Text(data[index]['name']),
                      subtitle: Text('Age: ${data[index]['age']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editData(data[index], context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteDialog(data[index]['id'], context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this data?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteData(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int id) {
    dbHelper.delete(id).then((rowsDeleted) {
      if (rowsDeleted > 0) {
        setState(() {
          // Reload data after deletion
        });
      }
    });
  }

  void _editData(Map<String, dynamic> data, BuildContext context) {
    nameController.text = data['name'];
    ageController.text = data['age'].toString();
    addressController.text = data['address'];
    _selectedImage=File(data['imagePath']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
               Row(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                 
                  height: 100,
                  width: 100,
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
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateData(data['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateData(int id) {
    final name = nameController.text;
    final age = int.tryParse(ageController.text) ?? 0;
    final address = addressController.text;
    final imagepath=_selectedImage!.path;

    if (name.isNotEmpty && age > 0) {
      final row = {
        'id': id,
        'name': name,
        'age': age,
        'address': address,
        'imagepath':imagepath
      };
      dbHelper.update(row).then((rowsUpdated) {
        if (rowsUpdated > 0) {
          setState(() {
            nameController.clear();
            ageController.clear();
            addressController.clear();
           
          });
        }
      });
    }
  }


void showtData(Map<String, dynamic> data, BuildContext context) {
  var name = data['name'];
  var age = data['age'];
  var address = data['address'];
  var imagePath = data['imagePath'];

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DetailsPage(
        name: name,
        age: age,
        address: address,
        imagePath: imagePath,
      ),
    ),
  );
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
