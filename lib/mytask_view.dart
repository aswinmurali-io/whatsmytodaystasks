import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:jiffy/jiffy.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'custom_dialog.dart' show CustomGradientDialogForm;
import 'database.dart' show Database;
import 'globals.dart';
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
  bool _showDividers = false;

  // for details
  String title, description, week = "Monday";
  Future<TimeOfDay> selectedTime;

  RefreshController _refreshController;

  final taskViewScaffoldKey = GlobalKey<ScaffoldState>();
  final _quickTaskController = TextEditingController();

  // setState() called after dispose()
  @override
  setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() => _currentWeekTabSize += 30); // trigger the scale transition for the tab
    _tabController = TabController(length: _totalTabs, vsync: this);
    _tabController.index = weeks.indexOf(_currentWeek);
    _tabController.addListener(() => setState(() => _currentWeek = weeks[_tabController.index]));
    _refreshController = RefreshController(initialRefresh: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshController.requestRefresh()); // executes after build
  }

  Future initAsync() async {
    await Database.autoconnect(userTasks);
    userTasks = await Database.download();
    await Database.resetTasks(userTasks, _currentWeek);
    setState(() => userTasks = userTasks);
  }

  @override
  dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  _accountConnectDialog() {
    String _email, _password, _status;
    showDialog(
        barrierColor: Colors.white.withOpacity(0.02),
        barrierDismissible: true,
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState2) => AnnotatedRegion<SystemUiOverlayStyle>(
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
                      height: 200,
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
                          )
                        ],
                      ),
                    ),
                  ),
                )));
  }

  // _accountInfoDialog() async {
  //   String _email = (await SharedPreferences.getInstance()).getString("email");
  //   showDialog(
  //       context: context,
  //       barrierColor: Colors.white.withOpacity(0.02),
  //       builder: (context) => StatefulBuilder(
  //           builder: (context, setState2) => AnnotatedRegion<SystemUiOverlayStyle>(
  //                 value: SystemUiOverlayStyle(
  //                     statusBarColor: Colors.black54,
  //                     statusBarIconBrightness: Brightness.dark,
  //                     systemNavigationBarColor: Colors.black54,
  //                     systemNavigationBarDividerColor: Colors.transparent,
  //                     systemNavigationBarIconBrightness: Brightness.light),
  //                 child: CustomGradientDialogForm(
  //                     title: Text("Account Details", style: TextStyle(fontSize: 20, color: Colors.white)),
  //                     icon: Icon(Icons.account_box, color: Colors.white),
  //                     content: SizedBox(
  //                       height: 100,
  //                       child: Column(
  //                         children: [
  //                           Text("Email\n$_email"),
  //                           Padding(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //                               GradientButton(
  //                                 child: Text("Signout"),
  //                                 elevation: (kIsWeb) ? 0.0 : 5.0,
  //                                 callback: () async {
  //                                   await pr.show();
  //                                   await Database.signOut();
  //                                   Navigator.of(context).pop();
  //                                   await pr.hide();
  //                                 },
  //                               ),
  //                               GradientButton(
  //                                 child: Text("Delete Account"),
  //                                 increaseWidthBy: 40,
  //                                 elevation: (kIsWeb) ? 0.0 : 5.0,
  //                                 callback: () async {
  //                                   await pr.show();
  //                                   await Database.deleteAccount();
  //                                   Navigator.of(context).pop();
  //                                   await pr.hide();
  //                                 },
  //                               ),
  //                             ]),
  //                           )
  //                         ],
  //                       ),
  //                     )),
  //               )));
  // }

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

  bool _resetOffset(int i) {
    if (i == _totalTabs) __offset = 0;
    return false;
  }

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
                            } else {
                              await pr.show();
                              await Database.deleteAccount();
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
            body: TabBarView(controller: _tabController, physics: const BouncingScrollPhysics(), children: [
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
                      setState(() => _showDividers = true);
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          Visibility(
                            visible: _showDividers,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: FadeInLeft(
                                preferences: AnimationPreferences(
                                    duration: const Duration(milliseconds: 300), offset: const Duration(seconds: 1)),
                                child: Row(children: [
                                  Text("Pending",
                                      style: TextStyle(
                                          foreground: Paint()..shader = textGradientShader,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const Expanded(child: const Padding(padding: EdgeInsets.zero)),
                                ]),
                              ),
                            ),
                          ),

                          // All Tasks
                          for (String task in userTasks.keys)
                            if (_tabController.index == 9 && !userTasks[task]["done"])
                              SizedBox(
                                width: (kIsWeb) ? 500 : double.infinity,
                                child: BounceIn(
                                  preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [BoxShadow(color: Colors.blueGrey[200], blurRadius: 10.0)],
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: autoGenerateColorCard[_uniqueColorIndex++],
                                        ),
                                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: ListTileTheme(
                                        iconColor: Colors.white,
                                        textColor: Colors.white,
                                        child: ListTile(
                                          title: Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                            child: Text(task, style: TextStyle(fontSize: 20)),
                                          ),
                                          subtitle: Row(
                                            verticalDirection: VerticalDirection.up,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(child: Text(userTasks[task]['description'])),
                                              Card(
                                                elevation: 0,
                                                color: Colors.black12,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    (userTasks[task]['time'] == userTasks[task]['endtime'])
                                                        ? "${userTasks[task]['time']}"
                                                        : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Checkbox(
                                                  value: userTasks[task]['done'],
                                                  onChanged: (value) {
                                                    setState(() => userTasks[task]['done'] = value);
                                                    //_storage.setString("data", jsonEncode(userTasks));
                                                    Database.upload(userTasks);
                                                  })
                                            ],
                                          ),
                                          isThreeLine: true,
                                          onTap: () => _tasksEditDialog(
                                            modifyWhat: true,
                                            title: task,
                                            oldTitle: task,
                                            repeat: userTasks[task]["repeat"],
                                            importance: userTasks[task]["importance"],
                                            description: userTasks[task]["description"],
                                            week2: weeks[userTasks[task]["week"]],
                                            selectedTime: userTasks[task]["time"],
                                            done: userTasks[task]["done"],
                                            endtime: userTasks[task]["endtime"],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                          // Important Cards first
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index)
                              if (!userTasks[task]["done"] && userTasks[task]["importance"] == 1)
                                SizedBox(
                                  width: (kIsWeb) ? 500 : double.infinity,
                                  child: BounceIn(
                                    preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [BoxShadow(color: Colors.blueGrey[200], blurRadius: 10.0)],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: autoGenerateColorCard[_uniqueColorIndex++],
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        ),
                                        child: ListTileTheme(
                                          iconColor: Colors.white,
                                          textColor: Colors.white,
                                          child: ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                              child: Text(task, style: TextStyle(fontSize: 20)),
                                            ),
                                            subtitle: Row(
                                              verticalDirection: VerticalDirection.up,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(child: Text(userTasks[task]['description'])),
                                                Card(
                                                  elevation: 0,
                                                  color: Colors.black12,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      (userTasks[task]['time'] == userTasks[task]['endtime'])
                                                          ? "${userTasks[task]['time']}"
                                                          : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Checkbox(
                                                    value: userTasks[task]['done'],
                                                    onChanged: (value) {
                                                      setState(() => userTasks[task]['done'] = value);
                                                      //_storage.setString("data", jsonEncode(userTasks));
                                                      Database.upload(userTasks);
                                                    })
                                              ],
                                            ),
                                            isThreeLine: true,
                                            onTap: () => _tasksEditDialog(
                                              modifyWhat: true,
                                              title: task,
                                              oldTitle: task,
                                              repeat: userTasks[task]["repeat"],
                                              importance: userTasks[task]["importance"],
                                              description: userTasks[task]["description"],
                                              week2: weeks[userTasks[task]["week"]],
                                              selectedTime: userTasks[task]["time"],
                                              done: userTasks[task]["done"],
                                              endtime: userTasks[task]["endtime"],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          // Then other tasks
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index)
                              if (!userTasks[task]["done"] && userTasks[task]["importance"] == 0)
                                SizedBox(
                                  width: (kIsWeb) ? 500 : double.infinity,
                                  child: BounceIn(
                                    preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [BoxShadow(color: Colors.blueGrey[200], blurRadius: 10.0)],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: autoGenerateColorCard[_uniqueColorIndex++],
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        ),
                                        child: ListTileTheme(
                                          iconColor: Colors.white,
                                          textColor: Colors.white,
                                          child: ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                              child: Text(task, style: TextStyle(fontSize: 20)),
                                            ),
                                            subtitle: Row(
                                              verticalDirection: VerticalDirection.up,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(child: Text(userTasks[task]['description'])),
                                                Card(
                                                  elevation: 0,
                                                  color: Colors.black12,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      (userTasks[task]['time'] == userTasks[task]['endtime'])
                                                          ? "${userTasks[task]['time']}"
                                                          : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Checkbox(
                                                    value: userTasks[task]['done'],
                                                    onChanged: (value) {
                                                      setState(() => userTasks[task]['done'] = value);
                                                      Database.upload(userTasks);
                                                    })
                                              ],
                                            ),
                                            isThreeLine: true,
                                            onTap: () => _tasksEditDialog(
                                                modifyWhat: true,
                                                title: task,
                                                oldTitle: task,
                                                repeat: userTasks[task]["repeat"],
                                                importance: userTasks[task]["importance"],
                                                description: userTasks[task]["description"],
                                                week2: weeks[userTasks[task]["week"]],
                                                selectedTime: userTasks[task]["time"],
                                                done: userTasks[task]["done"],
                                                endtime: userTasks[task]["endtime"]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          if (_tabController.index != 7 && _tabController.index != 8 && _tabController.index != 9)
                            Visibility(
                              visible: _showDividers,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 13, 0, 10),
                                child: FadeInLeft(
                                  preferences: AnimationPreferences(
                                      duration: const Duration(milliseconds: 300),
                                      offset: const Duration(milliseconds: 500)),
                                  child: Row(children: [
                                    Text(
                                      "All Days & Any days",
                                      style: TextStyle(
                                          foreground: Paint()..shader = textGradientShader,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20),
                                    ),
                                    const Expanded(child: const Padding(padding: EdgeInsets.zero)),
                                  ]),
                                ),
                              ),
                            ),

                          // All day and any day tasks
                          if (_tabController.index != 7 && _tabController.index != 8)
                            for (String task in userTasks.keys)
                              if (userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8)
                                if (!userTasks[task]["done"])
                                  SizedBox(
                                    width: (kIsWeb) ? 500 : double.infinity,
                                    child: BounceIn(
                                      preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [BoxShadow(color: Colors.blueGrey[200], blurRadius: 10.0)],
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: GradientColors.aqua,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                                          ),
                                          child: ListTileTheme(
                                            iconColor: Colors.white,
                                            textColor: Colors.white,
                                            child: ListTile(
                                              title: Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                child: Text(task, style: TextStyle(fontSize: 20)),
                                              ),
                                              subtitle: Row(
                                                verticalDirection: VerticalDirection.up,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(child: Text(userTasks[task]['description'])),
                                                  Card(
                                                    elevation: 0,
                                                    color: Colors.black12,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Text(
                                                        (userTasks[task]['time'] == userTasks[task]['endtime'])
                                                            ? "${userTasks[task]['time']}"
                                                            : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Checkbox(
                                                      value: userTasks[task]['done'],
                                                      onChanged: (value) {
                                                        setState(() => userTasks[task]['done'] = value);
                                                        Database.upload(userTasks);
                                                      })
                                                ],
                                              ),
                                              isThreeLine: true,
                                              onTap: () => _tasksEditDialog(
                                                  modifyWhat: true,
                                                  title: task,
                                                  oldTitle: task,
                                                  repeat: userTasks[task]["repeat"],
                                                  importance: userTasks[task]["importance"],
                                                  description: userTasks[task]["description"],
                                                  week2: weeks[userTasks[task]["week"]],
                                                  selectedTime: userTasks[task]["time"],
                                                  done: userTasks[task]["done"],
                                                  endtime: userTasks[task]["endtime"]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          Visibility(
                            visible: _showDividers,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: FadeInLeft(
                                preferences: AnimationPreferences(
                                    offset: const Duration(milliseconds: 500),
                                    duration: const Duration(milliseconds: 300)),
                                child: Row(children: [
                                  Text(
                                    "Completed",
                                    style: TextStyle(
                                        foreground: Paint()..shader = textGradientShader,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20),
                                  ),
                                  const Expanded(child: const Padding(padding: EdgeInsets.zero)),
                                ]),
                              ),
                            ),
                          ),

                          // Task that are already done will be grey with strike text
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == _tabController.index ||
                                userTasks[task]["week"] == 7 ||
                                userTasks[task]["week"] == 8)
                              if (userTasks[task]["done"])
                                SizedBox(
                                  width: (kIsWeb) ? 500 : double.infinity,
                                  child: BounceIn(
                                    preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 10)),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
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
                                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        ),
                                        child: ListTileTheme(
                                          iconColor: Colors.white,
                                          textColor: Colors.grey,
                                          child: ListTile(
                                            title: Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                child: Text(task,
                                                    style: TextStyle(
                                                        fontSize: 20, decoration: TextDecoration.lineThrough))),
                                            subtitle: Row(
                                              verticalDirection: VerticalDirection.up,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                    child: Text(userTasks[task]['description'],
                                                        style: TextStyle(decoration: TextDecoration.lineThrough))),
                                                Card(
                                                  elevation: 0,
                                                  color: Colors.black12,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      (userTasks[task]['time'] == userTasks[task]['endtime'])
                                                          ? "${userTasks[task]['time']}"
                                                          : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Checkbox(
                                                    value: userTasks[task]['done'],
                                                    onChanged: (value) {
                                                      setState(() => userTasks[task]['done'] = value);
                                                      // _storage.setString("data", jsonEncode(userTasks));
                                                      Database.upload(userTasks);
                                                    })
                                              ],
                                            ),
                                            isThreeLine: true,
                                            onTap: () => _tasksEditDialog(
                                                modifyWhat: true,
                                                title: task,
                                                oldTitle: task,
                                                repeat: userTasks[task]["repeat"],
                                                importance: userTasks[task]["importance"],
                                                description: userTasks[task]["description"],
                                                week2: weeks[userTasks[task]["week"]],
                                                selectedTime: userTasks[task]["time"],
                                                done: userTasks[task]["done"],
                                                endtime: userTasks[task]["endtime"]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                    child: Material(
                      elevation: 5.0,
                      shadowColor: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(25.7),
                      child: TextField(
                        autofocus: false,
                        enableSuggestions: true,
                        controller: _quickTaskController,
                        onSubmitted: (value) => setState(() {
                          userTasks.addAll({
                            value: {
                              "time": "Any Time",
                              "endtime": "Any Time",
                              "notify": true,
                              "description": description ?? '',
                              "image": null,
                              "importance": 0,
                              "repeat": false,
                              "done": false,
                              "week": (_tabController.index < 9)
                                  ? _tabController.index
                                  : week.indexOf(Jiffy(DateTime.now()).EEEE)
                            },
                          });
                          _quickTaskController.clear();
                        }),
                        decoration: InputDecoration(
                          hintText: ' Add Quick Task',
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(25.7)),
                        ),
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
}
