import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:jiffy/jiffy.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter_animator/flutter_animator.dart';

import '../globals.dart';
import '../routes/routes.gr.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  double _currentWeekTabSize = 30.0;
  String _currentWeek = Jiffy(DateTime.now()).EEEE;
  List<Widget> _tasksCards = [];
  final _totalTabs = 7;

  List<Widget> _renderTask() {
    int __offset;
    // clean the task card list otherwise it will exceed limit by repeated rebuilding
    _tasksCards.clear();
    for (int i = 1; i <= _totalTabs; i++) {
      __offset = 100;
      _tasksCards.add(CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: <Widget>[
              for (String day in weeks)
                BounceIn(
                  preferences: AnimationPreferences(
                      offset: Duration(milliseconds: __offset += 50)),
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
    WidgetsBinding.instance.addObserver(this);
    setState(() =>
        _currentWeekTabSize += 30); // trigger the scale transition for the tab
    _tabController = TabController(length: _totalTabs, vsync: this);
    _tabController.index = weeks.indexOf(_currentWeek);
    _tabController.addListener(
        () => setState(() => _currentWeek = weeks[_tabController.index]));
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white30,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white30,
        systemNavigationBarIconBrightness: Brightness.dark));
  }

  void _addPlanCallback() {

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _totalTabs,
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            brightness: Brightness.light,
            bottom: TabBar(
              physics: const BouncingScrollPhysics(),
              isScrollable: true,
              indicatorColor: Colors.transparent,
              indicatorWeight: 0.1,
              indicatorSize: TabBarIndicatorSize.label,
              controller: _tabController,
              tabs: <Widget>[
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
                        icon: const Icon(Icons.account_circle),
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
              physics: const BouncingScrollPhysics(),
              children: _renderTask()),
          floatingActionButton:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              heroTag: "btn3",
              focusElevation: 80,
              onPressed: () => null,
              tooltip: 'Edit Plan View',
              child: CircularGradientButton(
                child: const Icon(Icons.calendar_today),
                callback: () => ExtendedNavigator.of(context)
                    .pushNamed(Routes.weekendPlanView),
                gradient: Gradients.blush,
                elevation: 0,
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: FloatingActionButton(
                  heroTag: "btn4",
                  focusElevation: 80,
                  onPressed: () => null,
                  tooltip: 'Add a task',
                  child: CircularGradientButton(
                    child: const Icon(Icons.add),
                    callback: _addPlanCallback,
                    gradient: Gradients.hotLinear,
                    elevation: 0,
                  ),
                ))
          ])),
    );
  }
}
