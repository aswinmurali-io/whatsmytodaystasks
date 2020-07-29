import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'database.dart';

class TaskViewBackend {
  static Icon generateIconsForProfileList(String choice) {
    switch (choice) {
      case "Add Account":
        return Icon(Icons.add);
      case "Delete Account":
        return Icon(Icons.delete);
      case "Signout Account":
        return Icon(Icons.close);
      default:
        return Icon(Icons.account_circle);
    }
  }

  static profileButtonAction(
      String email, dynamic _accountConnectDialog, StateSetter setState, ProgressDialog pr, Map userTasks) async {
    switch (email) {
      case "Add Account":
        _accountConnectDialog();
        return;
      case "Delete Account":
        await pr.show();
        await Database.deleteAccount();
        setState(() => userTasks = {});
        await pr.hide();
        return;
      case "Signout Account":
        await pr.show();
        await Database.signOut();
        setState(() => userTasks = {});
        await pr.hide();
        return;
      case "Switch Google Account":
        await pr.show();
        await Database.signOut();
        userTasks.clear();
        await Database.googleAuthDialog();
        userTasks = await Database.download();
        setState(() => userTasks = userTasks);
        await pr.hide();
        return;
      default:
        await pr.show();
        await Database.signOut();
        userTasks.clear();
        await Database.auth(email, Database.getPassword(email), userTasks);
        userTasks = await Database.download();
        setState(() => userTasks = userTasks);
        await pr.hide();
        return;
    }
  }

  static accountFormValidation(String _email, String _password, StateSetter setState2, String _status,
      ProgressDialog pr, Map userTasks, BuildContext context, RefreshController _refreshController) async {
    {
      if (_email != null && _password != null) {
        // taken from https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
        RegExp __regexEmail = RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
        if (!__regexEmail.hasMatch(_email)) {
          setState2(() => _status = "Enter a valid email address.");
          return;
        }
        if (_password.length < 8) {
          setState2(() => _status = "Password should be atleast 8 characters long.");
          return;
        }
        await pr.show();
        String errorStatus = await Database.auth(_email, _password, userTasks);
        setState2(() => _status = "");
        switch (errorStatus) {
          case 'ERROR_NETWORK_REQUEST_FAILED':
            await pr.hide();
            setState2(() => _status = "Request Failed !");
            return;
          case "ERROR_WRONG_PASSWORD":
            await pr.hide();
            setState2(() => _status = "Wrong Password, Try again!");
            return;
          case "ERROR_TOO_MANY_REQUESTS":
            await pr.hide();
            setState2(() => _status = "Too many requests!");
            return;
          case "ERROR_USER_NOT_FOUND":
          case "auth/user-not-found":
            await pr.hide();
            showDialog(
                context: context,
                child: AlertDialog(
                  content: Text("Account not found. Do you want to create account instead ?"),
                  actions: [
                    GradientButton(
                        elevation: (kIsWeb) ? 0.0 : 5.0,
                        child: const Text("Yes"),
                        callback: () async {
                          await pr.show();
                          String error = await Database.register(_email, _password);
                          print(error);
                          for (int i = 0; i < 3; i++) Navigator.of(context).pop();
                          await pr.show();
                        }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: GradientButton(
                          elevation: (kIsWeb) ? 0.0 : 5.0,
                          child: const Text("No"),
                          callback: () => Navigator.of(context).pop()),
                    )
                  ],
                ));
            return;
        }
        Navigator.of(context).pop();
        await pr.hide();
        _refreshController.requestRefresh();
      } else
        setState2(() => _status = "Make sure to fill both, email and password");
    }
  }
}
