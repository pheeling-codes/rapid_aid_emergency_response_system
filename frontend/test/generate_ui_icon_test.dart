import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate Logo via Canvas', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw shadow
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(64, 64, 384, 384),
      const Radius.circular(64),
    );
    canvas.drawRRect(rrect.shift(const Offset(0, 12)), Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    
    // Draw white box
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    // Draw asterisk path
    final path = Path()
      ..moveTo(236, 128)
      ..lineTo(276, 128)
      ..lineTo(276, 236)
      ..lineTo(380, 206)
      ..lineTo(396, 242)
      ..lineTo(306, 276)
      ..lineTo(396, 310)
      ..lineTo(380, 346)
      ..lineTo(276, 316)
      ..lineTo(276, 424)
      ..lineTo(236, 424)
      ..lineTo(236, 316)
      ..lineTo(132, 346)
      ..lineTo(116, 310)
      ..lineTo(206, 276)
      ..lineTo(116, 242)
      ..lineTo(132, 206)
      ..lineTo(236, 236)
      ..close();

    final pathPaint = Paint()
      ..color = const Color(0xFF005EB8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, pathPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(512, 512);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    File('assets/icon.png').writeAsBytesSync(byteData!.buffer.asUint8List());
  });
}
