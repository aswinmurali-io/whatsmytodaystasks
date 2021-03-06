import 'dart:ui';
import 'package:flutter/material.dart';

class CustomGradientDialogForm extends StatefulWidget {
  final Color titleBackground;
  final Icon icon;
  final Widget title;
  final Widget description;
  final Color contentBackground;
  final EdgeInsetsGeometry contentPadding;
  final Widget content;
  final Duration animationDuration;

  CustomGradientDialogForm(
      {this.titleBackground,
      this.icon,
      this.title,
      this.description,
      this.contentBackground,
      this.contentPadding,
      this.content,
      this.animationDuration});

  @override
  createState() => _CustomGradientDialogFormState();
}

class _CustomGradientDialogFormState extends State<CustomGradientDialogForm> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (widget.icon != null) widget.icon,
                    if (widget.icon != null) SizedBox(width: 16),
                    if (widget.title != null) widget.title,
                  ],
                ),
              ),
              if (widget.description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: widget.description,
                ),
              if (widget.description != null)
                SizedBox(
                  height: 24,
                ),
              Container(
                padding: widget.contentPadding ?? EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: widget.contentBackground ?? Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: widget.content,
              )
            ],
          ),
        ),
      ),
    );
  }
}
