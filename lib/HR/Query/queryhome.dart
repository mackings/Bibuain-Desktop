import 'package:bdesktop/HR/Query/QueryApi/Queryservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Queryhome extends StatefulWidget {
  const Queryhome({super.key});

  @override
  State<Queryhome> createState() => _QueryhomeState();
}

class _QueryhomeState extends State<Queryhome> {
  
  List<dynamic> staffList = [];
  Map<String, dynamic>? selectedStaff;
  List<dynamic> messages = [];
  bool isLoading = false;

  TextEditingController messageController = TextEditingController();
  TextEditingController queryTextController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  String formatTimestamp(String timestamp) {
    DateTime messageDate = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    DateFormat timeFormatter = DateFormat.jm(); // e.g., 12:01 PM

    // Check if the message was sent today
    if (messageDate.day == now.day &&
        messageDate.month == now.month &&
        messageDate.year == now.year) {
      return "Today, ${timeFormatter.format(messageDate)}";
    }
    // Check if the message was sent yesterday
    else if (messageDate.day == now.day - 1 &&
        messageDate.month == now.month &&
        messageDate.year == now.year) {
      return "Yesterday, ${timeFormatter.format(messageDate)}";
    }
    // For older dates, show the full date
    else {
      DateFormat dateFormatter = DateFormat(
          "d MMM, ${timeFormatter.pattern}"); // e.g., 12 July, 2:01 PM
      return dateFormatter.format(messageDate);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStaffs();
  }

  Future<void> fetchStaffs() async {
    final response =
        await http.get(Uri.parse('https://b-backend-xe8q.onrender.com/staffs'));
    if (response.statusCode == 200) {
      setState(() {
        staffList = json.decode(response.body)['data'];
        print('Chat Staff list $staffList');
      });
    }
  }

  Future<void> fetchMessages(String name, String queryId) async {
    try {
      final response = await http.post(
        Uri.parse('https://b-backend-xe8q.onrender.com/getquery/messages'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "queryId": queryId,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['data'] != null && responseBody['data'] is List) {
          setState(() {
            messages = responseBody['data'];
            print('Fetched messages: $messages');
          });
        } else {
          print('Invalid data format');
        }
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  void selectStaff(Map<String, dynamic> staff) {
    setState(() {
      selectedStaff = staff;
      messages = []; // Clear previous messages when new staff is selected
    });

    // Check if staff has queries
    if (staff['queries'] != null && staff['queries'].isNotEmpty) {
      String queryId =
          staff['queries'][0]['_id']; // Adjust based on your data structure
      fetchMessages(staff['name'], queryId);
    } else {
      // Staff has no queries
      setState(() {
        messages = [];
      });
    }
  }

  Future<void> createQuery() async {
    if (selectedStaff != null) {
      String name = selectedStaff!['name'];
      String queryText = queryTextController.text;
      String notes = notesController.text;

      setState(() {
        isLoading = true; // Set loading state to true
      });

      try {
        final response = await http.post(
          Uri.parse('https://b-backend-xe8q.onrender.com/createquery'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "name": name,
            "queryText": queryText,
            "notes": notes,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          print('Query created: ${responseBody['data']}');

          // Clear text fields after successful creation
          queryTextController.clear();
          notesController.clear();
          
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Query created successfully')),
          );

          // Optionally refresh messages or update the state
          fetchMessages(name,
              responseBody['data']['_id']); // Assuming response has query ID
        } else {
          print('Failed to create query: ${response.statusCode}');
        }
      } catch (error) {
        print('Error creating query: $error');
      } finally {
        setState(() {
          isLoading = false; // Reset loading state
        });
      }
    } else {
      print('No staff selected');
    }
  }

  Future<void> closeQuery(String name, String queryId) async {
    final url = Uri.parse('https://b-backend-xe8q.onrender.com/removequery');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'queryId': queryId,
        }),
      );
      print(name + queryId);

      if (response.statusCode == 200) {
        // Handle successful response
        final snackBar = SnackBar(
          content: Text('Query Closed Succesfully'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('Query closed successfully');
      } else {
        // Handle error response
        print('Failed to close query: ${response.body}');
      }
    } catch (error) {
      print('Error closing query: $error');
    }
  }

  void showCreateQueryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Create Query",
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: 400,
            height: 200, // Adjust the height as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Border color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: TextField(
                    controller: queryTextController,
                    decoration: InputDecoration(
                      labelText: "Query Text",
                      border: InputBorder.none, // Remove the default border
                      contentPadding:
                          EdgeInsets.all(10), // Padding inside the TextField
                    ),
                  ),
                ),
                SizedBox(height: 16), // Add space between the text fields
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Border color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Notes",
                      border: InputBorder.none, // Remove the default border
                      contentPadding:
                          EdgeInsets.all(10), // Padding inside the TextField
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : TextButton(
                    onPressed: () {
                      createQuery();
                      Navigator.of(context).pop();
                    },
                    child: Text("Submit"),
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF030832),
        title: Text(
          "Queries",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Row(
        children: [
          // Left side (Staff list)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200], // Background color
              child: ListView.builder(
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  var staff = staffList[index];

                  // Define a list of colors to cycle through
                  final List<Color> avatarColors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.pink,
                    Colors.teal,
                    Colors.indigo,
                    Colors.yellow,
                  ];

                  // Get a color based on the index, cycling through the list of colors
                  Color avatarColor = avatarColors[index % avatarColors.length];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0), // Add padding to bring names down
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                avatarColor, // Assign dynamic color
                            child: Icon(Icons.person,
                                color: Colors.white), // Person icon
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0), // Adjust text positioning
                            child: Text(
                              staff['name'],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          onTap: () => selectStaff(staff),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

// UI code
          Expanded(
            flex: 3,
            child: selectedStaff != null
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, top: 40),
                    child: Column(
                      children: [
                        // Chat messages container
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedStaff!['name']}",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500),
                            ),
                            if (messages.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  String queryId = selectedStaff!['queries'] !=
                                              null &&
                                          selectedStaff!['queries'].isNotEmpty
                                      ? selectedStaff!['queries'][0][
                                          '_id'] // Adjust based on your data structure
                                      : "";
                                  closeQuery(selectedStaff!['name'], queryId);
                                },
                                child: Container(
                                  height: 40,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 0.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Close Query",
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(
                          height: 20,
                        ),

                        Expanded(
                          child: messages.isNotEmpty
                              ? ListView.builder(
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    var message = messages[index];
                                    bool isHR = message['senderRole'] == 'hr';
                                    String formattedTime =
                                        formatTimestamp(message['timestamp']);

                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      alignment: isHR
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6), // Limit width to 60% of the screen
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isHR
                                                ? Colors.blue[100]
                                                : Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, // Align text to the start (left)
                                            children: [
                                              Text(
                                                message['message'] ??
                                                    'No message',
                                                style: TextStyle(
                                                    fontSize:
                                                        16), // Adjust font size for the message
                                              ),
                                              SizedBox(
                                                  height:
                                                      5), // Add some space between message and timestamp
                                              Text(
                                                formattedTime,
                                                style: TextStyle(
                                                  color: Colors.grey[
                                                      600], // Subtle color for timestamp
                                                  fontSize:
                                                      12, // Smaller font for timestamp
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text('No queries for this staff Yet',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18)),
                                      // Show create query button if no messages exist
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top:
                                                35.0), // Adjust padding as needed
                                        child: GestureDetector(
                                          onTap: showCreateQueryDialog,
                                          child: Container(
                                            height: 50,
                                            width: 300,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF030832),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Create Query",
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // Show message input field only if messages exist
                        if (messages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: messageController,
                                    decoration: InputDecoration(
                                      hintText: "Send a message...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () async {
                                    // Send message function
                                    if (messageController.text.isNotEmpty &&
                                        selectedStaff != null) {
                                      String name = selectedStaff!['name'];

                                      // Get the query ID from the selected staff's queries
                                      String queryId = selectedStaff![
                                                      'queries'] !=
                                                  null &&
                                              selectedStaff!['queries']
                                                  .isNotEmpty
                                          ? selectedStaff!['queries'][0][
                                              '_id'] // Adjust based on your data structure
                                          : "";

                                      if (queryId.isNotEmpty) {
                                        try {
                                          // Prepare the request body
                                          final body = json.encode({
                                            "name": name,
                                            "queryId": queryId,
                                            "message": messageController.text,
                                          });

                                          // Make the HTTP POST request
                                          final response = await http.post(
                                            Uri.parse(
                                                'https://b-backend-xe8q.onrender.com/query/hrreply'),
                                            headers: {
                                              "Content-Type": "application/json"
                                            },
                                            body: body,
                                          );

                                          // Check for successful response
                                          if (response.statusCode == 200) {
                                            final responseBody =
                                                json.decode(response.body);
                                            print(
                                                'Message sent successfully: ${responseBody['data']}');

                                            // Update the local messages state
                                            setState(() {
                                              messages.add({
                                                'message':
                                                    messageController.text,
                                                'senderRole': 'hr',
                                                'timestamp': DateTime.now()
                                                    .toIso8601String(), // Adding current timestamp
                                              });
                                            });

                                            // Clear the message input field
                                            messageController.clear();
                                          } else {
                                            print(
                                                'Failed to send message: ${response.body}');
                                          }
                                        } catch (error) {
                                          print(
                                              'Error sending message: $error');
                                        }
                                      } else {
                                        print(
                                            'No valid query ID found for sending message.');
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      "Select a staff member to view queries",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
