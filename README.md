# Hotel Cartagena — Rediseño de `RoomsScreen`

Proyecto Flutter de la actividad **"De comprender el código a transformar la
experiencia"** (Electiva II · Dart y Flutter).

Pantalla rediseñada: `lib/screens/rooms_screen.dart` (RF03: consultar
habitaciones disponibles).

**App desplegada:** http://sparkling-biscuit-b82c5e.netlify.app/

## Contenido

| Archivo / carpeta | Descripción |
|-------------------|-------------|
| `lib/` | Código fuente de la aplicación |
| `lib/screens/rooms_screen.dart` | **Pantalla rediseñada** (filtro, resumen, botón Reservar, `StatefulWidget`, `RefreshIndicator`) |
| `lib/screens/reserve_screen.dart` | Recibe `numeroInicial` opcional |
| `lib/services/hotel.dart` | Lógica y reglas de negocio (sin cambios) |
| `test/rooms_screen_test.dart` | Pruebas automatizadas de las mejoras |

## Ejecutar

```powershell
flutter pub get
flutter run -d chrome
```

## Pruebas

```powershell
flutter test
```

## Mejoras implementadas

1. **Botón "Reservar"** por habitación (abre la reserva con el número precargado).
2. **Filtro "¿Cuántas personas?"** (Todas · 1 · 2 · 3–4).
3. **Resumen superior** de disponibles, reservadas y ocupadas.
4. **Actualización automática y manual** (`StatefulWidget` + `RefreshIndicator`).
5. **Limpieza visual y textos** (sin chip redundante, ícono de persona, plurales y estado vacío con sugerencia).
