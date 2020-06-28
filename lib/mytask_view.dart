import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:intl/intl.dart';

import 'package:jiffy/jiffy.dart';
//import 'package:auto_route/auto_route.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_dialog.dart';
import 'globals.dart';
//import 'routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  TextEditingController _textFieldTaskController;
  TextEditingController _textFieldDescriptionController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  final _totalTabs = 9;
  int _uniqueColorIndex;
  int __offset;
  SharedPreferences _storage;
  String dropdown = "Any Day";

  // for details
  String title, description, week = "Monday";
  Future<TimeOfDay> selectedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() =>
        _currentWeekTabSize += 30); // trigger the scale transition for the tab
    _tabController = TabController(length: _totalTabs, vsync: this);
    _tabController.index = weeks.indexOf(_currentWeek);
    _tabController.addListener(
        () => setState(() => _currentWeek = weeks[_tabController.index]));
    initAsyncStorage();
  }

  void initAsyncStorage() async {
    _storage = await SharedPreferences.getInstance();
    String data = _storage.get('data');
    if (data != null)
      // get the map and then convert it into a nested map (value is a map too)!
      jsonDecode(data).forEach((key, value) => userTasks.addAll({key: value}));
    else
      _storage.setString("data", jsonEncode(userTasks));
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white30,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white30,
        systemNavigationBarIconBrightness: Brightness.dark));
  }

  void _tasksEditDialog(
      {bool modifyWhat: false,
      bool done: false,
      String title,
      description,
      week2,
      oldTitle,
      dynamic endtime,
      selectedTime}) {
    // reset the form details or fill the current card details for edit
    if (!modifyWhat) {
      title = null;
      description = null;
      week = null;
      selectedTime = null;
      endtime = null;
      dropdown = "Any Day";
    } else
      dropdown = week2;

    _textFieldTaskController = TextEditingController(text: title);
    _textFieldDescriptionController = TextEditingController(text: description);

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState2) => CustomGradientDialogForm(
                  title: Text((modifyWhat) ? "Edit Task" : "New Task",
                      style: TextStyle(color: Colors.white, fontSize: 25)),
                  content: SizedBox(
                    height: 400,
                    width: 90,
                    child: Column(
                      children: [
                        const Text("What's the task ?"),
                        Expanded(
                            child: TextField(
                                controller: _textFieldTaskController,
                                autocorrect: true,
                                cursorColor: Colors.red,
                                maxLines: 1,
                                autofocus: true,
                                enableSuggestions: true,
                                maxLength: 40,
                                onChanged: (value) => title = value)),
                        const Text("Something else to remember with it?"),
                        Expanded(
                            child: TextField(
                                controller: _textFieldDescriptionController,
                                autocorrect: true,
                                cursorColor: Colors.red,
                                maxLines: 1,
                                autofocus: true,
                                enableSuggestions: true,
                                maxLength: 30,
                                onChanged: (value) => description = value)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Pick a day"),
                            DropdownButton(
                                value: dropdown,
                                items: weeks
                                    .map((value) => DropdownMenuItem<String>(
                                        value: value, child: Text(value)))
                                    .toList(),
                                onChanged: (value) {
                                  week = value;
                                  setState2(() => dropdown = value);
                                }),
                          ],
                        ),
                        const Text(
                            "if you already set the time and want to remove it. Open the time selector and just press cancel"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Set the start time"),
                            GradientButton(
                                shadowColor: Colors.black26,
                                elevation: 6.0,
                                shapeRadius: BorderRadius.circular(10),
                                gradient: Gradients.blush,
                                increaseWidthBy: 40,
                                child: Text("Choose Start Time"),
                                callback: () => selectedTime = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now())),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Set the end time"),
                            GradientButton(
                                shadowColor: Colors.black26,
                                elevation: 6.0,
                                shapeRadius: BorderRadius.circular(10),
                                gradient: Gradients.blush,
                                increaseWidthBy: 40,
                                child: Text("Choose End Time"),
                                callback: () => endtime = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now())),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GradientButton(
                                  shadowColor: Colors.black26,
                                  elevation: 6.0,
                                  shapeRadius: BorderRadius.circular(10),
                                  gradient: Gradients.coldLinear,
                                  increaseWidthBy: 20,
                                  child: const Text("Save",
                                      style: TextStyle(color: Colors.white)),
                                  callback: () async {
                                    if (week != null &&
                                        _textFieldTaskController.text
                                                .replaceAll(RegExp(r'\s'), '')
                                                .length !=
                                            0 &&
                                        _textFieldDescriptionController.text
                                                .replaceAll(RegExp(r'\s'), '')
                                                .length !=
                                            0) {
                                      TimeOfDay _awaitedTime, _awaitedTime2;
                                      if (selectedTime is String &&
                                          selectedTime != "Any Time") {
                                        DateTime dateTimeFromString =
                                            DateFormat.jm().parse(selectedTime);
                                        selectedTime = TimeOfDay(
                                            hour: dateTimeFromString.hour,
                                            minute: dateTimeFromString.minute);
                                        _awaitedTime = selectedTime;
                                      } else if (selectedTime
                                          is Future<TimeOfDay>) {
                                        _awaitedTime = (await selectedTime);
                                      }

                                      if (endtime is String &&
                                          endtime != "Any Time") {
                                        DateTime dateTimeFromString =
                                            DateFormat.jm().parse(endtime);
                                        endtime = TimeOfDay(
                                            hour: dateTimeFromString.hour,
                                            minute: dateTimeFromString.minute);
                                        _awaitedTime2 = endtime;
                                      } else if (endtime is Future<TimeOfDay>) {
                                        _awaitedTime2 = (await endtime);
                                      }
                                      // if modifiying then first check if key present else make one
                                      setState(() {
                                        if (modifyWhat &&
                                            userTasks.containsKey(oldTitle))
                                          userTasks.remove(oldTitle);
                                        userTasks.addAll({
                                          title: {
                                            "time": (_awaitedTime != null)
                                                ? "${(_awaitedTime.hour > 12) ? _awaitedTime.hour - 12 : _awaitedTime.hour}:${(_awaitedTime.minute < 10) ? '0${_awaitedTime.minute}' : _awaitedTime.minute} ${(_awaitedTime.period.index == 1) ? 'PM' : 'AM'}"
                                                : "Any Time",
                                            "endtime": (_awaitedTime2 != null)
                                                ? "${(_awaitedTime2.hour > 12) ? _awaitedTime2.hour - 12 : _awaitedTime2.hour}:${(_awaitedTime2.minute < 10) ? '0${_awaitedTime2.minute}' : _awaitedTime2.minute} ${(_awaitedTime2.period.index == 1) ? 'PM' : 'AM'}"
                                                : "Any Time",
                                            "notify": true,
                                            "description": description,
                                            "image": null,
                                            "importance": 0,
                                            "done":
                                                (!modifyWhat) ? false : done,
                                            "week": weeks.indexOf(week)
                                          },
                                        });
                                      });
                                      _storage.setString(
                                          "data", jsonEncode(userTasks));
                                      Navigator.of(context).pop();
                                    }
                                  }),
                              if (modifyWhat)
                                GradientButton(
                                  shadowColor: Colors.black26,
                                  elevation: 6.0,
                                  shapeRadius: BorderRadius.circular(10),
                                  gradient: Gradients.aliHussien,
                                  increaseWidthBy: 20,
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.white)),
                                  callback: () {
                                    setState(() => userTasks.remove(title));
                                    _storage.setString(
                                        "data", jsonEncode(userTasks));
                                    Navigator.of(context).pop();
                                  },
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  titleBackground: Colors.red,
                  contentBackground: Colors.white,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 25),
                )));
  }

  @override
  Widget build(BuildContext context) {
    __offset = 200;
    _uniqueColorIndex = 0;
    return DefaultTabController(
      length: _totalTabs,
      child: Scaffold(
          appBar: AppBar(
              titleSpacing: 20,
              brightness: Brightness.light,
              bottom: TabBar(
                physics: const BouncingScrollPhysics(),
                isScrollable: true,
                indicatorColor: Colors.transparent,
                indicatorWeight: 0.1,
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                tabs: [
                  for (String text in weeks)
                    if (_tabController.index == weeks.indexOf(_currentWeek))
                      Tab(
                        child: ZoomIn(
                          preferences: AnimationPreferences(
                              duration: const Duration(milliseconds: 100)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              width: (text == _currentWeek)
                                  ? _currentWeekTabSize + 70
                                  : _currentWeekTabSize + 60,
                              height: (text == _currentWeek)
                                  ? _currentWeekTabSize
                                  : _currentWeekTabSize - 30,
                              child: GradientButton(
                                gradient: (text == _currentWeek)
                                    ? Gradients.cosmicFusion
                                    : Gradients.taitanum,
                                shadowColor: Colors.transparent,
                                increaseWidthBy: _currentWeekTabSize + 10,
                                child: Text(text,
                                    style: TextStyle(
                                        fontSize:
                                            (text == _currentWeek) ? 20 : 15)),
                                callback: null,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              actions: [
                /*Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                  child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                          icon: const Icon(Icons.account_circle),
                          color: Colors.white,
                          onPressed: () => ExtendedNavigator.of(context)
                              .pushNamed(Routes.accountSettingsView))),
                )*/
              ],
              title: const Text("What's my today's tasks ?"),
              elevation: 0,
              backgroundColor: Colors.transparent),
          body: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                for (int i = 1; i <= _totalTabs; i++)
                  CupertinoScrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Row(children: [
                              Text("Pending",
                                  style: TextStyle(
                                      foreground: Paint()
                                        ..shader = textGradientShader,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child:
                                          Divider(color: Colors.deepOrange))),
                            ]),
                          ),
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index)
                              if (!userTasks[task]["done"])
                                BounceIn(
                                  preferences: AnimationPreferences(
                                      offset: Duration(
                                          milliseconds: __offset += 50)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blueGrey[200],
                                              blurRadius: 10.0)
                                        ],
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: autoGenerateColorCard[
                                              _uniqueColorIndex++],
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: ListTileTheme(
                                        iconColor: Colors.white,
                                        textColor: Colors.white,
                                        child: ListTile(
                                          title: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Text(task),
                                          ),
                                          subtitle: Row(
                                            verticalDirection:
                                                VerticalDirection.up,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                  child: Text(userTasks[task]
                                                      ['description'])),
                                              Card(
                                                elevation: 0,
                                                color: Colors.black12,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    (userTasks[task]['time'] ==
                                                            userTasks[task]
                                                                ['endtime'])
                                                        ? "${userTasks[task]['time']}"
                                                        : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                  value: userTasks[task]
                                                      ['done'],
                                                  onChanged: (value) {
                                                    setState(() =>
                                                        userTasks[task]
                                                            ['done'] = value);
                                                    _storage.setString("data",
                                                        jsonEncode(userTasks));
                                                  })
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _tasksEditDialog(
                                                modifyWhat: true,
                                                title: task,
                                                oldTitle: task,
                                                description: userTasks[task]
                                                    ["description"],
                                                week2: weeks[userTasks[task]
                                                    ["week"]],
                                                selectedTime: userTasks[task]
                                                    ["time"],
                                                done: userTasks[task]["done"],
                                                endtime: userTasks[task]
                                                    ["endtime"]),
                                          ),
                                          onTap: () => null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          if (_tabController.index != 7 &&
                              _tabController.index != 8)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Row(children: [
                                Text(
                                  "All Days & Any days",
                                  style: TextStyle(
                                      foreground: Paint()
                                        ..shader = textGradientShader,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        child:
                                            Divider(color: Colors.deepOrange))),
                              ]),
                            ),
                          // All day and any day tasks
                          if (_tabController.index != 7 &&
                              _tabController.index != 8)
                            for (String task in userTasks.keys)
                              if (userTasks[task]["week"] == 7)
                                if (!userTasks[task]["done"])
                                  BounceIn(
                                    preferences: AnimationPreferences(
                                        offset: Duration(
                                            milliseconds: __offset += 50)),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 5, 0, 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.blueGrey[200],
                                                blurRadius: 10.0)
                                          ],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: GradientColors.aqua,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        child: ListTileTheme(
                                          iconColor: Colors.white,
                                          textColor: Colors.white,
                                          child: ListTile(
                                            title: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 0),
                                              child: Text(task),
                                            ),
                                            subtitle: Row(
                                              verticalDirection:
                                                  VerticalDirection.up,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                    child: Text(userTasks[task]
                                                        ['description'])),
                                                Card(
                                                  elevation: 0,
                                                  color: Colors.black12,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      (userTasks[task]
                                                                  ['time'] ==
                                                              userTasks[task]
                                                                  ['endtime'])
                                                          ? "${userTasks[task]['time']}"
                                                          : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Checkbox(
                                                    value: userTasks[task]
                                                        ['done'],
                                                    onChanged: (value) {
                                                      setState(() =>
                                                          userTasks[task]
                                                              ['done'] = value);
                                                      _storage.setString(
                                                          "data",
                                                          jsonEncode(
                                                              userTasks));
                                                    })
                                              ],
                                            ),
                                            isThreeLine: true,
                                            trailing: IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _tasksEditDialog(
                                                  modifyWhat: true,
                                                  title: task,
                                                  oldTitle: task,
                                                  description: userTasks[task]
                                                      ["description"],
                                                  week2: weeks[userTasks[task]
                                                      ["week"]],
                                                  selectedTime: userTasks[task]
                                                      ["time"],
                                                  done: userTasks[task]["done"],
                                                  endtime: userTasks[task]
                                                      ["endtime"]),
                                            ),
                                            onTap: () => null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Row(children: [
                              Text(
                                "Completed",
                                style: TextStyle(
                                    foreground: Paint()
                                      ..shader = textGradientShader,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              const Expanded(
                                  child: const Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child:
                                          Divider(color: Colors.deepOrange))),
                            ]),
                          ),
                          // Task that are already done will be grey with strike text
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index)
                              if (userTasks[task]["done"])
                                BounceIn(
                                  preferences: AnimationPreferences(
                                      offset: Duration(
                                          milliseconds: __offset += 10)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueGrey[200],
                                            blurRadius: 10.0,
                                          )
                                        ],
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: GradientColors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: ListTileTheme(
                                        iconColor: Colors.white,
                                        textColor: Colors.grey,
                                        child: ListTile(
                                          title: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Text(task,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough)),
                                          ),
                                          subtitle: Row(
                                            verticalDirection:
                                                VerticalDirection.up,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                  child: Text(
                                                      userTasks[task]
                                                          ['description'],
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough))),
                                              Card(
                                                elevation: 0,
                                                color: Colors.black12,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    (userTasks[task]['time'] ==
                                                            userTasks[task]
                                                                ['endtime'])
                                                        ? "${userTasks[task]['time']}"
                                                        : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                  value: userTasks[task]
                                                      ['done'],
                                                  onChanged: (value) {
                                                    setState(() =>
                                                        userTasks[task]
                                                            ['done'] = value);
                                                    _storage.setString("data",
                                                        jsonEncode(userTasks));
                                                  })
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _tasksEditDialog(
                                                modifyWhat: true,
                                                title: task,
                                                oldTitle: task,
                                                description: userTasks[task]
                                                    ["description"],
                                                week2: weeks[userTasks[task]
                                                    ["week"]],
                                                selectedTime: userTasks[task]
                                                    ["time"],
                                                done: userTasks[task]["done"],
                                                endtime: userTasks[task]
                                                    ["endtime"]),
                                          ),
                                          onTap: () => null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          // To give space for showing the last card's edit button
                          const Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 73))
                        ],
                      ),
                    ),
                  )
              ]),
          floatingActionButton: RotateIn(
            preferences: AnimationPreferences(
                duration: const Duration(milliseconds: 300)),
            child: FloatingActionButton(
              heroTag: "Add Task",
              focusElevation: 80,
              onPressed: () => null,
              tooltip: "Add a task",
              child: CircularGradientButton(
                child: const Icon(Icons.add),
                callback: () => _tasksEditDialog(),
                gradient: Gradients.hotLinear,
                elevation: 0,
              ),
            ),
          )),
    );
  }
}