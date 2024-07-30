import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmPayDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  ConfirmPayDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Text('Confirm Pay',style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600
      ),),
      content: Text('Are you sure payments has been made?'),
      actions: <Widget>[
        TextButton(
          onPressed: onCancel,
          child: Text('No'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text('Yes'),
        ),
      ],
    );
  }
}
