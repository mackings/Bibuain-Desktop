import 'dart:convert';

import 'package:bdesktop/HR/Api/payrollservice.dart';
import 'package:bdesktop/HR/Payroll/widgets/card.dart';
import 'package:bdesktop/HR/models/staffpayroll.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Createpayroll extends StatefulWidget {
  const Createpayroll({super.key});

  @override
  State<Createpayroll> createState() => _CreatepayrollState();
}

class _CreatepayrollState extends State<Createpayroll> {
  int staffCount = 0;
  double totalAmountPaid = 0.0;
  double totalDebts = 0.0;
  List<StaffPayroll> staffPayrolls = [];
  bool isLoading = true;
  String errorMessage = '';
  List<String> staffNames = [];
  bool isLoadingStaffNames = true;

  @override
  void initState() {
    super.initState();
    fetchPayrollData();
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController basicSalaryController = TextEditingController();
  TextEditingController daysOfWorkController = TextEditingController();
  TextEditingController payController = TextEditingController();
  TextEditingController incentivesController = TextEditingController();
  TextEditingController debtController = TextEditingController();
  TextEditingController penaltiesController = TextEditingController();
  TextEditingController payablesController = TextEditingController();
  TextEditingController savingsController = TextEditingController();
  TextEditingController deductionsController = TextEditingController();
  TextEditingController netSalaryController = TextEditingController();

  Future<void> fetchPayrollData() async {
    try {
      final apiService = PayrollApiService();
      final response = await apiService.fetchPayrollData();

      if (response['success']) {
        setState(() {
          staffCount = response['data']['staffCount'];
          totalAmountPaid = response['data']['totalAmountPaid'].toDouble();
          totalDebts = response['data']['totalDebts'].toDouble();
          staffPayrolls = response['data']['staffPayrolls'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'];
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // Function to make the API call
  Future<void> createPayroll() async {
    final url = 'https://b-backend-xe8q.onrender.com/createpayroll';
    final body = jsonEncode({
      "name": nameController.text,
      "level": levelController.text,
      "basicSalary": int.parse(basicSalaryController.text),
      "daysOfWork": int.parse(daysOfWorkController.text),
      "pay": int.parse(payController.text),
      "incentives": int.parse(incentivesController.text),
      "debt": int.parse(debtController.text),
      "penalties": int.parse(penaltiesController.text),
      "payables": int.parse(payablesController.text),
      "savings": int.parse(savingsController.text),
      "deductions": int.parse(deductionsController.text),
      "netSalary": int.parse(netSalaryController.text),
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Payroll created successfully!');
        Navigator.of(context).pop(); // Close the dialog on success
      } else {
        print('Failed to create payroll.');
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fetch staff names and update the loading state
  Future<void> fetchStaffNames() async {
    final response = await http.get(
      Uri.parse('https://b-backend-xe8q.onrender.com/staffs'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;

      // Extract staff names
      setState(() {
        staffNames = data.map((staff) => staff['name'].toString()).toList();
        isLoadingStaffNames = false; // Mark loading as finished
        print("Staff Names $staffNames");
      });
    } else {
      throw Exception('Failed to load staff names');
    }
  }

  // Function to show the dialog

bool isSubmitting = false; // Track the submission/loading state

void _showCreatePayrollDialog() async {
  // Call fetch function to load staff names before showing the dialog
  await fetchStaffNames(); // Ensure names are fetched first

  // After names are fetched, show the dialog
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Payroll",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Scrollable form inside a container with limited height
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Column(
                        children: [
                          // Dropdown for Staff Names
                          _buildDropdownField('Name', staffNames, nameController),
                          // Other fields
                          _buildFormField('Level', levelController),
                          _buildFormField(
                              'Basic Salary', basicSalaryController,
                              isNumber: true),
                          _buildFormField('Days of Work', daysOfWorkController,
                              isNumber: true),
                          _buildFormField('Pay', payController, isNumber: true),
                          _buildFormField('Incentives', incentivesController,
                              isNumber: true),
                          _buildFormField('Debt', debtController, isNumber: true),
                          _buildFormField('Penalties', penaltiesController,
                              isNumber: true),
                          _buildFormField('Payables', payablesController,
                              isNumber: true),
                          _buildFormField('Savings', savingsController,
                              isNumber: true),
                          _buildFormField('Deductions', deductionsController,
                              isNumber: true),
                          _buildFormField('Net Salary', netSalaryController,
                              isNumber: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.montserrat(
                        color: Color(0xFF030832),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null // Disable the button while submitting
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isSubmitting = true; // Start loading
                              });

                              try {
                                await createPayroll(); // API Call to create payroll

                                // Show success Snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Payroll created for ${nameController.text}",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Close the dialog after submission
                                Navigator.of(context).pop();
                              } catch (error) {
                                // Handle error, show error Snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Failed to create payroll",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isSubmitting = false; // Stop loading
                                });
                              }
                            }
                          },
                    child: isSubmitting
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          ) // Show loading spinner
                        : Text(
                            "Submit",
                            style: GoogleFonts.montserrat(
                                color: Color(0xFF030832),
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
 final NumberFormat currencyFormatter =  NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF030832),
        title: Text(
          "Payroll",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(
                          title: 'Total Employees',
                          value: staffCount.toString(),
                          subValue: '',
                          iconColor: Colors.orange,
                          icon: Icons.people,
                          percentageColor: Colors.grey,
                          percentageText: '',
                        ),
                        StatCard(
                          title: 'Payroll Cost',
                          value: '\N${currencyFormatter.format(totalAmountPaid)}',
                          subValue: '',
                          iconColor: Colors.blue,
                          icon: Icons.monetization_on,
                          percentageColor: Colors.grey,
                          percentageText: '',
                        ),
                        StatCard(
                          title: 'Deductions',
                          value: '\N${currencyFormatter.format(totalDebts)}',
                          subValue: '',
                          iconColor: Colors.green,
                          icon: Icons.money_off,
                          percentageColor: Colors.grey,
                          percentageText: '',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          SizedBox(width: 25),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Payroll',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),


      
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2),
                          5: FlexColumnWidth(2),
                          6: FlexColumnWidth(2),
                          7: FlexColumnWidth(2),
                          8: FlexColumnWidth(2),
                          9: FlexColumnWidth(2),
                          10: FlexColumnWidth(2),
                          11: FlexColumnWidth(2),
                          12: FlexColumnWidth(2),
                          13: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Name',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Level',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Basic Sal..',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Days',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Pay',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Incentives',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Debt',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Penalties',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Payables',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Savings',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Deducti..',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Net Sal..',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Month',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Year',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Staff Payroll Data
                    Expanded(
                      child: ListView.builder(
                        itemCount: staffPayrolls.length,
                        itemBuilder: (context, index) {
                          final staffPayroll = staffPayrolls[index];

                          // Abbreviate long names or pad short names
                          String shortenedName = staffPayroll.name.length > 10
                              ? staffPayroll.name.substring(0, 7) + '.'
                              : staffPayroll.name.padRight(12, ' ');

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(3),
                                    3: FlexColumnWidth(2),
                                    4: FlexColumnWidth(2),
                                    5: FlexColumnWidth(2),
                                    6: FlexColumnWidth(2),
                                    7: FlexColumnWidth(2),
                                    8: FlexColumnWidth(2),
                                    9: FlexColumnWidth(2),
                                    10: FlexColumnWidth(2),
                                    11: FlexColumnWidth(2),
                                    12: FlexColumnWidth(2),
                                    13: FlexColumnWidth(2),
                                  },
                                  children: staffPayroll.payroll.map((payrollEntry) {
                                    final NumberFormat currencyFormatter =
                                        NumberFormat("#,##0", "en_US");
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            shortenedName,
                                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            payrollEntry.level,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.basicSalary)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '${payrollEntry.daysOfWork}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.netSalary)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.incentives)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.debt)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.penalties)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.payables)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.savings)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.deductions)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '\N${currencyFormatter.format(payrollEntry.netSalary)}',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            payrollEntry.month,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            payrollEntry.year.toString(),
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              Divider(
                                height: 20,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
)






                ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF030832),
        mini: false,
        child: Icon(Icons.create, color: Colors.white),
        onPressed: _showCreatePayrollDialog,
      ),
    );
  }
}

Widget _buildFormField(String label, TextEditingController controller,
    {bool isNumber = false}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    ),
  );
}


Widget _buildDropdownField(String label, List<String> items, TextEditingController controller) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white
    ),
    child: DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      focusColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none, 
        
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: (value) {
        // Store the selected item in the controller
        controller.text = value!;
      },
      validator: (value) => value == null ? 'Please select a $label' : null,
    ),
  );
}

