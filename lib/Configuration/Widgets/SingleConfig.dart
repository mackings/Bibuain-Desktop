import 'dart:convert';

import 'package:bdesktop/Configuration/Api/singleClass.dart';
import 'package:bdesktop/Configuration/Widgets/Confdialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Ensure you have this import for NumberFormat
import 'package:http/http.dart' as http; // Add http package for making requests

class SingleConfigurationsDialog extends StatefulWidget {
  final String username;

  const SingleConfigurationsDialog({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<SingleConfigurationsDialog> createState() => _SingleConfigurationsDialogState();
}

class _SingleConfigurationsDialogState extends State<SingleConfigurationsDialog> {
  final TextEditingController _markupController = TextEditingController();
  final TextEditingController _overrideController = TextEditingController();
  bool _isLoading = false;
  String? _previewMargin;
  bool _isConfigured = false; // Track if the configurations have been saved
  bool _isPreviewed = false; // Track if the preview has been calculated

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMarkup = prefs.getString('${widget.username}_markup') ?? '';
    String? savedOverride = prefs.getString('override') ?? '';

    setState(() {
      _markupController.text = savedMarkup.isNotEmpty
          ? NumberFormat("#,##0").format(int.parse(savedMarkup))
          : 'Set a Markup';
      _overrideController.text = savedOverride.isNotEmpty
          ? NumberFormat("#,##0").format(int.parse(savedOverride))
          : '';
    });
  }

  Future<void> _previewMarginCalculation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      SingleOfferService offerService = SingleOfferService();
      Map<String, dynamic> ratesData = await offerService.fetchRates(
        nusername: 'sample_nusername',
        pusername: 'sample_pusername',
      );

      Map<String, double> priceData = await offerService.calculatePrices(
        ratesData: ratesData,
        username: widget.username,
      );

      setState(() {
        _previewMargin = priceData['Margin']!.toStringAsFixed(2);
        _isPreviewed = true;
      });
    } catch (error) {
      print("Error in calculating margin: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadMargin() async {
    if (_previewMargin == null) return; // Exit if no margin is available

    final double marginValue = double.parse(_previewMargin!);
    final String url = 'https://b-backend-xe8q.onrender.com/offers/paxful/margin/update-single-account';

    final body = {
      "username": widget.username,
      "margin": marginValue
    };

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updating margin...')),
      );

      setState(() {
        _isLoading = true; // Set loading state
      });

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Handle the successful response
        final responseData = json.decode(response.body);
        print(responseData); // Print or handle response data as needed

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded successfully!')),
        );
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload margin!')),
        );
      }
    } catch (error) {
      print("Error during upload: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred!')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  Future<void> _saveConfigurations() async {
    setState(() {
      _isLoading = true;
    });

    String markup = _markupController.text.replaceAll(',', '');
    String override = _overrideController.text.replaceAll(',', '');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.username}_markup', markup);
    await prefs.setString('override', override);

    setState(() {
      _isConfigured = true;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Configurations set for ${widget.username}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Set Configs for ${widget.username.toUpperCase()}',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, fontSize: 20),
      ),
      content: SizedBox(
        width: 550,
        height: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_markupController, 'Set Markup'),
            SizedBox(height: 20),
            _buildTextField(_overrideController, 'Global Override'),
          ],
        ),
      ),
      actions: [
        if (_isConfigured && _isPreviewed && _previewMargin != null)
          Padding(
            padding: const EdgeInsets.only(right: 200),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _previewMargin!,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (_isConfigured && !_isPreviewed)
          TextButton(
            onPressed: _isLoading ? null : _previewMarginCalculation,
            child: _isLoading
                ? Text('Personalizing..', style: GoogleFonts.montserrat())
                : Text('Preview', style: GoogleFonts.montserrat()),
          ),
        if (_isConfigured && _isPreviewed)
          TextButton(
            onPressed: _isLoading ? null : _uploadMargin,
            child: _isLoading
                ? Text('Uploading Margin', style: GoogleFonts.montserrat())
                : Text('Upload', style: GoogleFonts.montserrat()),
          ),
        SizedBox(width: 10),
        TextButton(
          onPressed: _isLoading ? null : () async {
            await _saveConfigurations();
          },
          child: _isLoading
              ? Text('Saving your Changes', style: GoogleFonts.montserrat())
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
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
          suffixText: controller.text.isNotEmpty && controller.text != 'Set a Markup'
              ? "${NumberFormat("#,##0").format(int.parse(controller.text.replaceAll(',', '')))}"
              : null,
          suffixStyle: GoogleFonts.montserrat(color: Colors.grey),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyTextInputFormatter(),
        ],
      ),
    );
  }
}
