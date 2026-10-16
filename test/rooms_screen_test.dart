import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_cartagena_flutter/enums/tipo_habitacion.dart';
import 'package:hotel_cartagena_flutter/models/huesped.dart';
import 'package:hotel_cartagena_flutter/screens/rooms_screen.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

/// Pruebas de widget de la versión rediseñada de [RoomsScreen].
///
/// Verifican las mejoras implementadas: resumen superior, filtro por
/// número de personas, botón "Reservar" que abre la reserva con el
/// número precargado y estado vacío con sugerencia.
void main() {
  testWidgets('Muestra el resumen y el filtro de personas',
      (WidgetTester tester) async {
    // Superficie alta para que el ListView construya las 9 filas.
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(home: RoomsScreen(hotel: Hotel())));

    // Resumen superior (mejora M3).
    expect(find.text('Disponibles'), findsOneWidget);
    expect(find.text('Reservadas'), findsOneWidget);
    expect(find.text('Ocupadas'), findsOneWidget);

    // Filtro de personas (mejora M2).
    expect(find.text('¿Cuántas personas?'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('3–4'), findsOneWidget);

    // Hay 9 habitaciones iniciales (3 por tipo), cada una con su botón.
    expect(find.text('Reservar'), findsNWidgets(9));
  });

  testWidgets('El filtro "3–4" deja solo las Suites', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RoomsScreen(hotel: Hotel())));

    await tester.tap(find.text('3–4'));
    await tester.pumpAndSettle();

    // Sencilla y Doble no tienen capacidad para 3–4 personas.
    expect(find.text('Sin habitaciones disponibles'), findsNWidgets(2));
    // Solo quedan las 3 Suites.
    expect(find.text('Reservar'), findsNWidgets(3));
  });

  testWidgets('El botón "Reservar" abre la reserva con el número cargado',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RoomsScreen(hotel: Hotel())));

    await tester.tap(find.text('Reservar').first);
    await tester.pumpAndSettle();

    // Se abrió ReserveScreen con el número de la primera habitación (101).
    expect(find.text('Reservar habitación'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '101'), findsOneWidget);
  });

  testWidgets('El estado vacío sugiere qué hacer', (WidgetTester tester) async {
    final hotel = Hotel();
    // Reserva las 3 Suites para que el filtro "3–4" no encuentre ninguna.
    for (final h in hotel.habitaciones) {
      if (h.tipo == TipoHabitacion.suite) {
        hotel.reservarHabitacion(
          huesped: Huesped(nombre: 'Test', documento: '000'),
          numeroHabitacion: h.numero,
          dias: 1,
        );
      }
    }

    await tester.pumpWidget(MaterialApp(home: RoomsScreen(hotel: hotel)));
    await tester.tap(find.text('3–4'));
    await tester.pumpAndSettle();

    expect(find.text('No hay habitaciones disponibles'), findsOneWidget);
    expect(find.textContaining('Ajusta el filtro'), findsOneWidget);
  });
}
