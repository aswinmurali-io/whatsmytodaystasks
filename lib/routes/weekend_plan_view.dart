import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import 'package:whatsmytodaystasks/routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final _allGradColors = [
    GradientColors.aqua,
    GradientColors.harmonicEnergy,
    GradientColors.noontoDusk,
    MoreGradientColors.azureLane,
    MoreGradientColors.instagram,
    MoreGradientColors.darkSkyBlue,
  ];

  final _breadCrumbs = {
    "Weeks Plans": [Gradients.hotLinear, 60],
    "0 Tasks": [Gradients.blush, 30],
    "0% Success": [Gradients.tameer, 55]
  };

  final weeks = [
    "All days",
    "Any days",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  int _allGradColorsIndex = 0;

  List<Color> _getNextGradient() {
    _allGradColorsIndex++;
    if (_allGradColorsIndex >= _allGradColors.length) _allGradColorsIndex = 0;
    return _allGradColors[_allGradColorsIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
              child: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                      icon: Icon(Icons.account_circle),
                      color: Colors.white,
                      onPressed: () => ExtendedNavigator.of(context)
                          .pushNamed(Routes.todaysView))),
            ),
          ],
          title: const Text("What's my today's tasks ?"),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: CupertinoScrollbar(
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
                      children: [
                        for (String text in _breadCrumbs.keys)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: GradientButton(
                              gradient: _breadCrumbs[text][0],
                              shadowColor: Colors.transparent,
                              increaseWidthBy: _breadCrumbs[text][1],
                              child: Text(text, style: TextStyle(fontSize: 20)),
                              callback: null,
                            ),
                          ),
                      ],
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
                          colors: _getNextGradient(),
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
        ]));
  }
}
