import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/home/home_screen.dart';

void main() {
  testWidgets('Home screen shows the main signal dashboard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Que no se escape la señal.'), findsOneWidget);
    expect(find.text('BUSCAR MEJOR SEÑAL'), findsOneWidget);
    expect(find.text('ANTENAS CERCANAS'), findsOneWidget);
  });
}
