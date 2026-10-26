import 'package:app_nfce/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe a tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Nota Clara'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
