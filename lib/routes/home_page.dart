import 'package:beat_rush_hour/classes/routes/home_page/text_form_field_info.dart';
import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/getx/states/routes/home_page/home_page_text_field_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomePageController homePageController = Get.find<HomePageController>();
  bool isDialogBoxOpen = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homePageController.resultState.listen(
        (ResultState state) {
          if (state != ResultState.initial && !isDialogBoxOpen) {
            isDialogBoxOpen = true;

            Get.dialog(
              AlertDialog(
                content: Obx(
                  () {
                    ResultState resultState =
                        homePageController.resultState.value;
                    if (resultState == ResultState.resultLoaded) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'You can now reach your destination in ${homePageController.humanizeDuration(homePageController.currentDuration!)}',
                          ),
                        ],
                      );
                    } else if (resultState == ResultState.loading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (resultState == ResultState.success) {
                      return Center(
                        child: Text(
                          'You can now close this app. No need to worry about checking maps repeatedly now! \n\nWe will periodically check the time need to reach your destination for the next three hours, and if it becomes less than the duration, we will notify you. If you get no notification during that time, then you can assume that time needed to reach your destination did not come below the time you had specified.',
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 50.0,
                              color: Colors.redAccent,
                            ),
                            Text(
                                'Sorry, some unexpected error occurred while fetching duration data!'),
                          ],
                        ),
                      );
                    }
                  },
                ),
                scrollable: true,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      isDialogBoxOpen = false;
                    },
                    child: Text('Ok'),
                  )
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20.0,
                    ),
                  ),
                ),
              ),
              barrierDismissible: false,
            );
          }
        },
      );
    });

    super.initState();
  }

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
                homePageController.setThresholdDuration(value: duration);
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
