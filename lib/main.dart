import 'package:beat_rush_hour/firebase_options.dart';
import 'package:beat_rush_hour/getx/bindings/app_initial_bindings.dart';
import 'package:beat_rush_hour/routes/home_page.dart';
import 'package:beat_rush_hour/routes/result_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      getPages: [
        GetPage(
          name: '/',
          page: () => MyHomePage(),
        ),
      ],
      debugShowCheckedModeBanner: false,
      initialBinding: AppInitialBindings(),
    );
  }
}
