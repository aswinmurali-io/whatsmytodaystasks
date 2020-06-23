import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:jiffy/jiffy.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import '../globals.dart';
import '../routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _initialIndex, incrementDuration;
  TabController _tabController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  List<Widget> _tasksCards = [];

  List<Widget> _renderTask() {
    _tasksCards.clear();

    for (int i = 0; i < 7; i++) {
      _tasksCards.add(CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: <Widget>[
              for (String day in weeks)
                BounceIn(
                  preferences:
                      AnimationPreferences(offset: Duration(milliseconds: 300)),
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
                            icon: const Icon(Icons.edit),
                            onPressed: () => null,
                          ),
                          onTap: () => null,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ));
    }
    return _tasksCards;
  }

  @override
  void initState() {
    super.initState();

    // add an observer to detect life cycle change
    WidgetsBinding.instance.addObserver(this);

    // set up the _initialIndex to be the current week in index form
    _initialIndex = weeks.indexOf(_currentWeek);

    // trigger the scale transition for the tab
    setState(() => _currentWeekTabSize += 30);

    // set up the tab controller
    _tabController = TabController(length: 7, vsync: this);
    _tabController.index = _initialIndex;
    _tabController.addListener(
        () => setState(() => _currentWeek = weeks[_tabController.index]));
  }

  @override
  void dispose() {
    // dispose the tab controller
    _tabController.dispose();

    // dispose the observer for life cycle change
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // re-render the status foreground to be black
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            bottom: TabBar(
              physics: BouncingScrollPhysics(),
              isScrollable: true,
              indicatorColor: Colors.transparent,
              indicatorWeight: 0.1,
              indicatorSize: TabBarIndicatorSize.label,
              controller: _tabController,
              tabs: [
                for (String text in weeks)
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                        icon: Icon(Icons.account_circle),
                        color: Colors.white,
                        onPressed: () => ExtendedNavigator.of(context)
                            .pushNamed(Routes.accountSettingsView))),
              )
            ],
            title: const Text("What's my today's tasks ?"),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: TabBarView(
              controller: _tabController,
              physics: BouncingScrollPhysics(),
              children: _renderTask()),
          floatingActionButton:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              heroTag: "btn3",
              focusElevation: 80,
              onPressed: () => null,
              tooltip: 'Add a task',
              child: CircularGradientButton(
                child: Icon(Icons.calendar_today),
                callback: () => ExtendedNavigator.of(context)
                    .pushNamed(Routes.weekendPlanView),
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
