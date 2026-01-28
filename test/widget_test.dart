// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:code_app_pro/main.dart';
import 'package:code_app_pro/providers/app_state_provider.dart';
import 'package:code_app_pro/widgets/main_layout.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
        child: const CodeEditorApp(initialDirectory: '/test'),
      ),
    );

    // Verify that our app starts with correct title
    expect(find.text('代码编辑器 Pro'), findsOneWidget);
  });

  testWidgets('File bar is visible on large screens', (
    WidgetTester tester,
  ) async {
    // Build our app with a large screen size
    tester.view.physicalSize = const Size(1200, 800);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
        child: const CodeEditorApp(initialDirectory: '/test'),
      ),
    );

    // Verify that file bar is visible on large screens
    expect(find.byType(MainLayout), findsOneWidget);

    // Reset window size
    tester.view.resetPhysicalSize();
  });
}
