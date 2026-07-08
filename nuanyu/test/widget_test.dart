import 'package:flutter_test/flutter_test.dart';
import 'package:nuanyu/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const NuanYuApp());
    expect(find.text('呼吸'), findsOneWidget);
  });
}
