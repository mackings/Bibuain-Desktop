import 'package:bdesktop/Manual/Dashboard/Views/Query/Api/staffqueryservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';



class StaffQuery extends StatefulWidget {
  const StaffQuery({super.key});

  @override
  State<StaffQuery> createState() => _StaffQueryState();
}

class _StaffQueryState extends State<StaffQuery> {
  String? username;
  List<dynamic> queries = [];
  final StaffQueriesApiService apiService = StaffQueriesApiService();
  TextEditingController replyController = TextEditingController();
  bool isLoading = false; // To track loading state when sending reply

  @override
  void initState() {
    super.initState();
    fetchUsernameAndData();
  }

  Future<void> fetchUsernameAndData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');

    if (username != null && username!.isNotEmpty) {
      await fetchStaffData(username!);
    } else {
      print('No username found in preferences');
    }
  }

  Future<void> fetchStaffData(String username) async {
    var response = await apiService.fetchStaffQueries(username);
    if (response != null && response['success']) {
      setState(() {
        queries = response['data'];
      });
    } else {
      print('Failed to retrieve queries');
    }
  }

  Future<void> sendReply(String queryId) async {
    if (replyController.text.isNotEmpty && username != null) {
      setState(() {
        isLoading = true; // Set loading to true while sending reply
      });

      var response = await apiService.sendStaffReply(
        username!,
        queryId,
        replyController.text,
      );

      setState(() {
        isLoading = false; // Reset loading state once reply is sent
      });

      if (response != null && response['success']) {
        setState(() {
          replyController.clear();
          fetchStaffData(username!);
        });
      } else {
        print('Failed to send reply');
      }
    }
  }

String formatTimestamp(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp).toLocal();  // Adjust to local time
  return DateFormat('MMMM d, h:mm a').format(dateTime);     // Format the date
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30,right: 30),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Expanded(
              child: queries.isNotEmpty
                  ? ListView.builder(
                      itemCount: queries.length,
                      itemBuilder: (context, index) {
                        var query = queries[index];
                        var replies = query['replies'] ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: replies.map<Widget>((reply) {
                            bool isHR = reply['senderRole'] == 'hr';
                            String formattedTime = formatTimestamp(reply['timestamp']);
                            return Container(
                              padding: const EdgeInsets.all(10),
                              alignment: isHR ? Alignment.centerLeft : Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isHR ? Colors.blue[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply['message'] ?? 'No message',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No queries at The Moment",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: queries.isNotEmpty?TextField(
                      controller: replyController,
                      decoration: InputDecoration(
                        labelText: "Enter your reply",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 1, // Limit to single-line input
                    ):Text("")
                  ),
                  isLoading
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ) // Show loading spinner while sending reply
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            if (queries.isNotEmpty) {
                              sendReply(queries[0]['_id']); // Send reply to the first query for now
                            }
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

