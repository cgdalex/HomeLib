import 'package:flutter_test/flutter_test.dart';
import 'package:home_lib/main.dart';

void main() {
  testWidgets('HomeLIB app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeLibApp());

    expect(find.text('HomeLIB'), findsOneWidget);
  });
}