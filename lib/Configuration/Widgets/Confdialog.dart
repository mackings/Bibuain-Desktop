import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';



class ConfigurationsDialog extends StatefulWidget {
  @override
  State<ConfigurationsDialog> createState() => _ConfigurationsDialogState();
}

class _ConfigurationsDialogState extends State<ConfigurationsDialog> {
  final TextEditingController _markupController = TextEditingController();
  final TextEditingController _overrideController = TextEditingController();
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMarkup = prefs.getString('markup') ?? '';
    String? savedOverride = prefs.getString('override') ?? '';

    // Format values to display in the TextFields
    setState(() {
      _markupController.text = savedMarkup.isNotEmpty
          ? NumberFormat("#,##0").format(int.parse(savedMarkup))
          : '';
      _overrideController.text = savedOverride.isNotEmpty
          ? NumberFormat("#,##0").format(int.parse(savedOverride))
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Set Configurations',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 500,
        height: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_markupController, 'Enter Markup'),
            SizedBox(height: 20), // Space between fields
            _buildTextField(_overrideController, 'Enter Override'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null // Disable button while loading
              : () async {
                  setState(() {
                    _isLoading = true; // Set loading state
                  });

                  // Parse the input and save to SharedPreferences
                  String markup = _markupController.text.replaceAll(',', ''); // Remove commas
                  String override = _overrideController.text.replaceAll(',', ''); // Remove commas

                  // Save the values in thousands
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('markup', markup);
                  await prefs.setString('override', override);

                  setState(() {
                    _isLoading = false; // Reset loading state
                  });

                  // Show snackbar notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Configurations set!')),
                  );

                  // Optionally close the dialog
                  Navigator.of(context).pop();
                },
          child: _isLoading
              ? CircularProgressIndicator() // Show loading indicator
              : Text('Save and Sync', style: GoogleFonts.montserrat()),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, // Remove the default border
          contentPadding: EdgeInsets.all(10),
          suffixText: controller.text.isNotEmpty
              ? "${NumberFormat("#,##0").format(int.parse(controller.text.replaceAll(',', '')))}" // Show saved value in thousands
              : null,
          suffixStyle: GoogleFonts.montserrat(color: Colors.grey),
        ),
        keyboardType: TextInputType.number, // Numeric keyboard
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Only allow digits
          CurrencyTextInputFormatter(), // Custom formatter for currency
        ],
      ),
    );
  }
}

// Custom input formatter for formatting currency
class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    // Only allow digits
    final StringBuffer newText = StringBuffer();
    String value = newValue.text;

    if (value.isNotEmpty) {
      final int number = int.parse(value.replaceAll(',', '')); // Remove commas for parsing
      newText.write(NumberFormat("#,##0").format(number)); // Format number in thousands
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
