import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tienda1/app_state.dart';
import 'package:tienda1/main.dart';
import 'package:tienda1/services/local_store.dart';

void main() {
  testWidgets('muestra configuración inicial y permite cargar datos demo', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final state = AppState(LocalStore(preferences));
    await state.load();
    await tester.pumpWidget(DetectorApp(state: state));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    await tester.tap(find.text('Crear una cuenta nueva'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@negocio.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();
    expect(find.text('Configuremos tu negocio'), findsOneWidget);
    await tester.ensureVisible(find.text('Explorar con datos demo'));
    await tester.tap(find.text('Explorar con datos demo'));
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsWidgets);
    expect(state.products.length, 6);
    expect(state.alerts, isNotEmpty);
  });
}
