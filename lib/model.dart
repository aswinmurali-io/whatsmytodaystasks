import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:whatsmytodaystasks/database.dart';
import 'package:whatsmytodaystasks/globals.dart';

showQuickTaskUI(BuildContext context, dynamic setStateFromTaskView, String week, TabController tabController) {
  showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
              body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                child: Column(children: [
                  Expanded(
                    flex: 5,
                    child: ListView.builder(
                      itemCount: userTasks.keys.toList().length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(userTasks.keys.toList()[index]),
                          subtitle: Text(getWeekNameFromIndex(userTasks[userTasks.keys.toList()[index]]["week"])),
                          leading: Icon(Icons.list),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              userTasks.remove(userTasks.keys.toList()[index]);
                              setState(() => userTasks);
                              Database.upload(userTasks);
                              setStateFromTaskView(() => userTasks);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
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
                ])),
          ));
        });
      });
}
