import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:whatsmytodaystasks/card_design.dart';
import 'package:whatsmytodaystasks/mytask_view_partials.dart';

import 'database.dart' show Database;
import 'globals.dart';
import 'quick_task_ui.dart';
import 'tasks_dialog.dart' show TaskDialog;

class TaskView extends StatefulWidget {
  @override
  createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  final _totalTabs = 10;
  int _uniqueColorIndex;
  int __offset;
  //String dropdown = "Choose Day";
  ProgressDialog pr;

  // for details
  String title, description, week = "Monday";
  Future<TimeOfDay> selectedTime;

  RefreshController _refreshController;

  final taskViewScaffoldKey = GlobalKey<ScaffoldState>();

  // setState() called after dispose()
  @override
  build(BuildContext context) {
    __offset = 200;
    _uniqueColorIndex = 0;

    pr = ProgressDialog(context);
    return DefaultTabController(
      length: _totalTabs,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
        child: Scaffold(
            key: taskViewScaffoldKey,
            appBar: AppBar(
                titleSpacing: 20,
                brightness: Brightness.light,
                bottom: TabBar(
                  physics: (!kIsWeb) ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  indicatorWeight: 0.1,
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: _tabController,
                  tabs: [
                    for (String text in weeks)
                      if (_tabController.index == weeks.indexOf(_currentWeek))
                        Tab(
                          // TODO: maybe some improvement
                          child: ZoomIn(
                            preferences: AnimationPreferences(
                                duration: const Duration(milliseconds: 100), offset: const Duration(milliseconds: 500)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                                width: (text == _currentWeek) ? _currentWeekTabSize + 70 : _currentWeekTabSize + 60,
                                height: (text == _currentWeek) ? _currentWeekTabSize : _currentWeekTabSize - 30,
                                child: GradientButton(
                                  gradient: (text == _currentWeek) ? Gradients.cosmicFusion : Gradients.taitanum,
                                  shadowColor: Colors.transparent,
                                  increaseWidthBy: _currentWeekTabSize + 10,
                                  child: Text(text, style: TextStyle(fontSize: (text == _currentWeek) ? 20 : 15)),
                                  callback: null,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
                actions: [
                  if (kIsWeb)
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        // sync button
                        child: ZoomIn(
                          preferences: AnimationPreferences(
                              duration: const Duration(milliseconds: 400), offset: const Duration(seconds: 1)),
                          child: CircleAvatar(
                            radius: 16.0,
                            backgroundColor: Colors.red,
                            child: IconButton(
                                tooltip: 'Sync',
                                icon: const Icon(Icons.sync, size: 17.0),
                                color: Colors.white,
                                onPressed: () async => await _refreshController.requestRefresh()),
                          ),
                        )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      // sync button
                      child: ZoomIn(
                        preferences: AnimationPreferences(
                            duration: const Duration(milliseconds: 400), offset: const Duration(seconds: 1)),
                        child: CircleAvatar(
                          radius: 16.0,
                          backgroundColor: Colors.red,
                          child: IconButton(
                              tooltip: 'View',
                              icon: Icon(
                                  (() {
                                    switch (isGrid) {
                                      case 0:
                                        return Icons.list;
                                      case 1:
                                        return Icons.grid_on;
                                      case 2:
                                        return Icons.grid_off;
                                    }
                                  }()),
                                  size: 17.0),
                              color: Colors.white,
                              onPressed: () => setState(() => (isGrid < 2) ? isGrid++ : isGrid = 0)),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                      // profile button
                      child: ZoomIn(
                        preferences: AnimationPreferences(
                            duration: const Duration(milliseconds: 400), offset: const Duration(seconds: 1)),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          child: CircleAvatar(
                              radius: 23,
                              child: Icon(Icons.account_circle, color: Colors.white),
                              backgroundColor: Colors.red),
                          onSelected: (email) => TaskViewBackend.profileButtonAction(
                              email, setState, pr, userTasks, context, _refreshController),
                          itemBuilder: (context) {
                            return (["Add Account"] + Database.loadAccounts())
                                .map((String choice) => PopupMenuItem<String>(
                                    value: choice,
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                            child: TaskViewBackend.generateIconsForProfileList(choice)),
                                        Expanded(child: Text(choice))
                                      ],
                                    )))
                                .toList();
                          },
                        ),
                      )),
                ],
                title: FadeInLeft(
                    preferences: const AnimationPreferences(
                        duration: const Duration(milliseconds: 400), offset: const Duration(seconds: 1)),
                    child: const Text("What's my today's tasks ?")),
                elevation: 0,
                backgroundColor: Colors.transparent),
            body: TabBarView(controller: _tabController, children: [
              for (int i = 1; i <= _totalTabs; i++)
                CupertinoScrollbar(
                  isAlwaysShown: _resetOffset(i),
                  child: SmartRefresher(
                    enablePullUp: false,
                    enablePullDown: true,
                    header: WaterDropHeader(waterDropColor: Colors.red),
                    controller: _refreshController,
                    onRefresh: () async {
                      try {
                        await initAsync();
                      } catch (error) {
                        print(error);
                      }
                      _refreshController.refreshCompleted();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
                      child: (smartShowSections(setState, _tabController.index))
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                              child: Column(children: [
                                Image.asset('assets/notes.png', width: 60, height: 60),
                                const Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text("Nothing to show", style: TextStyle(color: Colors.blueGrey)))
                              ]))
                          : Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                taskSection(
                                    (_tabController.index != 7 &&
                                            _tabController.index != 8 &&
                                            _tabController.index != 9)
                                        ? "Suppose to be completed yesterday"
                                        : "",
                                    0),

                                // Important Cards first
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == weeks.indexOf(_currentWeek) - 1 &&
                                      _tabController.index != 9 &&
                                      _tabController.index != 8 &&
                                      _tabController.index != 7)
                                    if (!userTasks[task]["done"] && userTasks[task]["importance"] == 1)
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                // Then other tasks
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == weeks.indexOf(_currentWeek) - 1 &&
                                      _tabController.index != 9 &&
                                      _tabController.index != 8 &&
                                      _tabController.index != 7)
                                    if (!userTasks[task]["done"] && userTasks[task]["importance"] == 0)
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                taskSection("Pending", 1),

                                // All Tasks
                                for (String task in userTasks.keys)
                                  if (_tabController.index == 9 && !userTasks[task]["done"])
                                    taskCard(userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                // Important Cards first
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == _tabController.index)
                                    if (!userTasks[task]["done"] && userTasks[task]["importance"] == 1)
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                // Then other tasks
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == _tabController.index)
                                    if (!userTasks[task]["done"] && userTasks[task]["importance"] == 0)
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                if (_tabController.index != 7 && _tabController.index != 8 && _tabController.index != 9)
                                  taskSection("All Days & Any days", 2),

                                // All day and any day tasks
                                if (_tabController.index != 7 && _tabController.index != 8 && _tabController.index != 9)
                                  for (String task in userTasks.keys)
                                    if ((userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8))
                                      if (!userTasks[task]["done"])
                                        taskCard(
                                            userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                taskSection("Completed", 3),

                                // Task that are already done will be grey with strike text
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == _tabController.index ||
                                      userTasks[task]["week"] == 7 ||
                                      userTasks[task]["week"] == 8)
                                    if (userTasks[task]["done"])
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                // To give space for showing the last card's edit button
                                const Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 73))
                              ],
                            ),
                    ),
                  ),
                )
            ]),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                    child: InkWell(
                      onTap: () => showQuickTaskUI(context, setState, week, _tabController, taskViewScaffoldKey),
                      child: Material(
                        color: Colors.white,
                        elevation: 5.0,
                        shadowColor: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(25.7),
                        child: SizedBox(height: 40.0, child: Center(child: Text("Add / Search Tasks"))),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Material(
                        elevation: 5,
                        shadowColor: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(25.7),
                        child: CircleAvatar(radius: 23, child: Icon(Icons.list), backgroundColor: Colors.white)),
                    onSelected: (value) => _tabController.animateTo(weeks.indexOf(value)),
                    itemBuilder: (BuildContext context) {
                      return weeks.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            height: 40,
                            child: Text(
                              choice,
                              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                            ));
                      }).toList();
                    },
                  ),
                ),
                ZoomIn(
                  preferences: AnimationPreferences(
                      duration: const Duration(milliseconds: 300), offset: const Duration(seconds: 1)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                  ),
                ),
              ],
            )),
      ),
    );
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white30,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white30,
        systemNavigationBarIconBrightness: Brightness.dark));
    switch (state) {
      case AppLifecycleState.resumed:
        _refreshController.requestRefresh();
        break;
      default:
    }
  }

  @override
  dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future initAsync() async {
    await Database.autoconnect(userTasks);
    userTasks = await Database.download();
    await Database.resetTasks(userTasks, _currentWeek);
    setState(() => userTasks = userTasks);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() => _currentWeekTabSize += 30); // trigger the scale transition for the tab
    _tabController = TabController(length: _totalTabs, vsync: this);
    _tabController.index = weeks.indexOf(_currentWeek);

    // show the card after the tab swipe animation is over otherwise it's very glitchy
    // NOTE: to fix a tab issue in flutter web had to disable swipe tab in web platform
    if (!kIsWeb)
      _tabController.animation.addListener(() {
        if (int.parse(_tabController.animation.value.toString().substring(2)) != 0) {
          if (taskCardBool) setState(() => taskCardBool = false);
        } else {
          if (!taskCardBool) setState(() => taskCardBool = true);
        }
      });

    _tabController.addListener(() => setState(() => _currentWeek = weeks[_tabController.index]));
    _refreshController = RefreshController(initialRefresh: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshController.requestRefresh()); // executes after build
  }

  @override
  setState(fn) {
    if (mounted) super.setState(fn);
  }

  bool _resetOffset(int i) {
    if (i == _totalTabs) __offset = 0;
    return false;
  }

  // TODO: this is bad code left for some weird issues, fix this later
  _tasksEditDialog(
      {bool modifyWhat: false,
      bool done: false,
      bool repeat,
      int importance,
      String title,
      String description,
      String week2,
      String oldTitle,
      dynamic endtime,
      selectedTime}) {
    

    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => TaskDialog(setState, modifyWhat, done, importance, title,
            description, week2, oldTitle, endtime, selectedTime, repeat, taskViewScaffoldKey)));
  }
}
