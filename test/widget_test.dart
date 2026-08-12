import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flickpad/app.dart';
import 'package:flickpad/core/app_settings.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppSettings(),
        child: const FlickPadApp(),
      ),
    );
    expect(find.byType(FlickPadApp), findsOneWidget);
  });
}
