import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_aid/core/widgets/rapid_aid_logo.dart'; 

void main() {
  testWidgets('Generate Logo', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: const ColorScheme.light(primary: Color(0xFF005EB8))),
        home: const Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: ValueKey('logo'),
              child: RapidAidLogo(size: 512, iconSize: 340),
            ),
          ),
        ),
      ),
    );
    final finder = find.byKey(const ValueKey('logo'));
    final boundary = tester.renderObject(finder) as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    File('assets/icon.png').writeAsBytesSync(buffer);
  });
}
