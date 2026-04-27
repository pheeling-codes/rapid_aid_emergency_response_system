import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incident Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text("Date: ${data['date']}"),
            Text("Location: ${data['location']}"),
            Text("Status: ${data['status']}"),

            const SizedBox(height: 20),

            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: const Center(child: Text("Incident Map Snapshot")),
            ),
          ],
        ),
      ),
    );
  }
}
