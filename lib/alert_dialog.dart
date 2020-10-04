import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//class AlertDialogBox{

  buildPicker(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notify when the time is less than'),
            content: CupertinoPicker.builder(
              itemExtent: 20,
              onSelectedItemChanged: null,
              itemBuilder: (context, pickerIndex) {
                return Align(
                  alignment: Alignment.center,
                  child: Text('$pickerIndex'),
                );
              },
            ),
          );
        }
    );
  }
//}