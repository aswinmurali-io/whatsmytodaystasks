import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import '../globals.dart';
import '../routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String _currentWeek = "";
  double _currentWeekTabSize = 30.0;

  int _getCurrentWeek(DateTime date) {
    return ((int.parse(DateFormat('D').format(date)) - date.weekday + 10) / 7)
        .floor();
  }

  _TaskViewState() {
    _currentWeek = weeks[_getCurrentWeek(DateTime.now())];
    Future.delayed(const Duration(milliseconds: 5),
        () => setState(() => _currentWeekTabSize += 30));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.red,
              indicatorWeight: 0.1,
              onTap: (index) => setState(() => _currentWeek = weeks[index]),
              tabs: [
                for (String text in weeks)
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
              IconButton(
                icon: const Icon(Icons.calendar_view_day),
                onPressed: () => ExtendedNavigator.of(context)
                    .pushNamed(Routes.weekendPlanView),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                        icon: Icon(Icons.account_circle),
                        color: Colors.white,
                        onPressed: () => ExtendedNavigator.of(context)
                            .pushNamed(Routes.accountSettingsView))),
              ),
            ],
            title: const Text("What's my today's tasks ?"),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: TabBarView(children: [
            for (int i = 0; i < 7; i++)
              CupertinoScrollbar(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [],
                          ),
                        ),
                      ),
                      for (String day in weeks)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
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
                                colors: getNextGradient(),
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ListTileTheme(
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              child: ListTile(
                                title: Text(day),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => null,
                                ),
                                onTap: () => null,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
          ]),
          floatingActionButton:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              heroTag: "btn3",
              focusElevation: 80,
              onPressed: () => null,
              tooltip: 'Add a task',
              child: CircularGradientButton(
                child: Icon(Icons.calendar_today),
                callback: () {},
                gradient: Gradients.blush,
                elevation: 0,
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: FloatingActionButton(
                  heroTag: "btn4",
                  focusElevation: 80,
                  onPressed: () => null,
                  tooltip: 'Add a task',
                  child: CircularGradientButton(
                    child: Icon(Icons.add),
                    callback: () {},
                    gradient: Gradients.hotLinear,
                    elevation: 0,
                  ),
                ))
          ])),
    );
  }
}
