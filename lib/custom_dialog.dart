import 'package:flutter/material.dart';

class DialogForm extends StatefulWidget {
  
  DialogForm({
    this.titleBackground = Colors.blueAccent,
    this.icon,
    this.title,
    this.description,
    this.contentBackground,
    this.contentPadding,
    this.content,
    this.animationDuration
  });

  final Color titleBackground;
  final Icon icon;
  final Widget title;
  final Widget description;
  final Color contentBackground;
  final EdgeInsetsGeometry contentPadding;
  final Widget content;
  final Duration animationDuration;


  @override
  _DialogFormState createState() => _DialogFormState();
}

class _DialogFormState extends State<DialogForm> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 40,
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: widget.animationDuration ?? Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
          color: widget.titleBackground,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (widget.icon != null) widget.icon,
                  if (widget.icon != null) SizedBox(width: 16,),
                  if (widget.title != null) widget.title,
                ],
              ),
            ),

            if (widget.description != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: widget.description,
            ),
            if (widget.description != null) SizedBox(height: 24,),
            
            Container(
              padding: widget.contentPadding ?? EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: widget.contentBackground ?? Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: widget.content,
            )

          ],
        ),
      ),
    );
  }
}