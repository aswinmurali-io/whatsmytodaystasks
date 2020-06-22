import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import 'routes.gr.dart';

class TodaysView extends StatefulWidget {
  @override
  _TodaysViewState createState() => _TodaysViewState();
}

class _TodaysViewState extends State<TodaysView> with TickerProviderStateMixin {
  double initialCardSize = 60;

  final _allGradColors = [
    GradientColors.aqua,
    GradientColors.harmonicEnergy,
    GradientColors.noontoDusk,
    MoreGradientColors.azureLane,
    MoreGradientColors.instagram,
    MoreGradientColors.darkSkyBlue,
  ];

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
          title: const Text("Account"),
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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
                  child: Container(
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(48.0),
                        boxShadow: [
                          new BoxShadow(
                              color: Colors.blueGrey[100], blurRadius: 18)
                        ]),
                    child: CircleAvatar(
                        maxRadius: 60,
                        backgroundColor: Colors.red,
                        child: IconButton(
                            icon: Icon(Icons.account_circle),
                            color: Colors.white,
                            onPressed: () => null)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: GradientButton(
                    gradient: Gradients.blush,
                    shadowColor: Colors.transparent,
                    increaseWidthBy: 60,
                    child: Text("User Name", style: TextStyle(fontSize: 20)),
                    callback: null,
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
            heroTag: "btn1",
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
                heroTag: "btn2",
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
