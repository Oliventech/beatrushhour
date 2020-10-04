import 'dart:async';
import 'package:beatrushhour/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/distance.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum PageNavigator {settings}

class _MyHomePageState extends State<MyHomePage> {

  var _timer;
  int duration;

  TextEditingController _fromSearchBarController = TextEditingController();
  TextEditingController _toSearchBarController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Less traffic"),
          content: Text("Duration : $duration"),
        );
      },
    );
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void dispose() {
    super.dispose();
    _fromSearchBarController.dispose();
    _toSearchBarController.dispose();
  }

  List<double> latitudeList = List.filled(2, 0);
  List<double> longitudeList = List.filled(2, 0);

  List placeList = List.filled(2, 0);

  void triggerApiResults(barPos) async {
    //barPos means the position of the search bar

    Prediction prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: 'AIzaSyA8fgeZ4gNYIcMC1jPTG4YTI_m4v-P6AXk',
        mode: Mode.overlay,
        language: "en"
    );
    GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: 'AIzaSyA8fgeZ4gNYIcMC1jPTG4YTI_m4v-P6AXk');
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(prediction.placeId);

    print(detail.result.formattedAddress);

    setState(() {
      barPos == 0 ? _fromSearchBarController.text = '${detail.result.formattedAddress}':_toSearchBarController.text = '${detail.result.formattedAddress}';
    });

    placeList[barPos]  = detail.result;

    latitudeList[barPos] = detail.result.geometry.location.lat;
    longitudeList[barPos] = detail.result.geometry.location.lng;
  }

  activateDistanceCalculation() async {
    final GoogleDistanceMatrix distanceMatrix = GoogleDistanceMatrix(apiKey: 'AIzaSyA8fgeZ4gNYIcMC1jPTG4YTI_m4v-P6AXk');

    var origins = [
      Location(latitudeList[0], longitudeList[0]),
      //Location(77.00000, 77.00000),
    ];
    var destinations = [
      Location(latitudeList[1], longitudeList[1]),
      //Location(88.01234, 79.034567),
    ];

    var responseForLocation = await distanceMatrix.distanceWithLocation(
      origins,
      destinations,
    );

    try {
      print('response ${responseForLocation.status}');

      if (responseForLocation.isOkay) {

        for (var row in responseForLocation.results) {
          for (var element in row.elements) {
            duration = element.duration.value;
            print(element.duration.value);
            print(
                'distance ${element.distance.text} duration ${element.duration.value}');
          }
        }
      } else {
        print('ERROR: ${responseForLocation.errorMessage}');
      }
    } finally {
      distanceMatrix.dispose();
    }

    int seconds = Duration(minutes: settingsRef.timeThreshold).inSeconds;
    print('seconds: $seconds');
    print('duration: $duration');
    if(duration <= seconds) {
      _timer.cancel();
      _showNotificationWithDefaultSound();
      print('yay, time reached');
    }
  }

  @override
  Widget build(BuildContext context) {
    var _selection;

    return Scaffold(
      appBar: AppBar(
        title: Text('Beat Rush Hour'),
        actions: [
          PopupMenuButton<PageNavigator>(
              onSelected: (PageNavigator result) {
                setState(() {
                  _selection = result;
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SettingsPage()
                  ));
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<PageNavigator>>[
                PopupMenuItem(
                  child: Text('Settings'),
                  value: PageNavigator.settings,
                )
              ]
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _fromSearchBarController,
              onTap: () => triggerApiResults(0),
              decoration: InputDecoration(
                labelText: 'From',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _toSearchBarController,
              onTap: () => triggerApiResults(1),
              decoration: InputDecoration(
                labelText: 'To',
              ),
            ),
          ),
          RaisedButton(
            child: Text('Cancel'),
            onPressed: () {
              _timer.cancel();
            },
          ),
          RaisedButton(
            child: Text('Done'),
            onPressed: () {
              // if(settingsRef.timeSelectedList[0] < TimeOfDay.now()) {
              //   timerToBeginOtherTimer = new Timer.periodic(
              //     Duration(seconds: 2),
              //       (Timer timer) {
              //       print(TimeOfDay.now());
              //         if(settingsRef.timeSelectedList[0] <= TimeOfDay.now()) {
              //
              //         }
              //       }
              //   );
              // }
              _timer = new Timer.periodic(
                Duration(seconds: 5),
                    (Timer timer) {
                  activateDistanceCalculation();
                },
              );
            },
          ),
          RaisedButton(
            child: Text('For testing notifications'),
            onPressed: () => _showNotificationWithDefaultSound(),
          )
        ],
      ),
    );
  }
}
