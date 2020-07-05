import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_dialog.dart';
import 'database.dart';
import 'globals.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  TextEditingController _textFieldTaskController;
  TextEditingController _textFieldDescriptionController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  final _totalTabs = 9;
  int _uniqueColorIndex;
  int __offset;
  String dropdown = "Choose Day";
  ProgressDialog pr;
  bool _showDividers = false;

  // for details
  String title, description, week = "Monday";
  Future<TimeOfDay> selectedTime;

  RefreshController _refreshController;

  // setState() called after dispose()
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() => _currentWeekTabSize += 30); // trigger the scale transition for the tab
    _tabController = TabController(length: _totalTabs, vsync: this);
    _tabController.index = weeks.indexOf(_currentWeek);
    _tabController.addListener(() => setState(() => _currentWeek = weeks[_tabController.index]));
    _refreshController = RefreshController(initialRefresh: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshController.requestRefresh()); // executes after build
  }

  Future<void> initAsync() async {
    await Database.autoconnect();
    userTasks = await Database.download();
    await Database.resetTasks(userTasks, _currentWeek);
    setState(() => userTasks = userTasks);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
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

  void _accountConnectDialog() {
    String _email, _password, _status;
    // TODO: add a loading thing when auth
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState2) => CustomGradientDialogForm(
                  title: Text("Account", style: TextStyle(color: Colors.white, fontSize: 25)),
                  icon: Icon(Icons.account_box, color: Colors.white),
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                            child: TextField(
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
                        GradientButton(
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
                              await Database.auth(_email, _password);
                              Navigator.of(context).pop();
                              await pr.hide();
                            } else
                              setState2(() => _status = "Make sure to fill both, email and password");
                          },
                        )
                      ],
                    ),
                  ),
                )));
  }

  void _accountInfoDialog() async {
    String _email = (await SharedPreferences.getInstance()).getString("email");
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState2) => CustomGradientDialogForm(
                title: Text("Account Details", style: TextStyle(fontSize: 20, color: Colors.white)),
                icon: Icon(Icons.account_box, color: Colors.white),
                content: SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      Text("Email\n$_email"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          GradientButton(
                            child: Text("Signout"),
                            callback: () async {
                              await pr.show();
                              await Database.signOut();
                              // update it in UI, not handled by database
                              setState2(() => userTasks = {});
                              Navigator.of(context).pop();
                              await pr.hide();
                            },
                          ),
                          GradientButton(
                            child: Text("Delete Account"),
                            increaseWidthBy: 40,
                            callback: () async {
                              await pr.show();
                              await Database.deleteAccount();
                              // update it in UI, not handled by database
                              setState2(() => userTasks = {});
                              Navigator.of(context).pop();
                              await pr.hide();
                            },
                          ),
                        ]),
                      )
                    ],
                  ),
                ))));
  }

  void _tasksEditDialog(
      {bool modifyWhat: false,
      bool done: false,
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
      week = _currentWeek;
      dropdown = _currentWeek;
    } else
      dropdown = week2;

    _textFieldTaskController = TextEditingController(text: title);
    _textFieldDescriptionController = TextEditingController(text: description);

    int _importance = importance ?? 0;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState2) => CupertinoScrollbar(
                  child: SingleChildScrollView(
                    child: CustomGradientDialogForm(
                      title: Text((modifyWhat) ? "Edit Task" : "New Task",
                          style: TextStyle(color: Colors.white, fontSize: 25)),
                      content: Column(
                        children: [
                          const Text("What's the task ?"),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                            child: Expanded(
                                child: TextField(
                                    controller: _textFieldTaskController,
                                    autocorrect: true,
                                    cursorColor: Colors.red,
                                    maxLines: 1,
                                    enableSuggestions: true,
                                    maxLength: 40,
                                    onChanged: (value) => title = value)),
                          ),
                          const Text("Something else to remember with it?"),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                            child: Expanded(
                                child: TextField(
                                    controller: _textFieldDescriptionController,
                                    autocorrect: true,
                                    cursorColor: Colors.red,
                                    maxLines: 1,
                                    autofocus: true,
                                    enableSuggestions: true,
                                    maxLength: 30,
                                    onChanged: (value) => description = value)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Pick a day"),
                              DropdownButton(
                                  value: dropdown,
                                  items: (weeks + ["Tomorrow"])
                                          .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                                          .toList() +
                                      [],
                                  onChanged: (value) {
                                    week = value;
                                    setState2(() => dropdown = value);
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Is this task very important ? "),
                              Checkbox(
                                  value: (_importance == 0) ? false : true,
                                  onChanged: (bool value) => setState2(() => _importance = (value) ? 1 : 0))
                            ],
                          ),
                          ExpansionTile(
                            title: Text("Time"),
                            children: [
                              SingleChildScrollView(
                                child: Wrap(children: [
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
                                          callback: () => selectedTime =
                                              showTimePicker(context: context, initialTime: TimeOfDay.now())),
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
                                          callback: () =>
                                              endtime = showTimePicker(context: context, initialTime: TimeOfDay.now())),
                                    ],
                                  ),
                                ]),
                              )
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
                                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                                    callback: () async {
                                      if (week != null &&
                                          _textFieldTaskController.text.replaceAll(RegExp(r'\s'), '').length != 0) {
                                        TimeOfDay _awaitedTime, _awaitedTime2;
                                        if (selectedTime is String && selectedTime != "Any Time") {
                                          DateTime dateTimeFromString = DateFormat.jm().parse(selectedTime);
                                          selectedTime = TimeOfDay(
                                              hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
                                          _awaitedTime = selectedTime;
                                        } else if (selectedTime is Future<TimeOfDay>) {
                                          _awaitedTime = (await selectedTime);
                                        }

                                        if (endtime is String && endtime != "Any Time") {
                                          DateTime dateTimeFromString = DateFormat.jm().parse(endtime);
                                          endtime = TimeOfDay(
                                              hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
                                          _awaitedTime2 = endtime;
                                        } else if (endtime is Future<TimeOfDay>) {
                                          _awaitedTime2 = (await endtime);
                                        }
                                        // if modifiying then first check if key present else make one
                                        setState(() {
                                          if (modifyWhat && userTasks.containsKey(oldTitle)) userTasks.remove(oldTitle);
                                          userTasks.addAll({
                                            title: {
                                              "time": (_awaitedTime != null)
                                                  ? "${(_awaitedTime.hour > 12) ? _awaitedTime.hour - 12 : _awaitedTime.hour}:${(_awaitedTime.minute < 10) ? '0${_awaitedTime.minute}' : _awaitedTime.minute} ${(_awaitedTime.period.index == 1) ? 'PM' : 'AM'}"
                                                  : "Any Time",
                                              "endtime": (_awaitedTime2 != null)
                                                  ? "${(_awaitedTime2.hour > 12) ? _awaitedTime2.hour - 12 : _awaitedTime2.hour}:${(_awaitedTime2.minute < 10) ? '0${_awaitedTime2.minute}' : _awaitedTime2.minute} ${(_awaitedTime2.period.index == 1) ? 'PM' : 'AM'}"
                                                  : "Any Time",
                                              "notify": true,
                                              "description": description ?? '',
                                              "image": null,
                                              "importance": _importance,
                                              "repeat": false,
                                              "done": (!modifyWhat) ? false : done,
                                              "week": (dropdown == "Tomorrow")
                                                  ? ((_currentWeek == "Sunday") ? 0 : weeks.indexOf(_currentWeek) + 1)
                                                  : weeks.indexOf(week)
                                            },
                                          });
                                        });
                                        // save locally & also cloud
                                        //_storage.setString("data", jsonEncode(userTasks));
                                        Database.upload(userTasks);

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
                                    child: const Text("Delete", style: TextStyle(color: Colors.white)),
                                    callback: () {
                                      setState(() => userTasks.remove(title));
                                      //_storage.setString("data", jsonEncode(userTasks));
                                      Database.upload(userTasks);
                                      Navigator.of(context).pop();
                                    },
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                      titleBackground: Colors.red,
                      contentBackground: Colors.white,
                      icon: const Icon(Icons.edit, color: Colors.white, size: 25),
                    ),
                  ),
                )));
  }

  bool _resetOffset(int i) {
    if (i == _totalTabs) __offset = 0;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    __offset = 200;
    _uniqueColorIndex = 0;
    pr = ProgressDialog(context);
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
                // Padding(
                //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                //     // sync button
                //     child: CircleAvatar(
                //       radius: 16.0,
                //       backgroundColor: Colors.red,
                //       child: IconButton(
                //           tooltip: 'Sync',
                //           icon: const Icon(Icons.sync, size: 17.0),
                //           color: Colors.white,
                //           onPressed: () async {
                //             await pr.show();
                //             userTasks = await Database.download();
                //             setState(() => userTasks = userTasks);
                //             await pr.hide();
                //           }),
                //     )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                    // profile button
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                          tooltip: "Profile",
                          icon: const Icon(Icons.account_circle),
                          color: Colors.white,
                          onPressed: () async {
                            if ((await SharedPreferences.getInstance()).getString("email") == null)
                              _accountConnectDialog();
                            else
                              _accountInfoDialog();
                          }),
                    )),
              ],
              title: const Text("What's my today's tasks ?"),
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
                    await initAsync();
                    _refreshController.refreshCompleted();
                    setState(() => _showDividers = true);
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(15, 15, 10, 0),
                    child: Column(
                      children: [
                        Visibility(
                          visible: _showDividers,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: FadeInLeft(
                              preferences: AnimationPreferences(
                                  duration: const Duration(milliseconds: 300),
                                  offset: const Duration(milliseconds: 500)),
                              child: Row(children: [
                                Text("Pending",
                                    style: TextStyle(
                                        foreground: Paint()..shader = textGradientShader,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child: Divider(color: Colors.deepOrange))),
                              ]),
                            ),
                          ),
                        ),
                        // Important Cards first
                        for (String task in userTasks.keys)
                          if (userTasks[task]["week"] == _tabController.index)
                            if (!userTasks[task]["done"] && userTasks[task]["importance"] == 1)
                              BounceIn(
                                preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                        // Then other tasks
                        for (String task in userTasks.keys)
                          if (userTasks[task]["week"] == _tabController.index)
                            if (!userTasks[task]["done"] && userTasks[task]["importance"] == 0)
                              BounceIn(
                                preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                        if (_tabController.index != 7 && _tabController.index != 8)
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
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Divider(color: Colors.deepOrange))),
                                ]),
                              ),
                            ),
                          ),
                        // All day and any day tasks
                        if (_tabController.index != 7 && _tabController.index != 8)
                          for (String task in userTasks.keys)
                            if (userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8)
                              if (!userTasks[task]["done"])
                                BounceIn(
                                  preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 50)),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                                const Expanded(
                                    child: const Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child: Divider(color: Colors.deepOrange))),
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
                              BounceIn(
                                preferences: AnimationPreferences(offset: Duration(milliseconds: __offset += 10)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                                                style:
                                                    TextStyle(fontSize: 20, decoration: TextDecoration.lineThrough))),
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
                        // To give space for showing the last card's edit button
                        const Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 73))
                      ],
                    ),
                  ),
                ),
              )
          ]),
          floatingActionButton: RotateIn(
            preferences: AnimationPreferences(
                duration: const Duration(milliseconds: 300), offset: const Duration(milliseconds: 500)),
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
