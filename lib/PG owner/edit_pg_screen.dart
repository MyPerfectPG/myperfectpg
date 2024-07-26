import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myperfectpg/components/resuable.dart';

class EditPGScreen extends StatefulWidget {
  final String pgId;

  EditPGScreen({required this.pgId});

  @override
  _EditPGScreenState createState() => _EditPGScreenState();
}

class _EditPGScreenState extends State<EditPGScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();

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
  List<String> _imageUrls = [];
  List<File> _newImages = [];

  @override
  void initState() {
    super.initState();
    _loadPGDetails();
  }

  Future<void> _loadPGDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('pgs').doc(widget.pgId).get();
    setState(() {
      _nameController.text = doc['name'];
      _locationController.text = doc['location'];
      _landmarkController.text = doc['landmark'];
      _priceController.text = doc['price'].toString();
      _timeController.text = doc['time'];
      _summaryController.text = doc['summary'];
      _otherServiceController.text = doc['otherService'];
      _gender = doc['gender'];
      _sharing = doc['sharing'];
      _fooding = doc['fooding'];
      _elecbill = doc['elecbill'];
      _foodtype = doc['foodtype'];
      _furnishing = doc['furnishing'];
      _ac = doc['ac'];
      _cctv = doc['cctv'];
      _wifi = doc['wifi'];
      _parking = doc['parking'];
      _laundary = doc['laundary'];
      _profession = doc['profession'];
      _imageUrls = List<String>.from(doc['images']);
    });
  }

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
        _imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return _imageUrls;
    // Store the list of image URLs in Firestore
    await FirebaseFirestore.instance.collection('pg_owners').add({
      'imageUrls': _imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Images uploaded successfully!');
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> downloadUrls = [];
    for (File image in images) {
      String fileName = image.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child('pg_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image as File);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> _updatePG() async {
    try {
      List<String> newImageUrls = await _uploadImages(_newImages);
      List<String> finalImageUrls = _imageUrls + newImageUrls;
      await FirebaseFirestore.instance.collection('pgs')
          .doc(widget.pgId)
          .update({
        'images': finalImageUrls,
        'name': _nameController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'time': _timeController.text.trim(),
        'otherService': _otherServiceController.text.trim(),
        'location': _locationController.text.trim(),
        'summary': _summaryController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'gender': _gender,
        'sharing': _sharing,
        'fooding': _fooding,
        'elecbill': _elecbill,
        'foodtype': _foodtype,
        'furnishing': _furnishing,
        'ac': _ac,
        'cctv': _cctv,
        'wifi': _wifi,
        'parking': _parking,
        'laundary': _laundary,
        'profession': _profession,
      });
      Navigator.pop(context);
    }catch (e) {
      print('Failed to update PG: $e');
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    setState(() {
      _imageUrls.remove(imageUrl);
    });
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit PG',style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xff0094FF),),
      backgroundColor: Color(0xffF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Uploadimage(context, "Pick New Images", uploadMultipleImages),
              SizedBox(height: 10),
              Text('Current Images:', style: TextStyle(fontSize: 16)),
              Wrap(
                children: _imageUrls.map((imageUrl) {
                  return Stack(
                    children: [
                      Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteImage(imageUrl),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
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
              DropdownButtonFormField(value: _gender,items: <String>['Boys', 'Girls', 'Both']
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
              DropdownButtonFormField(value: _sharing,
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
              DropdownButtonFormField(value: _fooding,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _foodtype,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _ac,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _furnishing,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _cctv,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _wifi,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _parking,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _laundary,
                onChanged: (String? newValue) {
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
              DropdownButtonFormField(value: _profession,
                onChanged: (String? newValue) {
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
                onPressed: _updatePG,
                child: Text('Update PG'),
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
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side:  BorderSide(color: Color(0xff0094FF)),))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}