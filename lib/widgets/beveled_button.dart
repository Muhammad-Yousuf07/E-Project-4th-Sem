

import 'package:flutter/material.dart';

class BeveledButton extends StatelessWidget {
  const BeveledButton({super.key,required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[4],
            foregroundColor: Colors.black,
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            )
        ),
        onPressed: onTap,
        child: Text(title)
    );
  }
}
