import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import 'custom_dialog.dart';
import 'database.dart';
import 'globals.dart';

/*
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, __) =>
        TaskDialog(**)));
 */

class TaskDialog extends StatefulWidget {
  final setState2, taskViewScaffoldKey;

  final bool modifyWhat, done, repeat;
  final int importance;
  final String title, description, week2, oldTitle;
  final dynamic endtime, selectedTime;

  TaskDialog(this.setState2, this.modifyWhat, this.done, this.importance, this.title, this.description, this.week2,
      this.oldTitle, this.endtime, this.selectedTime, this.repeat, this.taskViewScaffoldKey);

  @override
  createState() => _TaskDialogState(setState2, modifyWhat, done, importance, title, description, week2, oldTitle,
      endtime, selectedTime, repeat, taskViewScaffoldKey);
}

class _TaskDialogState extends State<TaskDialog> {
  int _importance;
  TextEditingController _textFieldTaskController;
  TextEditingController _textFieldDescriptionController;

  final setState2, taskViewScaffoldKey;

  bool modifyWhat, done, repeat;
  int importance;
  String title, description, week2, oldTitle;
  dynamic endtime, selectedTime;
  TimeOfDay _awaitedTime, _awaitedTime2; // String, TimeOfDay

  Map _undo = {};

  String _currentWeek, dropdown, week;

  static ScrollController scrollController = ScrollController();

  final _taskFocusNode = _attachFocusNodeForAutoscroll(scrollController, 0);
  final _descFocusNode = _attachFocusNodeForAutoscroll(scrollController, 40);
  final _dropdownFocusNode = _attachFocusNodeForAutoscroll(scrollController, 100);

  _TaskDialogState(this.setState2, this.modifyWhat, this.done, this.importance, this.title, this.description,
      this.week2, this.oldTitle, this.endtime, this.selectedTime, this.repeat, this.taskViewScaffoldKey);

  @override
  initState() {
    super.initState();
    _textFieldTaskController = TextEditingController(text: title);
    _textFieldDescriptionController = TextEditingController(text: description);
    _importance = importance ?? 0;
    if (modifyWhat)
      _currentWeek = dropdown = week = week2;
    else {
      _currentWeek = dropdown = week = Jiffy(DateTime.now()).EEEE;
      repeat = false;
      _taskFocusNode.requestFocus();
    }
  }

  static FocusNode _attachFocusNodeForAutoscroll(ScrollController scrollController, double offset) {
    FocusNode _focusNode = FocusNode();
    _focusNode.addListener(
        () => scrollController.animateTo(offset, duration: Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn));
    return _focusNode;
  }

  @override
  dispose() {
    _textFieldTaskController.dispose();
    _textFieldDescriptionController.dispose();
    super.dispose();
  }

  save() async {
    if (week != null && _textFieldTaskController.text.replaceAll(RegExp(r'\s'), '').length != 0) {
      TimeOfDay _awaitedTime, _awaitedTime2;
      if (selectedTime is String && selectedTime != "Any Time") {
        DateTime dateTimeFromString = DateFormat.jm().parse(selectedTime);
        selectedTime = TimeOfDay(hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
        _awaitedTime = selectedTime;
      } else if (selectedTime is Future<TimeOfDay>) {
        _awaitedTime = (await selectedTime);
      }

      if (endtime is String && endtime != "Any Time") {
        DateTime dateTimeFromString = DateFormat.jm().parse(endtime);
        endtime = TimeOfDay(hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
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
            "repeat": repeat,
            "done": (!modifyWhat) ? false : done,
            "week": (dropdown == "Tomorrow")
                ? ((_currentWeek == "Sunday") ? 0 : weeks.indexOf(_currentWeek) + 1)
                : weeks.indexOf(week)
          },
        });
      });
      Database.upload(userTasks);
      Navigator.of(context).pop();
      setState2(() => userTasks = userTasks);
    }
  }

  delete() {
    _undo = userTasks[title];
    setState2(() => userTasks.remove(title));
    Database.upload(userTasks);
    Navigator.of(context).pop();
    taskViewScaffoldKey.currentState.showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Deleted task"),
        OutlineButton(
            child: const Text("Undo"),
            onPressed: () {
              userTasks.addAll({title: _undo});
              setState2(() => userTasks);
              Database.upload(userTasks);
              taskViewScaffoldKey.currentState.hideCurrentSnackBar();
            })
      ]),
    ));
  }

  @override
  build(BuildContext context) {
    //List<String> _weeks = weeks;
    //_weeks.remove("All Tasks");
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black54.withOpacity(0.55),
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light),
      child: CustomGradientDialogForm(
        title: Text((modifyWhat) ? "Edit Task" : "New Task", style: TextStyle(color: Colors.white, fontSize: 25)),
        content: SizedBox(
          height: 350,
          child: CupertinoScrollbar(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("What's the task ?"),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: TextField(
                        controller: _textFieldTaskController,
                        focusNode: _taskFocusNode,
                        autocorrect: true,
                        cursorColor: Colors.red,
                        maxLines: 1,
                        enableSuggestions: true,
                        maxLength: 40,
                        onSubmitted: (_) {
                          scrollController.animateTo(
                            10.0,
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 300),
                          );
                          _descFocusNode.requestFocus();
                        },
                        onChanged: (value) => title = value),
                  ),
                  const Text("Something else to remember with it?"),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: TextField(
                        controller: _textFieldDescriptionController,
                        focusNode: _descFocusNode,
                        autocorrect: true,
                        cursorColor: Colors.red,
                        maxLines: 1,
                        enableSuggestions: true,
                        maxLength: 30,
                        onSubmitted: (_) => _dropdownFocusNode.requestFocus(),
                        onChanged: (value) => description = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pick a day"),
                      DropdownButton(
                          value: dropdown,
                          focusNode: _dropdownFocusNode,
                          items: (weeks + ["Tomorrow"])
                                  .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                                  .toList() +
                              [],
                          onChanged: (value) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            week = value;
                            setState(() => dropdown = value);
                          }),
                    ],
                  ),
                  Row(children: [
                    const Text("Important task"),
                    Checkbox(
                        value: (_importance == 0) ? false : true,
                        onChanged: (bool value) => setState(() => _importance = (value) ? 1 : 0))
                  ]),
                  Row(children: [
                    const Text("Repeat task every week"),
                    Checkbox(value: repeat, onChanged: (value) => setState(() => repeat = value))
                  ]),
                  ExpansionTile(
                    title: Text("Time"),
                    onExpansionChanged: (value) => Future.delayed(
                        const Duration(milliseconds: 300),
                        () => scrollController.animateTo(300,
                            duration: const Duration(milliseconds: 100), curve: Curves.bounceIn)),
                    children: [
                      SingleChildScrollView(
                        child: Wrap(children: [
                          const Text(
                              "if you already set the time and want to remove it. Open the time selector and just press cancel"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Set the start time" +
                                    ((_awaitedTime != null)
                                        ? ", ${(_awaitedTime.hour > 12) ? _awaitedTime.hour - 12 : _awaitedTime.hour}:${(_awaitedTime.minute < 10) ? '0${_awaitedTime.minute}' : _awaitedTime.minute} ${(_awaitedTime.period.index == 1) ? 'PM' : 'AM'}"
                                        : ''),
                              ),
                              GradientButton(
                                  shadowColor: Colors.black26,
                                  elevation: (kIsWeb) ? 0.0 : 6.0,
                                  shapeRadius: BorderRadius.circular(10),
                                  gradient: Gradients.blush,
                                  increaseWidthBy: 40,
                                  child: Text("Choose Start Time"),
                                  callback: () => setState(() async {
                                        selectedTime = showTimePicker(context: context, initialTime: TimeOfDay.now());
                                        _awaitedTime = await selectedTime ?? '';
                                        setState(() => _awaitedTime = _awaitedTime);

                                        FocusScope.of(context).requestFocus(FocusNode());
                                        Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () => scrollController.animateTo(300,
                                                duration: const Duration(milliseconds: 100), curve: Curves.bounceIn));
                                      })),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Set the end time" +
                                    ((_awaitedTime2 != null)
                                        ? ", ${(_awaitedTime2.hour > 12) ? _awaitedTime2.hour - 12 : _awaitedTime2.hour}:${(_awaitedTime2.minute < 10) ? '0${_awaitedTime2.minute}' : _awaitedTime2.minute} ${(_awaitedTime2.period.index == 1) ? 'PM' : 'AM'}"
                                        : ''),
                              ),
                              GradientButton(
                                  shadowColor: Colors.black26,
                                  elevation: (kIsWeb) ? 0.0 : 6.0,
                                  shapeRadius: BorderRadius.circular(10),
                                  gradient: Gradients.blush,
                                  increaseWidthBy: 40,
                                  child: Text("Choose End Time"),
                                  callback: () async {
                                    endtime = showTimePicker(context: context, initialTime: TimeOfDay.now());
                                    _awaitedTime2 = await endtime ?? '';
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    setState(() => _awaitedTime2 = _awaitedTime2);
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => scrollController.animateTo(300,
                                            duration: const Duration(milliseconds: 100), curve: Curves.bounceIn));
                                  }),
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
                            elevation: (kIsWeb) ? 0.0 : 6.0,
                            shapeRadius: BorderRadius.circular(10),
                            gradient: Gradients.coldLinear,
                            increaseWidthBy: 20,
                            child: const Text("Save", style: TextStyle(color: Colors.white)),
                            callback: save),
                        if (modifyWhat)
                          GradientButton(
                            shadowColor: Colors.black26,
                            elevation: (kIsWeb) ? 0.0 : 6.0,
                            shapeRadius: BorderRadius.circular(10),
                            gradient: Gradients.aliHussien,
                            increaseWidthBy: 20,
                            child: const Text("Delete", style: TextStyle(color: Colors.white)),
                            callback: delete,
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        titleBackground: Colors.red,
        contentBackground: Colors.white,
        icon: const Icon(Icons.edit, color: Colors.white, size: 25),
      ),
    );
  }
}
