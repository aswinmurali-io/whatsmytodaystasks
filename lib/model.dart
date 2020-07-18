import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:jiffy/jiffy.dart';

import 'database.dart';
import 'globals.dart';
import 'tasks_dialog.dart';

showQuickTaskUI(BuildContext context, StateSetter setStateFromTaskView, String week, TabController tabController,
    GlobalKey<ScaffoldState> taskViewScaffoldKey) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
              body: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                  child: Column(children: [
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: userTasks.keys.toList().length,
                        itemBuilder: (context, index) {
                          String taskName = userTasks.keys.toList()[index];
                          return SlideInUp(
                            preferences: AnimationPreferences(
                                offset: Duration(seconds: 0), duration: Duration(milliseconds: 500)),
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
                                  setState(() => userTasks);
                                  Database.upload(userTasks);
                                  setStateFromTaskView(() => userTasks);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextField(
                            autocorrect: true,
                            autofocus: true,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                              hintText: ' Add / Search Task',
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onSubmitted: (value) => setStateFromTaskView(() {
                              if (value.isNotEmpty)
                                userTasks.addAll({
                                  value: {
                                    "time": "Any Time",
                                    "endtime": "Any Time",
                                    "notify": true,
                                    "description": '',
                                    "image": null,
                                    "importance": 0,
                                    "repeat": false,
                                    "done": false,
                                    "week": (tabController.index < 9)
                                        ? tabController.index
                                        : week.indexOf(Jiffy(DateTime.now()).EEEE)
                                  },
                                });
                              Database.upload(userTasks);
                              Navigator.of(context).pop();
                            }),
                          ),
                        ),
                      ),
                    )
                  ])));
        });
      });
}
