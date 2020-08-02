import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:jiffy/jiffy.dart';

import 'database.dart';
import 'globals.dart';
import 'tasks_dialog.dart';

showQuickTaskUI(BuildContext context, StateSetter setStateFromTaskView, String week, TabController tabController,
    GlobalKey<ScaffoldState> taskViewScaffoldKey) async {
  // task form properties
  String day = "Selected Tab";
  bool important = false, repeat = false;
  DateTime date;
  TimeOfDay start, end;

  int currentWeekIndex;

  PersistentBottomSheetController _controller;

  _controller = taskViewScaffoldKey.currentState.showBottomSheet((context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
        child: Column(children: [
          Expanded(
            flex: 6,
            child: ListView.builder(
              itemCount: userTasks.keys.toList().length,
              itemBuilder: (context, index) {
                String taskName = userTasks.keys.toList()[index];
                return SlideInUp(
                  preferences:
                      AnimationPreferences(offset: Duration(seconds: 0), duration: Duration(milliseconds: 500)),
                  child: ListTile(
                    title: Text(taskName),
                    subtitle: Text(getWeekNameFromIndex(userTasks[taskName]["week"])),
                    leading: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).pop();
                        return Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) => TaskDialog(
                                setStateFromTaskView,
                                true,
                                userTasks[taskName]["done"],
                                userTasks[taskName]["importance"],
                                taskName,
                                userTasks[taskName]["description"],
                                weeks[userTasks[taskName]["week"]],
                                taskName,
                                userTasks[taskName]["endtime"],
                                userTasks[taskName]["time"],
                                userTasks[taskName]["repeat"],
                                taskViewScaffoldKey)));
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        userTasks.remove(userTasks.keys.toList()[index]);
                        Database.upload(userTasks);
                        setStateFromTaskView(() => userTasks);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: GradientButton(
                    gradient: (day == "Today") ? Gradients.backToFuture : Gradients.deepSpace,
                    child: const Text("Today"),
                    callback: () {
                      _controller.setState(() {
                        date = null;
                        day = "Today";
                        repeat = false;
                      });
                    },
                  )),
              GradientButton(
                increaseWidthBy: 30,
                gradient: (day == "Tommorow") ? Gradients.hotLinear : Gradients.deepSpace,
                child: Text("Tommorow"),
                callback: () {
                  _controller.setState(() {
                    date = null;
                    day = "Tommorow";
                    repeat = false;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: GradientButton(
                  increaseWidthBy: 30,
                  gradient: (date != null) ? Gradients.cosmicFusion : Gradients.deepSpace,
                  child: Text((date.toString() == 'null') ? "Custom" : date.toString().substring(0, 10)),
                  callback: () async {
                    date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year, 1),
                        lastDate: DateTime(2101));
                    _controller.setState(() {
                      if (date != null) {
                        day = null;
                        repeat = false;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: GradientButton(
                  gradient: (important) ? Gradients.blush : Gradients.deepSpace,
                  increaseWidthBy: 30,
                  child: Text("Important"),
                  callback: () {
                    _controller.setState(() => important = !important);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: GradientButton(
                  gradient: (repeat) ? Gradients.cosmicFusion : Gradients.deepSpace,
                  child: Text("Repeat"),
                  callback: () {
                    _controller.setState(() {
                      day = null;
                      date = null;
                      repeat = !repeat;
                    });
                  },
                ),
              ),
              GradientButton(
                gradient: (day == "Selected Tab") ? Gradients.cosmicFusion : Gradients.deepSpace,
                child: Text("Selected Tab"),
                increaseWidthBy: 30,
                callback: () {
                  _controller.setState(() {
                    day = "Selected Tab";
                    date = null;
                  });
                },
              ),
            ],
          ),
          Row(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: GradientButton(
                  gradient: (start != null) ? Gradients.jShine : Gradients.deepSpace,
                  increaseWidthBy: 26,
                  child: Text((start == null) ? "Set Start Time" : start.format(context)),
                  callback: () async {
                    start = await showTimePicker(initialTime: TimeOfDay.now(), context: context);
                    _controller.setState(() => start);
                  },
                )),
            GradientButton(
              gradient: (end != null) ? Gradients.blush : Gradients.deepSpace,
              increaseWidthBy: 26,
              child: Text((end == null) ? "Set End Time" : end.format(context)),
              callback: () async {
                end = await showTimePicker(initialTime: TimeOfDay.now(), context: context);
                _controller.setState(() => end);
              },
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                maxLength: 40,
                autocorrect: true,
                autofocus: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  hintText: ' +  Add Task',
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (value) => setStateFromTaskView(() {
                  currentWeekIndex = weeks.indexOf(Jiffy(DateTime.now()).EEEE);
                  if (value.isNotEmpty)
                    userTasks.addAll({
                      value: {
                        "time": start ?? "Any Time",
                        "endtime": end ?? "Any Time",
                        "notify": true,
                        "description": '',
                        "image": null,
                        "importance": (important) ? 1 : 0,
                        "repeat": repeat,
                        "done": false,
                        "date": date,
                        "week": (day == "Tomorrow")
                            ? ((currentWeekIndex >= 7) ? 0 : currentWeekIndex + 1)
                            : ((day == "Selected Tab")
                                ? (tabController.index != 9) ? tabController.index : currentWeekIndex
                                : (day == "Today") ? currentWeekIndex : weeks.indexOf(Jiffy(date).EEEE)),
                      },
                    });
                  print(userTasks[value]);
                  Database.upload(userTasks);
                  Navigator.of(context).pop();
                }),
              ),
            ),
          )
        ]));
  });
}
