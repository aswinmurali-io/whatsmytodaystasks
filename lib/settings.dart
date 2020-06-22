/*
  key => Settings Title (string)
  value => List(
    1) Setting icon
    2) Settings bool value (true, false, 
      null -> means not boolean settings will switch to a button instead)
    3) Settings description
    4) Settings button
  )
*/

import 'package:flutter/material.dart';

final settings = {
  "Disable notification": [
    Icons.notifications,
    false,
    "Enable it to prevent the app from pushing a notification in this device",
    null,
  ],
  "High Contrast Mode": [
    Icons.font_download,
    false,
    "Enable this if you have difficulty reading text. The app will make it pitch black.",
    null,
  ],
  "Sync to cloud": [
    Icons.sync,
    null,
    "Sync your tasks in the cloud. Useful if your were offline and the auto sync did not sync",
    "Sync Now"
  ],
  "Sign out from this device": [
    Icons.account_box,
    null,
    "Signout from this device",
    "Signout"
  ],
  "Delete Account": [
    Icons.delete_forever,
    null,
    "Delete the account from your current device and the cloud",
    "Delete",
  ],
};
