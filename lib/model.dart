import 'dart:ui';

import 'package:flutter/material.dart';

modalBottomSheetMenu(BuildContext context) {
  showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (builder) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 350.0,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                child: Center(
                  child: Text("This is a modal sheet"),
                )),
          ),
        );
      });
}
