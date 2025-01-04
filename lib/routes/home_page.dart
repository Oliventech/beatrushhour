import 'package:beat_rush_hour/classes/routes/home_page/text_form_field_info.dart';
import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/getx/states/routes/home_page/home_page_text_field_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomePageController homePageController = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beat Rush Hour'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 20.0,
          children: [
            ...homePageController.textFormFieldInfoMap.keys.map<Widget>(
              (key) {
                TextFormFieldInfo info =
                    homePageController.textFormFieldInfoMap[key]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SearchAnchor.bar(
                    searchController: info.controller,
                    barHintText: info.backgroundText,
                    suggestionsBuilder: (context, controller) {
                      homePageController.onChanged(
                        type: info.homePageFieldType,
                      );
                      return [
                        GetBuilder<HomePageController>(
                          id: info.homePageFieldType,
                          builder: (controller) {
                            if (info.state.value ==
                                HomePageTextFieldState.loading) {
                              return Container(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            } else if (info.state.value ==
                                HomePageTextFieldState.suggestionsLoaded) {
                              return Column(
                                children: [
                                  ...info.suggestionsList.map(
                                    (value) => ListTile(
                                      title: Text(value.fullText),
                                      leading: Icon(
                                        Icons.place_outlined,
                                      ),
                                      onTap: () {
                                        //TODO:
                                        homePageController.onSuggestionTap(
                                          type: info.homePageFieldType,
                                          selectedValue: value,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            } else if (info.state.value ==
                                HomePageTextFieldState.noSuggestionFound) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text('No Suggestions Found'),
                              );
                            } else if (info.state.value ==
                                HomePageTextFieldState.completed) {
                              //TODO:
                            } else if (info.state.value ==
                                HomePageTextFieldState.closed) {
                              //TODO:
                            }
                            return Container();
                          },
                        ),
                      ];
                    },
                  ),
                );
              },
            ),
            Text("Select minutes you want to reach under!"),
            CupertinoTimerPicker(
              onTimerDurationChanged: (Duration duration) {
                homePageController.setDuration(value: duration);
              },
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.done_all_rounded,
              ),
              onPressed: () {
                homePageController.onSubmit();
              },
              label: Text('Start'),
            )
          ],
        ),
      ),
    );
  }
}
