import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// MAP PLACEHOLDER
        Container(
          color: Colors.grey.shade300,
          child: const Center(child: Text("MAP VIEW")),
        ),

        /// TOP SEARCH BAR
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search location...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        /// FLOATING BUTTON
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
