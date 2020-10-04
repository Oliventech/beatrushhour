import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  static final _SettingsPageState listRef = new _SettingsPageState._internal();

  factory _SettingsPageState() {
    return listRef;
  }

  _SettingsPageState._internal();

  int timeThreshold = 0;

  List timeSelectedList = [];

  Future<void> showNumberPicker() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Notify when the time is less than'),
            content: CupertinoPicker.builder(
              childCount: 1440,
              itemExtent: 80,
              onSelectedItemChanged: (value) {
                timeThreshold = value;
              },
              itemBuilder: (context, pickerIndex) {
                return Align(
                  alignment: Alignment.center,
                  child: Text('$pickerIndex minutes'),
                );
              },
            ),
            actionsPadding: EdgeInsets.only(right: 5),
            actions: [
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text('Save'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  showTextField() {

  }

  showPickerOfTime(index) {
    showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    ).then((value) => timeSelectedList[index] = value);
  }

  List settingsPageItems = [
    'Notify me when',
    'Start time',
    'End time',
    'Calls',
    'Key'
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView.separated(
          itemCount: settingsPageItems.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(settingsPageItems[index]),
              onTap: () {
                switch (index) {
                  case 0: showNumberPicker();
                  break;
                  case 1: showPickerOfTime(index);
                  break;
                  case 2: showPickerOfTime(index);
                  break;
                  case 3: showNumberPicker();
                  break;
                  case 4: showTextField();
                  break;
                }
              },
            );
          },
          separatorBuilder: (context, dividerIndex) {
            return Divider();
          },
        )
    );
  }
}

final settingsRef = _SettingsPageState();