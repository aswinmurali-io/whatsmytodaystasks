import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:gradient_widgets/gradient_widgets.dart';

import '../settings.dart';

class AccountSettingsView extends StatefulWidget {
  @override
  _AccountSettingsViewState createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48.0),
                        boxShadow: [
                          BoxShadow(color: Colors.blueGrey[100], blurRadius: 18)
                        ]),
                    child: CircleAvatar(
                        maxRadius: 60,
                        backgroundColor: Colors.red,
                        child: IconButton(
                            icon: Icon(Icons.account_circle),
                            color: Colors.white,
                            onPressed: () => null))),
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
              for (String setting in settings.keys)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: ListTileTheme(
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      focusColor: Colors.red,
                      title: Text(setting),
                      subtitle: Text(settings[setting][2]),
                      leading: IconButton(
                        icon: Icon(settings[setting][0]),
                        onPressed: null,
                      ),
                      trailing: (settings[setting][1] != null)
                          ? Switch(
                              value: settings[setting][1],
                              onChanged: (value) => setState(() =>
                                  settings[setting][1] = !settings[setting][1]),
                            )
                          : SizedBox(
                              width: 90,
                              child: GradientButton(
                                callback: null,
                                isEnabled: false,
                                shapeRadius: BorderRadius.circular(10),
                                shadowColor: Colors.blueGrey,
                                elevation: 0,
                                gradient: Gradients.cosmicFusion,
                                child: Text(
                                  settings[setting][3] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                      onTap: () => null,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
