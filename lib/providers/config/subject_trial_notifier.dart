import 'package:flutter/material.dart';
import '../../core/trial/subject_trial.dart';

class SubjectTrialNotifier extends ChangeNotifier {
  SubjectTrial? _selectedSubject;

  SubjectTrial? get selectedSubject => _selectedSubject;

  void selectSubject(SubjectTrial subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void clearSubject() {
    _selectedSubject = null;
    notifyListeners();
  }
}
