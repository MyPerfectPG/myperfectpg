import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:myperfectpg/components/resuable.dart';

class AddPGScreen extends StatefulWidget {
  @override
  _AddPGScreenState createState() => _AddPGScreenState();
}

class _AddPGScreenState extends State<AddPGScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  String _gender = 'Any';
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
      final ref = _storage.ref().child('photos').child(DateTime.now().toString());
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();
      setState(() {
        _images.add(url);
      });
    }
  }

  Future<void> _addPG() async {
    try {
      CollectionReference pgs = FirebaseFirestore.instance.collection('pgs');
      await pgs.add({
        'name': _nameController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'time': _timeController.text.trim(),
        'otherService': _otherServiceController.text.trim(),
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
        'location': _locationController.text.trim(),
        'summary': _summaryController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'images': [], // Add image URLs after uploading them to Firebase Storage
        'ownerId': user?.uid,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Failed to add PG: $e');
    }
  }

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
              Uploadimage(context, "Upload File", _pickImage),
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
              DropdownButtonFormField(/*value: _gender,*/items: <String>['Boys', 'Girls', 'Any']
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
