import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weld_inspection_app/app/app.dart';

void main() {
  testWidgets('desktop navigation opens every screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeldInspectionApp()));

    expect(find.text('Weld Inspection Dashboard'), findsOneWidget);

    await tester.tap(find.text('New Inspection').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Upload a weld or fabrication image to begin an automated quality inspection.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Inspection History').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Completed inspection records will be listed here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Reports').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Inspection reports and exports will be available here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Application preferences and configuration will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Dashboard').first);
    await tester.pumpAndSettle();
    expect(find.text('Weld Inspection Dashboard'), findsOneWidget);
  });
}
