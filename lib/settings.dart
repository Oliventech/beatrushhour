import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {

  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  static int timeThreshold = 20;

  static String timeInNormalFormat = '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}';

  static List timeSelectedList = [TimeOfDay.now(), TimeOfDay(hour: TimeOfDay.now().minute+30 >= 60? TimeOfDay.now().hour+1:TimeOfDay.now().hour, minute: TimeOfDay.now().minute+30 >= 60? TimeOfDay.now().minute%30:TimeOfDay.now().minute+30)];

  String giveTimeInNormalFormat(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

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
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  }
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text('Save'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          );
        }
    );
  }

  TextEditingController keyTextController = TextEditingController();

  void dispose() {
    super.dispose();
    keyTextController.dispose();
  }

  showPickerOfTime(index) {
    showTimePicker(
        cancelText: 'Save',
        context: context,
        initialTime: index == 0?timeSelectedList[0]:timeSelectedList[1],
    ).then((value) {
      setState(() {
        timeSelectedList[index] = value;
      });
    });
  }

  List settingsPageItems = [
    'Notify me when',
    'Start time',
    'End time',
  ];

  @override
  Widget build(BuildContext context) {
    List trailingList = [
      Text('$timeThreshold'),
      Text('${giveTimeInNormalFormat(timeSelectedList[0])}'),
      Text('${giveTimeInNormalFormat(timeSelectedList[1])}'),
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView.separated(
          itemCount: settingsPageItems.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(settingsPageItems[index]),
              trailing: trailingList[index],
              onTap: () {
                switch (index) {
                  case 0: showNumberPicker();
                  break;
                  case 1: showPickerOfTime(0);
                  break;
                  case 2: showPickerOfTime(1);
                  break;
                  default: showPickerOfTime(1);
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