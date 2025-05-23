import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/data/data_provider.dart';
import '../../core/trial/subject_trial.dart';
import '../../providers/config/subject_trial_notifier.dart';

class SubjectForm extends StatefulWidget {
  const SubjectForm({super.key});

  @override
  State<SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<SubjectForm> {
  static const List<String> genderOptions = <String>[
    "Select",
    "Male",
    "Female"
  ];

  static const List<String> dominantHandOptions = <String>[
    "Select",
    "Right-handed",
    "Left-handed",
    "Ambidextrous"
  ];

  final String genderDefault = genderOptions[0];
  final String dominantHandDefault = dominantHandOptions[0];

  bool _isSaving = false;

  SubjectTrial? _subject;
  String? _subjectGender;
  String? _subjectDominantHand;

  bool get _formVisible => (_subject != null);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightCmController = TextEditingController();
  final _weightKgController = TextEditingController();
  final _wristCircumferenceCmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightCmController.dispose();
    _weightKgController.dispose();
    _wristCircumferenceCmController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() ?? false;
  }

  bool get _hasFormChanged {
    return (_subject?.name != _nameController.text) ||
        (_subject?.age != int.tryParse(_ageController.text)) ||
        (_subject?.gender != _subjectGender) ||
        (_subject?.dominantHand != _subjectDominantHand) ||
        (_subject?.heightCm != int.tryParse(_heightCmController.text)) ||
        (_subject?.weightKg != double.tryParse(_weightKgController.text)) ||
        (_subject?.wristCircumferenceCm !=
            double.tryParse(_wristCircumferenceCmController.text));
  }

  bool get _canSave =>
      (!_isSaving && _formVisible && _isFormValid && _hasFormChanged);

  void _setSubject(SubjectTrial subject) {
    final subjectNotifier =
        Provider.of<SubjectTrialNotifier>(context, listen: false);
    setState(() {
      _subject = subject;
      _nameController.text = subject.name;
      _ageController.text = subject.age?.toString() ?? '';
      _subjectGender = subject.gender ?? genderDefault;
      _heightCmController.text = subject.heightCm?.toString() ?? '';
      _weightKgController.text = subject.weightKg?.toString() ?? '';
      _subjectDominantHand = subject.dominantHand ?? dominantHandDefault;
      _wristCircumferenceCmController.text =
          subject.wristCircumferenceCm?.toString() ?? '';
    });
    subjectNotifier.selectSubject(subject);
  }

  void _createNewSubject() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _setSubject(await dataProvider.createSubjectTrial(name: 'New Subject'));
  }

  Future<void> _getSubject() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final name = await _promptSubjectName(context);
    if (name == null || name.trim().isEmpty) return;
    final results = await dataProvider.searchSubjectsByName(name);
    if (!mounted) return;
    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects found.')),
      );
      return;
    }
    final SubjectTrial? selected = (results.length == 1)
        ? results.first
        : await _selectSubjectFromList(context, results);
    if (selected != null) {
      _setSubject(selected);
    }
  }

  Future<void> _saveSubject() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final subject = _subject!;
    subject
      ..name = _nameController.text
      ..age = int.tryParse(_ageController.text)
      ..gender = (_subjectGender != genderOptions[0]) ? _subjectGender : null
      ..dominantHand = (_subjectDominantHand != dominantHandOptions[0])
          ? _subjectDominantHand
          : null
      ..heightCm = int.tryParse(_heightCmController.text)
      ..weightKg = double.tryParse(_weightKgController.text)
      ..wristCircumferenceCm =
          double.tryParse(_wristCircumferenceCmController.text);

    await dataProvider.saveSubject(subject);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subject saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _formVisible
        ? Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _subject!.id,
                  decoration: const InputDecoration(
                    labelText: 'Subject ID',
                  ),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Invalid name.';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: "Age",
                    hintText: "Ex: 35",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return null;
                    final age = int.tryParse(value);
                    if (age == null || age < 18 || age > 99) {
                      return 'Invalid age; out of range (18-99).';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gender",
                    hintText: "Select",
                  ),
                  value: _subjectGender,
                  items: genderOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _subjectGender = value;
                    });
                  },
                  validator: (String? value) => null,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Dominant Hand",
                    hintText: "Select",
                  ),
                  value: _subjectDominantHand,
                  items: dominantHandOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _subjectDominantHand = value;
                    });
                  },
                  validator: (String? value) => null,
                ),
                TextFormField(
                  controller: _heightCmController,
                  decoration: InputDecoration(
                    labelText: "Height (cm.)",
                    hintText: "Ex: 175",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return null;
                    final height = int.tryParse(value);
                    if (height == null || height < 1 || height > 300) {
                      return 'Invalid height; out of range (1-300).';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                TextFormField(
                  controller: _weightKgController,
                  decoration: InputDecoration(
                    labelText: "Weight (Kg.)",
                    hintText: "Ex: 60.5",
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return null;
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30.0 || weight > 150.0) {
                      return 'Invalid weight; out of range (30.0-150.0).';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                TextFormField(
                  controller: _wristCircumferenceCmController,
                  decoration: InputDecoration(
                    labelText: "Wrist Circumference (cm.)",
                    hintText: "Ex: 17.5",
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return null;
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 10.0 || weight > 30.0) {
                      return 'Invalid wrist circumference; out of range (10.0-30.0).';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _canSave ? _saveSubject : null,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Provider.of<SubjectTrialNotifier>(context,
                                listen: false)
                            .clearSubject();
                        setState(() {
                          _subject = null;
                          _nameController.clear();
                          _ageController.clear();
                          _heightCmController.clear();
                          _weightKgController.clear();
                          _wristCircumferenceCmController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _getSubject,
                icon: const Icon(Icons.search),
                label: const Text('Get Existing Subject'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _createNewSubject,
                icon: const Icon(Icons.add),
                label: const Text('New Subject'),
              ),
            ],
          );
  }

  Future<String?> _promptSubjectName(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        void submit() => Navigator.of(context).pop(controller.text);
        return AlertDialog(
          title: const Text('Find Subject by name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Name'),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<SubjectTrial?> _selectSubjectFromList(
      BuildContext context, List<SubjectTrial> subjects) async {
    return showDialog<SubjectTrial>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Subject'),
        children: subjects
            .map(
              (subject) => SimpleDialogOption(
                child: Text('${subject.name} (ID: ${subject.id})'),
                onPressed: () => Navigator.pop(context, subject),
              ),
            )
            .toList(),
      ),
    );
  }
}
