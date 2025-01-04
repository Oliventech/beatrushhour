import 'package:beat_rush_hour/getx/bindings/app_initial_bindings.dart';
import 'package:beat_rush_hour/getx/controllers/routes/result_page_controller.dart';
import 'package:beat_rush_hour/routes/home_page.dart';
import 'package:beat_rush_hour/routes/result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");

  WidgetsFlutterBinding.ensureInitialized();

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
        GetPage(
          name: '/result',
          page: () {
            if (!Get.isRegistered<ResultPageController>()) {
              Get.put(ResultPageController());
            }
            return ResultPage();
          },
        ),
      ],
      debugShowCheckedModeBanner: false,
      initialBinding: AppInitialBindings(),
    );
  }
}
