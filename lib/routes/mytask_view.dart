import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

import 'package:jiffy/jiffy.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_animator/flutter_animator.dart';

import '../custom_dialog.dart';
import '../globals.dart';
import '../routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  final _totalTabs = 7;
  int _uniqueColorIndex;
  int __offset;

  // for details
  String title, description, week;
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

  void _tasksEditDialog({bool modifyWhat}) {
    // reset the form details
    title = null;
    description = null;
    week = null;
    selectedTime = null;

    showDialog(
        context: context,
        child: CustomGradientDialogForm(
          title: const Text(
            "Edit Task",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          content: SizedBox(
            height: 287,
            width: 90,
            child: Column(
              children: [
                Text("What's the task ?"),
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    cursorColor: Colors.red,
                    maxLines: 1,
                    autofocus: true,
                    enableSuggestions: true,
                    maxLength: 40,
                    onChanged: (value) => title = value,
                  ),
                ),
                Text("Something else to remember with it?"),
                Expanded(
                    child: TextField(
                  autocorrect: true,
                  cursorColor: Colors.red,
                  maxLines: 1,
                  autofocus: true,
                  enableSuggestions: true,
                  maxLength: 40,
                  onChanged: (value) => description = value,
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pick a day"),
                    DropdownButton(
                      value: weeks[0],
                      items: weeks
                          .map((value) => DropdownMenuItem<String>(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) => setState(() => week = value),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Set the time"),
                    GradientButton(
                        shadowColor: Colors.black26,
                        elevation: 6.0,
                        shapeRadius: BorderRadius.circular(10),
                        gradient: Gradients.blush,
                        increaseWidthBy: 20,
                        child: Text("Choose Time"),
                        callback: () {
                          selectedTime = showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                        }),
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
                          child: Text("Save",
                              style: TextStyle(color: Colors.white)),
                          callback: () async {
                            TimeOfDay _awaitedTime = (await selectedTime);

                            if (modifyWhat == null)
                              setState(() => userTasks.addAll({
                                    title: {
                                      "time": (_awaitedTime != null)
                                          ? "${_awaitedTime.hour}:${_awaitedTime.minute}${_awaitedTime.periodOffset}"
                                          : "Any Time",
                                      "endtime": "12:00AM",
                                      "notify": true,
                                      "description": description,
                                      "image": null,
                                      "importance": 0,
                                      "done": false,
                                      "week": weeks.indexOf(week)
                                    },
                                  }));
                            Navigator.of(context).pop();
                          }),
                    ],
                  ),
                )
              ],
            ),
          ),
          titleBackground: Colors.red,
          contentBackground: Colors.white,
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 25,
          ),
        ));
  }

  void _addPlanCallback() {
    print("Hi");
    __offset = 100;
    setState(() => userTasks.addAll({
          "Test ${Random().nextInt(324)}": {
            "time": "9:00AM",
            "endtime": "11:00AM",
            "notify": true,
            "description": "This is a test task, blah, blah, blah, blah, blah",
            "image": null,
            "importance": 0,
            "done": false,
            "week": 2
          },
        }));
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
              tabs: <Widget>[
                for (String text in weeks)
                  Tab(
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
                                  fontSize: (text == _currentWeek) ? 20 : 15)),
                          callback: null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                        icon: const Icon(Icons.account_circle),
                        color: Colors.white,
                        onPressed: () => ExtendedNavigator.of(context)
                            .pushNamed(Routes.accountSettingsView))),
              )
            ],
            title: const Text("What's my today's tasks ?"),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
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
                                            blurRadius: 10.0,
                                          )
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
                                                    "${userTasks[task]['time']} - ${userTasks[task]['endtime']}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                  value: userTasks[task]
                                                      ['done'],
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          userTasks[task]
                                                              ['done'] = value))
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: _tasksEditDialog,
                                          ),
                                          onTap: () => null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          Divider(
                            thickness: 1.0,
                            color: Colors.blueGrey[100],
                          ),
                          // Task that are already done will be grey with strike text
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index)
                              if (userTasks[task]["done"])
                                BounceIn(
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
                                                    "${userTasks[task]['time']} - ${userTasks[task]['endtime']}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                  value: userTasks[task]
                                                      ['done'],
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          userTasks[task]
                                                              ['done'] = value))
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: _tasksEditDialog,
                                          ),
                                          onTap: () => null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )
              ]),
          floatingActionButton:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              heroTag: "btn3",
              focusElevation: 80,
              onPressed: () => null,
              tooltip: 'Edit Plan View',
              child: CircularGradientButton(
                child: const Icon(Icons.calendar_today),
                callback: () => ExtendedNavigator.of(context)
                    .pushNamed(Routes.weekendPlanView),
                gradient: Gradients.blush,
                elevation: 0,
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: FloatingActionButton(
                  heroTag: "btn4",
                  focusElevation: 80,
                  onPressed: () => null,
                  tooltip: 'Add a task',
                  child: CircularGradientButton(
                    child: const Icon(Icons.add),
                    callback: _addPlanCallback,
                    gradient: Gradients.hotLinear,
                    elevation: 0,
                  ),
                ))
          ])),
    );
  }
}
