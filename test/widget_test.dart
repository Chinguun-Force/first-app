import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // SharedPreferences initializer-ыг mock хийх боломжтой ч энэ нь энгийн smoke test юм.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Нэвтрэх дэлгэц харагдаж байгаа эсэхийг шалгах (Redirect find-аар)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
