import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/FarmerModel.dart';

class MyForm extends StatefulWidget {
  final FarmerModel farmerModel;

  const MyForm(this.farmerModel);

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _stateController = TextEditingController(text: 'Punjab');
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _tehsilController = TextEditingController();
  final TextEditingController _societyNameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _sourceOfIrrigationController = TextEditingController();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _farmerEducationController = TextEditingController();
  final TextEditingController _farmerAgeController = TextEditingController();
  final TextEditingController _farmerFatherNameController = TextEditingController();
  final TextEditingController _farmerMobilenoController = TextEditingController();
  final TextEditingController _farmerPincodeController = TextEditingController();
  final TextEditingController _ownedAreaController = TextEditingController();
  final TextEditingController _totalOperatedAreaController = TextEditingController();
  final TextEditingController _tubewellOrCanalController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  String? regionId, tehsilId,  blockId, societyNameId;
  final _formKey = GlobalKey<FormState>();
  bool? _isCooperativeMember;
  bool _consentGiven = false; // Track whether consent is given
  final List<String> _districts = ['Moga', 'Ludhiana', 'Other'];
  String? _selectedRegionId;
  late FarmerModel farmerModel;
  List<String> villageNames = [];
  List<String> societyNames = [];
  List<String> societyIds = [];


  @override
  void initState() {
    super.initState();
    farmerModel = widget.farmerModel;
    fetchRegionAndTehsilData();
    print("regionId data: ${farmerModel.blockId}");
  }

  void dispose() {
    _stateController.dispose();
    _dateController.dispose();
    _blockController.dispose();
    _tehsilController.dispose();
    _societyNameController.dispose();
    _villageController.dispose();
    _sourceOfIrrigationController.dispose();
    _farmerNameController.dispose();
    _farmerEducationController.dispose();
    _farmerAgeController.dispose();
    _farmerFatherNameController.dispose();
    _farmerMobilenoController.dispose();
    _farmerPincodeController.dispose();
    _ownedAreaController.dispose();
    _totalOperatedAreaController.dispose();
    _tubewellOrCanalController.dispose();
    _deviceIdController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> fetchRegionAndTehsilData() async {
    try {
      // Replace 'blocks' with the actual name of your block collection
      var blockCollection = FirebaseFirestore.instance.collectionGroup('blocks');

      // Query the block document using farmerModel.blockid
      var querySnapshot = await blockCollection
          .where('blockId', isEqualTo: farmerModel.blockId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var blockDoc = querySnapshot.docs.first;
        String blockName = blockDoc['blockName'];
        setState(() {
          regionId = blockDoc['regionId'];
          tehsilId = blockDoc['tehsilId'];
          blockId = blockDoc['blockId'];
          _blockController.text = blockName;
        });
        fetchDistrictName(regionId!);
        fetchTehsilName(tehsilId!);
        fetchSocietyNames(regionId!,tehsilId!,blockId!);
        print("regionId data: $regionId");
        print("tehsil data: $tehsilId");
      } else {
        print("regionId datatest: ${farmerModel.blockId}");
      }
    } catch (e) {
      print("Error fetching region and tehsil data: $e");
    }
  }

  void fetchDistrictName(String regionId) async {
    // Fetch the region document using the regionId
    DocumentSnapshot regionDoc = await FirebaseFirestore.instance
        .collection('regions')
        .doc(regionId)
        .get();

    // Check if the document exists and fetch the 'name' field
    if (regionDoc.exists) {
      String regionName = regionDoc['name'];
      setState(() {
        _districtController.text = regionName;
      });
    } else {
      print("Region not found");
    }
  }

  void fetchSocietyNames(String regionId, String tehsilId, String blockId) async {
    // Fetch all documents from the villageName collection
    QuerySnapshot societyNameSnapshot = await FirebaseFirestore.instance
        .collection('regions')
        .doc(regionId)
        .collection('tehsil')
        .doc(tehsilId)
        .collection('blocks')
        .doc(blockId)
        .collection('societies')
        .get();

    setState(() {
      societyNames = societyNameSnapshot.docs.map((doc) => doc['cooperativeSociety'] as String).toList();
      societyIds = societyNameSnapshot.docs.map((doc) => doc['societyId'] as String).toList();
    });
    // fetchVillage(regionId!,tehsilId!,blockId!,societyNameId!);
  }

  void fetchVillage(String regionId, String tehsilId, String blockId, String societyNameId,) async {
    // Fetch all documents from the villageName collection
    QuerySnapshot villageSnapshot = await FirebaseFirestore.instance
        .collection('regions')
        .doc(regionId)
        .collection('tehsil')
        .doc(tehsilId)
        .collection('blocks')
        .doc(blockId)
        .collection('societies')
        .doc(societyNameId)
        .collection('villages')
        .get();

    setState(() {
      villageNames = villageSnapshot.docs.map((doc) => doc['villageName'] as String).toList();
    });
  }

  void fetchTehsilName(String regionId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('tehsil')
        .where('tehsilId', isEqualTo: tehsilId)
        .get();

    // Check if any documents are found
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot tehsilDoc = querySnapshot.docs.first;
      String tehsilName = tehsilDoc['tehsilName'];
      setState(() {
        _tehsilController.text = tehsilName;
      });
    } else {
      print("tehsilName not found");
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Forms').add({
          'FieldCadre': farmerModel.farmerName,
          'State': _stateController.text,
          'district': _districtController.text,
          'Block': _blockController.text,
          'Tehsil': _tehsilController.text,
          'societyName': _societyNameController.text,
          'Village': _villageController.text,
          'sourceOfIrrigation': _sourceOfIrrigationController.text,
          'farmerName': _farmerNameController.text,
          'farmerEducation': _farmerEducationController.text,
          'farmerAge': _farmerAgeController.text,
          'Father': _farmerFatherNameController.text,
          'farmerMobileno': _farmerMobilenoController.text,
          'farmerPincode': _farmerPincodeController.text,
          'ownedArea': _ownedAreaController.text,
          'totalOperatedArea': _totalOperatedAreaController.text,
          'isCooperativeMember': _isCooperativeMember,
          // 'deviceId': _deviceIdController.text,
          // 'model': _modelController.text,
          // 'manufacturer': _manufacturerController.text,
          'createdOn': Timestamp.now(),
        });

        // Resetting form fields after successful submission
        _villageController.clear();
        _sourceOfIrrigationController.clear();
        _farmerNameController.clear();
        _farmerEducationController.clear();
        _farmerAgeController.clear();
        _farmerFatherNameController.clear();
        _farmerMobilenoController.clear();
        _farmerPincodeController.clear();
        _ownedAreaController.clear();
        _totalOperatedAreaController.clear();

        // Reset other form state variables
        setState(() {
          _isCooperativeMember = null;
          _consentGiven = false;
          villageNames.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Non Intensive Form',
          style: TextStyle(
            color: ThemeClass.colorPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // TextFormField(
                //   controller: _dateController,
                //   decoration: const InputDecoration(
                //     labelText: 'Date',
                //     suffixIcon: Icon(Icons.calendar_today),
                //   ),
                //   readOnly: true,
                //   onTap: () => _selectDate(context),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select Date';
                //     }
                //     return null;
                //   },
                // ),
                // const SizedBox(height: 16),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter State';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(labelText: 'District'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter District';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tehsilController,
                  decoration: const InputDecoration(labelText: 'Tehsil'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Tehsil';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _blockController,
                  decoration: const InputDecoration(labelText: 'Block'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Block';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Name of Cooperative Society'),
                  value: _societyNameController.text.isNotEmpty ? _societyNameController.text : null,
                  hint: const Text('Select Name of Cooperative Society'),
                  items: societyNames.map((String societyName) {
                    return DropdownMenuItem<String>(
                      value: societyName,
                      child: Text(societyName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _societyNameController.text = newValue!;

                      // Get the index of the selected society
                      int index = societyNames.indexOf(newValue);

                      // Use the corresponding societyId to fetch villages
                      if (index != -1) {
                        String selectedSocietyId = societyIds[index];
                        fetchVillage(regionId!, tehsilId!, blockId!, selectedSocietyId!);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Name of Cooperative Society';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Village'),
                  value: _villageController.text.isNotEmpty ? _villageController.text : null,
                  hint: const Text('Select Village'),
                  items: villageNames.map((String villageName) {
                    return DropdownMenuItem<String>(
                      value: villageName,
                      child: Text(villageName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _villageController.text = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Village';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _farmerNameController,
                  decoration: const InputDecoration(labelText: 'Farmer Name (Full Name)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Farmer Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _farmerEducationController,
                  decoration: const InputDecoration(labelText: 'Education'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Education';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _farmerAgeController,
                  decoration: const InputDecoration(labelText: 'Age of the Farmer'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Age';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _farmerMobilenoController,
                  decoration: const InputDecoration(labelText: 'Mobile no.'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Mobile no.';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _farmerFatherNameController,
                  decoration: const InputDecoration(labelText: 'Father/Husband Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Father Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Is the Farmer a member of cooperative?',
                      style: TextStyle(
                        fontSize: 16, // Increase the font size as needed
                        color: Colors.grey[700], // Set the color to a greyish tone
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0), // Adds padding above the Row
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _isCooperativeMember,
                            activeColor: ThemeClass.colorPrimary,
                            onChanged: (bool? value) {
                              setState(() {
                                _isCooperativeMember = value;
                              });
                            },
                          ),
                          Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 16, // Increase the font size
                              color: Colors.grey[700], // Greyish color similar to the label
                            ),
                          ),
                          Radio<bool>(
                            value: false,
                            groupValue: _isCooperativeMember,
                            activeColor: ThemeClass.colorPrimary,
                            onChanged: (bool? value) {
                              setState(() {
                                _isCooperativeMember = value;
                              });
                            },
                          ),
                          Text(
                            'No',
                            style: TextStyle(
                              fontSize: 16, // Increase the font size
                              color: Colors.grey[700], // Greyish color similar to the label
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 0),
                  ],
                ),
                TextFormField(
                  controller: _farmerPincodeController,
                  decoration: const InputDecoration(labelText: 'Pincode'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Pincode';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sourceOfIrrigationController,
                  decoration: const InputDecoration(labelText: 'Source Of Irrigation (Tubewell=1, Canal=2, both=3)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Source Of Irrigation';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownedAreaController,
                  decoration: const InputDecoration(labelText: 'Owned Area(in Acre)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Owned Area(Acre)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalOperatedAreaController,
                  decoration: const InputDecoration(labelText: 'Total Operated Area(in Acre) (Owned + Leased)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Total Operated Area(Acre)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 29.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _consentGiven,
                        activeColor: ThemeClass.colorPrimary,
                        onChanged: (bool? value) {
                          setState(() {
                            _consentGiven = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          "The above survey was completed by me in person with the consent of the respondents. I confirm that respondent(s) are above 18 years of age and I have obtained their consent to collect their personal data (including facial images) for processing under this programme. I have asked all questions and recorded the responses accurately without fear or influence.",
                          style: TextStyle(
                            fontSize: 14, // Adjust font size as needed
                            color: Colors.grey[700], // Greyish color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _consentGiven ? _submitData : null, // Enable only if consent is given
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
