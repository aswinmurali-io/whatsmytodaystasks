import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:jiffy/jiffy.dart';

import 'database.dart';
import 'globals.dart';

List<bool> _visibility = [false, false, false, false];
int isGrid;
bool showYesterday;

bool smartShowSections(StateSetter setStateFromTaskView, int tabIndex, String _currentWeek) {
  // TODO: Make the code cleaner
  List _check = [];
  if (tabIndex == 9)
    return false;
  else if (tabIndex == 8 || tabIndex == 7) {
    for (String task in userTasks.keys)
      if (!userTasks[task]["done"] && userTasks[task]["week"] == tabIndex) _check.add(task);
    if (_check.isNotEmpty)
      setStateFromTaskView(() => _visibility[1] = true);
    else
      setStateFromTaskView(() => _visibility[1] = false);
    _check.clear();
    for (String task in userTasks.keys)
      if (userTasks[task]["done"] && userTasks[task]["week"] == tabIndex) _check.add(task);
    if (_check.isNotEmpty)
      setStateFromTaskView(() => _visibility[3] = true);
    else
      setStateFromTaskView(() => _visibility[3] = false);
    return (_visibility[1] == true || _visibility[3] == true) ? false : true;
  } // display all tasks page

  // check how many tasks are there for different section and then display the necessary sections
  for (String task in userTasks.keys)
    if (!userTasks[task]["done"] &&
        userTasks[task]["week"] == tabIndex - 1 &&
        weeks.indexOf(Jiffy(DateTime.now()).EEEE) == tabIndex) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[0] = true);
  else
    _visibility[0] = false;
  _check.clear();

  for (String task in userTasks.keys)
    if (!userTasks[task]["done"] &&
        userTasks[task]["week"] == tabIndex &&
        tabIndex != 7 &&
        tabIndex != 8 &&
        tabIndex != 9) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[1] = true);
  // TODO: not needed right?
  else
    _visibility[1] = false;
  _check.clear();

  for (String task in userTasks.keys)
    if ((userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8) &&
        tabIndex != 7 &&
        tabIndex != 8 &&
        tabIndex != 9 &&
        !userTasks[task]["done"]) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[2] = true);
  else
    _visibility[2] = false;
  _check.clear();

  for (String task in userTasks.keys)
    if (userTasks[task]["done"] &&
        (userTasks[task]["week"] == tabIndex &&
            userTasks[task]["week"] != 7 &&
            userTasks[task]["week"] != 8 &&
            userTasks[task]["week"] != 9)) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[3] = true);
  else
    _visibility[3] = false;
  _check.clear();
  return (_visibility[0] == false && _visibility[1] == false && _visibility[2] == false && _visibility[3] == false)
      ? true
      : false;
}

bool taskCardBool = true;

Widget taskCard(Map userTasks, String task, StateSetter setStateFromTaskView, dynamic tasksEditDialog,
    int uniqueColorIndex, int offset) {
  return Visibility(
    visible: taskCardBool,
    child: SizedBox(
      width: (() {
        switch (isGrid) {
          case 0:
            return null;
          case 1:
            return 300.0 + (task.length.toDouble() * 7.0);
          case 2:
            return 700.0;
          default:
            return null;
        }
      }()),
      child: FadeIn(
        preferences:
            AnimationPreferences(offset: Duration(milliseconds: offset += 50), duration: Duration(milliseconds: 500)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.blueGrey[200], blurRadius: 10.0)],
              gradient: (userTasks[task]["done"])
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: GradientColors.grey,
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: getNextGradient()),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              onTap: () => tasksEditDialog(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          task ?? "Unknown Task",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.white, fontSize: 23),
                        ),
                        if (userTasks[task]['description'] != null && userTasks[task]['description'] != '')
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              userTasks[task]['description'] ?? "",
                              textAlign: TextAlign.start,
                              softWrap: true,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        if (userTasks[task]['description'] == null || userTasks[task]['description'] == '')
                          Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        // hide time label if task has no deadline
                        if ((userTasks[task]['time'] != "Any Time" && userTasks[task]['endtime'] != "Any Time") ||
                            userTasks[task]['time'] != "Any Time" ||
                            userTasks[task]['endtime'] != "Any Time")
                          Wrap(
                            children: [
                              Card(
                                elevation: 10,
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer, color: Colors.white, size: 17),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(
                                          (userTasks[task]['time'] == userTasks[task]['endtime'])
                                              ? "${userTasks[task]['time']}"
                                              : "${userTasks[task]['time']} ${(userTasks[task]['endtime'] != 'Any Time') ? '- ${userTasks[task]['endtime']}' : ''}",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (userTasks[task]["importance"] == 1)
                                SizedBox(
                                  width: 96,
                                  child: Card(
                                      elevation: 10,
                                      color: Colors.black12,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.notification_important, color: Colors.white, size: 17),
                                            const Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                              child: Text("Important", style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              if (userTasks[task]["repeat"])
                                SizedBox(
                                  width: 80,
                                  child: Card(
                                      elevation: 10,
                                      color: Colors.black12,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.repeat, color: Colors.white, size: 17),
                                            const Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                              child: Text("Repeat", style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                            ],
                          ),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                      child: Transform.scale(
                        scale: (kIsWeb) ? 1 : 2,
                        child: CircularCheckBox(
                            checkColor: Colors.blueGrey, // color of tick Mark
                            activeColor: Colors.white,
                            value: userTasks[task]['done'],
                            onChanged: (value) {
                              setStateFromTaskView(() => userTasks[task]['done'] = value);
                              Database.upload(userTasks);
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget taskSection(String section, int index, dynamic changeShowYesterday, bool showYesterday) {
  return Visibility(
    visible: _visibility[index],
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: FadeInLeft(
        preferences:
            AnimationPreferences(duration: const Duration(milliseconds: 300), offset: const Duration(seconds: 1)),
        child: Row(children: [
          Text(section,
              style: TextStyle(
                  foreground: Paint()..shader = textGradientShader, fontWeight: FontWeight.bold, fontSize: 20)),
          if (index == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: GradientButton(
                child: Text((showYesterday) ? "Hide" : "Show"),
                callback: changeShowYesterday,
              ),
            ),
          const Expanded(child: const Padding(padding: EdgeInsets.zero))
        ]),
      ),
    ),
  );
}
