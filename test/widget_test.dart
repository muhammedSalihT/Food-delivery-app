import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/app/app.dart';

void main() {
  testWidgets('FoodDeliveryApp launches with MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FoodDeliveryApp()));

    // Initial pump
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
