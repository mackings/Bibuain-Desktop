import 'package:flutter/material.dart';

class ScrollableContainers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrollable Containers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Swipe Horizontally:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 200, // Set height of the container
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                child: Row(
                  children: [
                    buildContainer('Container 1', Colors.red),
                    buildContainer('Container 2', Colors.blue),
                    buildContainer('Container 3', Colors.green),
                    buildContainer('Container 4', Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContainer(String text, Color color) {
    return Container(
      width: 150, // Set width of each container
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      color: color,
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}