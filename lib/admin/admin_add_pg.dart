import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/resuable.dart';

class AddPGScreenAdmin extends StatefulWidget {

  final String pgId;
  AddPGScreenAdmin({required this.pgId});

  @override
  State<AddPGScreenAdmin> createState() => _AddPGScreenAdminState();
}

class _AddPGScreenAdminState extends State<AddPGScreenAdmin> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _landmarkController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  final TextEditingController _summaryController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _otherServiceController = TextEditingController();

  final _storage = FirebaseStorage.instance;

  final _picker = ImagePicker();

  String _gender = 'Both';

  String _sharing = 'Single';

  String _fooding = 'Not Included';

  String _elecbill = 'Not Included';

  String _foodtype = 'Both';

  String _furnishing = 'Unfurnished';

  String _ac = 'Not Available';

  String _cctv = 'Not Available';

  String _wifi = 'Not Available';

  String _parking = 'Not Available';

  String _laundary = 'Not Available';

  String _profession = 'Student';

  List<String> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile.path);
      });
    }
  }

  /*Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (String imagePath in _images) {
      try {
        print('Attempting to upload file: $imagePath');
        File file = File(imagePath);

        // Check if the file exists
        if (await file.exists()) {
          final ref = _storage.ref().child('photos').child(DateTime.now().toString());
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask.whenComplete(() {});
          final url = await snapshot.ref.getDownloadURL();
          imageUrls.add(url);
          print('Successfully uploaded file: $url');
        } else {
          print('File does not exist: $imagePath');
        }
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }
    return imageUrls;
  }*/
  List<String> imageUrls = [];

  Future<List<String>> uploadMultipleImages() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images == null || images.isEmpty) {
      print('No images selected.');
      // return;
    }



    for (XFile image in images!) {
      File imageFile = File(image.path);

      try {
        // Create a unique file name for each image
        String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

        // Upload the image to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref(fileName)
            .putFile(imageFile);

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the download URL in a list
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
    // Store the list of image URLs in Firestore
    /*await FirebaseFirestore.instance.collection('pg_owners').add({
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });*/

    print('Images uploaded successfully!');
  }

  String? uid;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  /*@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFieldData();
  }
  String? oid;
  void fetchFieldData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('pg_owners')
          .doc('owner id')
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          oid = documentSnapshot.get('owner id');
        });
      } else {
        setState(() {
          oid = 'Document does not exist';
        });
      }
    } catch (e) {
      setState(() {
        oid = 'Error fetching data: $e';
      });
    }
  }
*/
  Future<void> _addPG() async {
    try {
      CollectionReference pgs = FirebaseFirestore.instance.collection('pgs');
      await pgs.add({
        'name': _nameController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'time': _timeController.text.trim(),
        'otherService': _otherServiceController.text.trim(),
        'gender': _gender ?? '',
        'sharing': _sharing ?? '',
        'fooding': _fooding ?? '',
        'elecbill': _elecbill ?? '',
        'foodtype': _foodtype ?? '',
        'furnishing': _furnishing ?? '',
        'ac': _ac ?? false,
        'cctv': _cctv ?? false,
        'wifi': _wifi ?? false,
        'parking': _parking ?? false,
        'laundary': _laundary ?? false,
        'profession': _profession ?? '',
        'location': _locationController.text.trim(),
        'summary': _summaryController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'images': imageUrls,
        'ownerId': widget.pgId,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Failed to add PG: $e');
    }
  }

  /*String? uid;
  Map<String, dynamic>? pgOwnerData;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
      fetchPgOwnerData(user.uid);
    }
  }

  void fetchPgOwnerData(String uid) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('pg_owners')
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {
      setState(() {
        pgOwnerData = documentSnapshot.data() as Map<String, dynamic>?;
      });
      //print(pgOwnerData);
    } else {
      print('Document does not exist');
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Add PG')),
      backgroundColor: Color(0xffF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Uploadimage(context, "Upload File", uploadMultipleImages),
              SizedBox(height: 20,),
              DataTextField('PG Name', Icons.home_outlined, false, _nameController),
              SizedBox(height: 10,),
              DataTextField('Location', Icons.location_city_outlined, false, _locationController),
              SizedBox(height: 10,),
              DataTextField('Landmark', Icons.pin_drop_outlined, false, _landmarkController),
              SizedBox(height: 10,),
              DataTextField('Time', Icons.timelapse_outlined, false, _timeController),
              SizedBox(height: 10,),
              DataTextField('Summary', Icons.summarize_outlined, false, _summaryController),
              SizedBox(height: 10,),
              DataTextField('Other Services', Icons.home_repair_service_outlined, false, _otherServiceController),
              SizedBox(height: 10,),
              DataTextField('Price', Icons.currency_rupee_outlined, false, _priceController),
              SizedBox(height: 10,),
              DropdownButtonFormField(/*value: _gender,*/items: <String>['Boys', 'Girls', 'Both']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,),
                );
              }).toList(), onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },decoration: InputDecoration(
                hintText: "Gender",
                filled: true,
                fillColor: Color(0xffF7F7F7),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
              ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(
                onChanged: (String? newValue) {
                  setState(() {
                    _sharing = newValue!;
                  });
                },
                items: <String>['Single', 'Double', 'Triple']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                hintText: "Sharing",
                filled: true,
                fillColor: Color(0xffF7F7F7),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
              ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _fooding = newValue!;
                });
              },
                items: <String>['Included', 'Not Included']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Fooding",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _foodtype = newValue!;
                });
              },
                items: <String>['Veg', 'Non-Veg','No','Both']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Food Type",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _ac = newValue!;
                });
              },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "AC",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _furnishing = newValue!;
                });
              },
                items: <String>['Unfurnished', 'Semi-Furnished','Furnished']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Furnishing",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _cctv = newValue!;
                });
              },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "CCTV",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _wifi = newValue!;
                });
              },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Wifi",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _parking = newValue!;
                });
              },
                items: <String>['Available','Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Parking",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _laundary = newValue!;
                });
              },
                items: <String>['Available', 'Not Available']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Laundary",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              DropdownButtonFormField(onChanged: (String? newValue) {
                setState(() {
                  _profession = newValue!;
                });
              },
                items: <String>['Student', 'Working Profession','Both']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),decoration: InputDecoration(
                  hintText: "Profession",
                  filled: true,
                  fillColor: Color(0xffF7F7F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: _addPG,
                child: Text('Add PG'),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white;
                      }
                      return Color(0xff0094FF);
                    }),
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xff0094FF);
                      }
                      return Colors.white;
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side: BorderSide(color: Color(0xff0094FF)),))),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
