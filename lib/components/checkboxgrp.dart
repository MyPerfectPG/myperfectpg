import 'package:flutter/material.dart';

class CheckboxGroup extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onChanged;

  CheckboxGroup({required this.options, required this.onChanged});

  @override
  _CheckboxGroupState createState() => _CheckboxGroupState();
}

class _CheckboxGroupState extends State<CheckboxGroup> {
  List<String> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return CheckboxListTile(
          title: Text(option),
          value: selectedOptions.contains(option),
          onChanged: (bool? value) {
            setState(() {
              if (value ?? false) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
              widget.onChanged(selectedOptions);
            });
          },
          activeColor: Colors.blue,
        );
      }).toList(),
    );
  }
}
