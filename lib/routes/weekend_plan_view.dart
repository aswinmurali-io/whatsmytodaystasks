import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:auto_route/auto_route.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import '../globals.dart';
import '../routes/routes.gr.dart';

class WeekendPlanView extends StatefulWidget {
  @override
  _WeekendPlanViewState createState() => _WeekendPlanViewState();
}

class _WeekendPlanViewState extends State<WeekendPlanView> {
  final _breadCrumbs = {
    "Weeks Plans": [Gradients.hotLinear, 60.0], // Must be decimal
    "0 Tasks": [Gradients.blush, 30.0],
    "0% Success": [Gradients.tameer, 55.0]
  };

  @override
  Widget build(BuildContext context) {
    // reset the gradiant scale
    allGradColorsIndex = 0;

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
                          .pushNamed(Routes.accountSettingsView))),
            ),
          ],
          title: const Text("Manage weekend tasks"),
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
                          colors: getNextGradientForPlanView(),
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
