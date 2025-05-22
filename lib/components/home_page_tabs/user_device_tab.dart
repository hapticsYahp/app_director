import 'package:flutter/material.dart';

import '../user_device_tab_forms/device_form.dart';

const List<String> genderOptions = <String>["Select", "Male", "Female"];

const List<String> dominantHandOptions = <String>[
  "Select",
  "Right-handed",
  "Left-handed",
  "Ambidextrous"
];

class UserDeviceTab extends StatefulWidget {
  const UserDeviceTab({super.key});

  @override
  State<UserDeviceTab> createState() => _UserDeviceTabState();
}

class _UserDeviceTabState extends State<UserDeviceTab> with AutomaticKeepAliveClientMixin {
  // User fields
  String? userId;
  int? userAge;
  String? userGender;
  String? userDominantHand;
  int? userHeightCm;
  double? userWeightKg;
  double? userWristCircumferenceCm;

  final String genderDefault = genderOptions[0];
  final String dominantHandDefault = dominantHandOptions[0];

  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _userAgeController = TextEditingController();
  final _userHeightCmController = TextEditingController();
  final _userWeightKgController = TextEditingController();
  final _userWristCircumferenceCmController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _userAgeController.dispose();
    _userHeightCmController.dispose();
    _userWeightKgController.dispose();
    _userWristCircumferenceCmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _userIdController.text = userId ?? '';
    _userAgeController.text = userAge?.toString() ?? '';
    userGender = userGender ?? genderDefault;
    userDominantHand = userDominantHand ?? dominantHandDefault;
    _userHeightCmController.text = userHeightCm?.toString() ?? '';
    _userWeightKgController.text = userWeightKg?.toString() ?? '';
    _userWristCircumferenceCmController.text =
        userWristCircumferenceCm?.toString() ?? '';
  }

  bool get _isUserFormValid {
    return _userFormKey.currentState?.validate() ?? false;
  }

  void _onSaveUser() {
    if (_isUserFormValid) {
      setState(() {
        userId = _userIdController.text;
        userAge = int.tryParse(_userAgeController.text);
        userHeightCm = int.tryParse(_userHeightCmController.text);
        userWeightKg = double.tryParse(_userWeightKgController.text);
        userWristCircumferenceCm =
            double.tryParse(_userWristCircumferenceCmController.text);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Device",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DeviceForm(),
            SizedBox(height: 24.0),

            // User form.
            Form(
              key: _userFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "User",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            labelText: "ID",
                            hintText: "Ex: john_doe",
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid ID.';
                            }
                            // TODO: check that the ID is unique.
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: _userAgeController,
                          decoration: InputDecoration(
                            labelText: "Age",
                            hintText: "Ex: 35",
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid age.';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 18 || age > 99) {
                              return 'Invalid age; out of range (18-99).';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Gender",
                            hintText: "Select",
                          ),
                          value: userGender,
                          items: genderOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              userGender = value;
                            });
                          },
                          validator: (String? value) {
                            if (value == null ||
                                value.isEmpty ||
                                (value == genderOptions[0])) {
                              return 'Please select.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Dominant Hand",
                            hintText: "Select",
                          ),
                          value: userDominantHand,
                          items: dominantHandOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              userDominantHand = value;
                            });
                          },
                          validator: (String? value) {
                            if (value == null ||
                                value.isEmpty ||
                                (value == dominantHandOptions[0])) {
                              return 'Please select.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userHeightCmController,
                          decoration: InputDecoration(
                            labelText: "Height (cm.)",
                            hintText: "Ex: 175",
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid height.';
                            }
                            final height = int.tryParse(value);
                            if (height == null || height < 1 || height > 300) {
                              return 'Invalid height; out of range (1-300).';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: _userWeightKgController,
                          decoration: InputDecoration(
                            labelText: "Weight (Kg.)",
                            hintText: "Ex: 60.5",
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid weight.';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null ||
                                weight < 30.0 ||
                                weight > 150.0) {
                              return 'Invalid weight; out of range (30.0-150.0).';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _userWristCircumferenceCmController,
                          decoration: InputDecoration(
                            labelText: "Wrist Circumference (cm.)",
                            hintText: "Ex: 17.5",
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid wrist circumference.';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null ||
                                weight < 10.0 ||
                                weight > 30.0) {
                              return 'Invalid wrist circumference; out of range (10.0-30.0).';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _onSaveUser,
                        child: Text("Save User"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
