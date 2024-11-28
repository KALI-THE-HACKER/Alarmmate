import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AlarmProvider with ChangeNotifier {
  Map<int, String> _alarms = {};
  int _nextId = 2;
  late Box AlarmBox;

  AlarmProvider() {
    _loadAlarms();
  }

  Map<int, String> get alarms => _alarms;
  
  void _loadAlarms() async {
    AlarmBox = Hive.box('AlarmBox');
    _nextId = AlarmBox.get('_nextId', defaultValue: 2);
    final storedAlarms = AlarmBox.get('alarms', defaultValue: {});
    _alarms = Map<int, String>.from(storedAlarms);
    notifyListeners();
  }

  void addAlarm(String alarmTime) {
    _alarms[_nextId] = alarmTime;
    _nextId++;
    _saveAlarms();
    notifyListeners();
  }

  void deleteAlarm(int id) {
    _alarms.remove(id);
    _saveAlarms();
    notifyListeners();
  }

  void _saveAlarms() {
      AlarmBox.put('alarms', _alarms);
      AlarmBox.put('nextId', _nextId);
    }
}