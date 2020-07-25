import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

import 'database.dart';
import 'globals.dart';

List<bool> _visibility = [false, false, false];

bool smartShowSections(StateSetter setStateFromTaskView, int tabIndex) {
  List _check = [];
  // check how many tasks are there for different section and then display the necessary sections
  for (String task in userTasks.keys)
    if (!userTasks[task]["done"] && userTasks[task]["week"] == tabIndex) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[0] = true);
  else
    _visibility[0] = false;
  _check.clear();

  for (String task in userTasks.keys)
    if ((userTasks[task]["week"] == 7 || userTasks[task]["week"] == 8) &&
        tabIndex != 7 &&
        tabIndex != 8 &&
        tabIndex != 9 &&
        !userTasks[task]["done"]) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[1] = true);
  else
    _visibility[1] = false;
  _check.clear();

  for (String task in userTasks.keys)
    if (userTasks[task]["done"] &&
        (userTasks[task]["week"] == tabIndex ||
            userTasks[task]["week"] == 7 ||
            userTasks[task]["week"] == 8 ||
            userTasks[task]["week"] == 9)) _check.add(task);
  if (_check.isNotEmpty)
    setStateFromTaskView(() => _visibility[2] = true);
  else
    _visibility[2] = false;
  _check.clear();
  return (_visibility[0] == false && _visibility[1] == false && _visibility[2] == false) ? true : false;
}

bool taskCardBool = true;

Widget taskCard(Map userTasks, String task, StateSetter setStateFromTaskView, dynamic tasksEditDialog,
    int uniqueColorIndex, int offset) {
  return Visibility(
    visible: taskCardBool,
    child: SizedBox(
      width: (kIsWeb) ? 400 : null,
      child: BounceIn(
        preferences: AnimationPreferences(offset: Duration(milliseconds: offset += 50)),
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
                      colors: autoGenerateColorCard[uniqueColorIndex++]),
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
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        task ?? "Unknown Task",
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
                  Padding(
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
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget taskSection(String section, int index) {
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
          const Expanded(child: const Padding(padding: EdgeInsets.zero))
        ]),
      ),
    ),
  );
}
