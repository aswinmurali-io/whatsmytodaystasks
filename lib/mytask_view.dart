import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:whatsmytodaystasks/card_design.dart';

import 'custom_dialog.dart' show CustomGradientDialogForm;
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
  String dropdown = "Choose Day";
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
                                onPressed: () async {
                                  await _refreshController.requestRefresh();
                                }),
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
                          onSelected: (email) async {
                            if (email == "Add Account")
                              _accountConnectDialog();
                            // TODO: change it to switch later on
                            else if (email == "Delete Account") {
                              await pr.show();
                              await Database.deleteAccount();
                              setState(() => userTasks = {});
                              await pr.hide();
                            } else if (email == "Signout Account") {
                              await pr.show();
                              await Database.signOut();
                              setState(() => userTasks = {});
                              await pr.hide();
                            } else if (email == "Switch Google Account") {
                              await pr.show();
                              await Database.signOut();
                              userTasks.clear();
                              await Database.googleAuthDialog();
                              userTasks = await Database.download();
                              setState(() => userTasks = userTasks);
                              await pr.hide();
                            } else {
                              await pr.show();
                              await Database.signOut();
                              userTasks.clear();
                              await Database.auth(email, Database.getPassword(email), userTasks);
                              userTasks = await Database.download();
                              setState(() => userTasks = userTasks);
                              await pr.hide();
                            }
                          },
                          itemBuilder: (context) {
                            return (["Add Account"] + Database.loadAccounts())
                                .map((String choice) => PopupMenuItem<String>(
                                    value: choice,
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                            child: (() {
                                              switch (choice) {
                                                case "Add Account":
                                                  return Icon(Icons.add);
                                                case "Delete Account":
                                                  return Icon(Icons.delete);
                                                case "Signout Account":
                                                  return Icon(Icons.close);
                                                default:
                                                  return Icon(Icons.account_circle);
                                              }
                                            }())),
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
                                taskSection("Suppose to be completed yesterday", 0),

                                // Important Cards first
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == weeks.indexOf(_currentWeek) - 1)
                                    if (!userTasks[task]["done"] && userTasks[task]["importance"] == 1)
                                      taskCard(
                                          userTasks, task, setState, _tasksEditDialog, _uniqueColorIndex, __offset),

                                // Then other tasks
                                for (String task in userTasks.keys)
                                  if (userTasks[task]["week"] == weeks.indexOf(_currentWeek) - 1)
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
                                    if (userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8)
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

  _accountConnectDialog() {
    String _email, _password, _status;

    showDialog(
        barrierColor: Colors.white.withOpacity(0.02),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState2) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.black54,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light),
              child: CustomGradientDialogForm(
                title: Text("Account", style: TextStyle(color: Colors.white, fontSize: 25)),
                icon: Icon(Icons.account_box, color: Colors.white),
                content: SizedBox(
                  height: 240,
                  child: Column(
                    children: [
                      Expanded(
                          child: TextField(
                              autofillHints: [AutofillHints.email],
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => _email = value,
                              decoration: const InputDecoration(hintText: 'Enter your email'))),
                      Expanded(
                          child: TextField(
                        obscureText: true,
                        onSubmitted: (_) async {
                          if (_email != null && _password != null) {
                            // taken from https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
                            RegExp __regexEmail = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                            if (!__regexEmail.hasMatch(_email)) {
                              setState2(() => _status = "Enter a valid email address.");
                              return;
                            }
                            if (_password.length < 8) {
                              setState2(() => _status = "Password should be atleast 8 characters long.");
                              return;
                            }
                            await pr.show();
                            String errorStatus = await Database.auth(_email, _password, userTasks);
                            setState2(() => _status = "");
                            switch (errorStatus) {
                              case 'ERROR_NETWORK_REQUEST_FAILED':
                                await pr.hide();
                                setState2(() => _status = "Request Failed !");
                                return;
                              case "ERROR_WRONG_PASSWORD":
                                await pr.hide();
                                setState2(() => _status = "Wrong Password, Try again!");
                                return;
                              case "ERROR_TOO_MANY_REQUESTS":
                                await pr.hide();
                                setState2(() => _status = "Too many requests!");
                                return;
                              case "ERROR_USER_NOT_FOUND":
                              case "auth/user-not-found":
                                await pr.hide();
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      content: Text("Account not found. Do you want to create account instead ?"),
                                      actions: [
                                        GradientButton(
                                            elevation: (kIsWeb) ? 0.0 : 5.0,
                                            child: const Text("Yes"),
                                            callback: () async {
                                              await pr.show();
                                              String error = await Database.register(_email, _password);
                                              print(error);
                                              for (int i = 0; i < 3; i++) Navigator.of(context).pop();
                                              await pr.show();
                                            }),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: GradientButton(
                                              elevation: (kIsWeb) ? 0.0 : 5.0,
                                              child: const Text("No"),
                                              callback: () => Navigator.of(context).pop()),
                                        )
                                      ],
                                    ));
                                return;
                            }
                            Navigator.of(context).pop();
                            await pr.hide();
                            _refreshController.requestRefresh();
                          } else
                            setState2(() => _status = "Make sure to fill both, email and password");
                        },
                        onChanged: (value) => _password = value,
                        decoration: InputDecoration(hintText: 'Enter password'),
                      )),
                      Text(_status ?? '', style: TextStyle(color: Colors.red)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: GradientButton(
                          elevation: (kIsWeb) ? 0.0 : 5.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [Icon(Icons.account_circle), Text("Connect")]),
                          increaseWidthBy: 20,
                          callback: () async {
                            if (_email != null && _password != null) {
                              // taken from https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
                              RegExp __regexEmail = RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                              if (!__regexEmail.hasMatch(_email)) {
                                setState2(() => _status = "Enter a valid email address.");
                                return;
                              }
                              if (_password.length < 8) {
                                setState2(() => _status = "Password should be atleast 8 characters long.");
                                return;
                              }
                              await pr.show();
                              String errorStatus = await Database.auth(_email, _password, userTasks);
                              setState2(() => _status = "");
                              switch (errorStatus) {
                                case 'ERROR_NETWORK_REQUEST_FAILED':
                                  await pr.hide();
                                  setState2(() => _status = "Request Failed !");
                                  return;
                                case "ERROR_WRONG_PASSWORD":
                                  await pr.hide();
                                  setState2(() => _status = "Wrong Password, Try again!");
                                  return;
                                case "ERROR_TOO_MANY_REQUESTS":
                                  await pr.hide();
                                  setState2(() => _status = "Too many requests!");
                                  return;
                                case "ERROR_USER_NOT_FOUND":
                                case "auth/user-not-found":
                                  await pr.hide();
                                  showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        content: Text("Account not found. Do you want to create account instead ?"),
                                        actions: [
                                          GradientButton(
                                              elevation: (kIsWeb) ? 0.0 : 5.0,
                                              child: const Text("Yes"),
                                              callback: () async {
                                                await pr.show();
                                                String error = await Database.register(_email, _password);
                                                print(error);
                                                for (int i = 0; i < 3; i++) Navigator.of(context).pop();
                                                await pr.show();
                                              }),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                            child: GradientButton(
                                                elevation: (kIsWeb) ? 0.0 : 5.0,
                                                child: const Text("No"),
                                                callback: () => Navigator.of(context).pop()),
                                          )
                                        ],
                                      ));
                                  return;
                              }
                              Navigator.of(context).pop();
                              await pr.hide();
                              _refreshController.requestRefresh();
                            } else
                              setState2(() => _status = "Make sure to fill both, email and password");
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(thickness: 1),
                      ),
                      SignInButton(
                        Buttons.Google,
                        padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                        onPressed: () async {
                          await Database.googleAuthDialog();
                          Navigator.of(context).pop();
                          _refreshController.requestRefresh();
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  bool _resetOffset(int i) {
    if (i == _totalTabs) __offset = 0;
    return false;
  }

  void _tasksEditDialog(
      {bool modifyWhat: false,
      done: false,
      repeat,
      int importance,
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
      selectedTime = null;
      endtime = null;
    } else
      dropdown = week2;

    //TODO: remoev hes
    modifyWhat = modifyWhat;
    done = done;
    importance = importance;
    title = title;
    description = description;
    week2 = week2;
    oldTitle = oldTitle;
    endtime = endtime;
    selectedTime = selectedTime;

    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => TaskDialog(setState, modifyWhat, done, importance, title,
            description, week2, oldTitle, endtime, selectedTime, repeat, taskViewScaffoldKey)));
  }
}
