import 'package:flutter/material.dart';

class MapInText extends StatelessWidget {
  const MapInText({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[700],
      body: Directionality(
        textDirection: TextDirection.ltr, // English
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Table(
            border: TableBorder.all(color: Colors.white, width: 1),
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(5)},
            children: [
              // Title Row
              _buildFullWidthRow("Faculty of Science"),
              // Header Row
              _buildRow("Location", "Details", isHeader: true),
              // Data Rows
              _buildRow("Helal Hall", "October Building – Ground Floor"),
              _buildRow("Hegazy Hall", "October Building – Ground Floor"),
              _buildRow(
                "Hammad Hall",
                "First floor, after October stairs – Animal Dept corridor",
              ),
              _buildRow(
                "Louh Hall",
                "First floor, after October stairs – Plant Dept corridor",
              ),
              _buildRow(
                "Room 233 B",
                "First floor corridor between Faculty front and October",
              ),
              _buildRow(
                "Rooms 233–238",
                "First floor corridor between Scoper and October",
              ),
              _buildRow(
                "Hall A/B/C",
                "Basement, stairs between Scoper and October",
              ),
              _buildRow("Hall 1/2/3", "Basement, stairs after October"),
              _buildRow("Room 7", "First floor – end of the main corridor"),
              _buildRow(
                "Faculty Library",
                "Ground floor between Scoper and October",
              ),
              _buildRow("Rooms 11–12", "Basement of the new building"),
              _buildRow(
                "Physics Labs",
                "Outside main faculty building, north after the mosque",
              ),
              _buildRow("Chemistry Labs", "In front of the main mosque gate"),
              _buildRow("IT Unit", "October Building 2"),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(String location, String details, {bool isHeader = false}) {
    final style = TextStyle(
      color: Colors.white,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(location, style: style),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(details, style: style),
        ),
      ],
    );
  }

  TableRow _buildFullWidthRow(String text) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(),
      ],
    );
  }
}
