import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              color: Colors.blueGrey,
              icon: Icon(Icons.settings),
              onPressed: () => null,
            )
          ],
          title: Text(
            "What's my today's tasks ?",
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[],
          ),
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            focusElevation: 50,
            onPressed: () => null,
            tooltip: 'Add a day',
            child: Icon(Icons.calendar_today),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: FloatingActionButton(
                focusElevation: 50,
                onPressed: () => null,
                tooltip: 'Add a task',
                child: Icon(Icons.add),
              ))
        ]));
  }
}
