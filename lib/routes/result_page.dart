import 'package:beat_rush_hour/classes/routes/home_page/text_form_field_info.dart';
import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/getx/controllers/routes/result_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultPage extends StatefulWidget {
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final HomePageController homePageController = Get.find<HomePageController>();
  final ResultPageController resultsPageController =
      Get.find<ResultPageController>();
  late Map<HomePageFieldType, TextFormFieldInfo> textFormFormFieldMap;

  @override
  void initState() {
    textFormFormFieldMap = homePageController.textFormFieldInfoMap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          ResultPageState state = resultsPageController.resultPageState.value;

          if (state == ResultPageState.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state == ResultPageState.success) {
            return Column(
              children: [
                Text(
                  'Origin: ${textFormFormFieldMap[HomePageFieldType.origin]?.prediction?.fullText}',
                ),
                Text(
                  'Destiniation: ${textFormFormFieldMap[HomePageFieldType.destination]?.prediction?.fullText}',
                ),
                Text(
                  'Duration you want to reach under: ${homePageController.thresholdDuration}',
                ),
                Text(
                  'Current duration travel will take: ${resultsPageController.currentDuration}',
                ),
                Text(
                  'Last Time Duration was Fetched: ',
                ),
              ],
            );
          } else {
            return Center(
              child: Text(
                'Sorry, some unexpected error occurred.',
              ),
            );
          }
        }),
      ),
    );
  }
}
