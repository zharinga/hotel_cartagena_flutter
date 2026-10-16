# Presentación — Rediseño de `RoomsScreen` (Hotel Cartagena)

> Duración sugerida: 7–10 minutos. Abre con `PRESENTACION_RoomsScreen.html` en el navegador (se puede imprimir a PDF).

---

## Diapositiva 1 — La pantalla y su propósito

**Pantalla asignada:** `lib/screens/rooms_screen.dart` — `RoomsScreen`
**Requisito funcional:** RF03 — consultar habitaciones disponibles.

**Qué hace:** muestra las habitaciones disponibles agrupadas por tipo (Sencilla, Doble, Suite) con su capacidad.

**Tarea del usuario:** encontrar rápido una habitación que le sirva al huésped y reservarla sin equivocarse de número.

**Flujo en el sistema:** Login → Menú → *Consultar habitaciones* → (Reservar → Check-in → Check-out).

---

## Diapositiva 2 — Diagnóstico de la versión original

| # | Problema | Consecuencia | Evidencia |
|---|----------|--------------|-----------|
| P1 | Chip de estado siempre "Disponible" en verde | Ruido visual sin información | `_EstadoChip` (líneas 75–92) |
| P2 | Las filas no llevan a ninguna acción | Hay que volver al menú y escribir el número | `ListTile` sin `onTap` |
| P3 | No ayuda a elegir según el número de huéspedes | El recepcionista deduce qué tipo sirve | Capacidad solo como texto |
| P4 | No hay panorama general del hotel | Con "0 disponibles" no se sabe el estado real | Solo se listan disponibles |
| P5 | Los datos pueden quedar desactualizados | No hay forma de refrescar | `StatelessWidget`, sin `RefreshIndicator` |
| P6 | Textos poco naturales y estado vacío sin orientación | Lectura menos clara | "disponible(s)", "persona(s)" |

**Criterio usado:** jerarquía visual, organización, legibilidad, consistencia, interacción, retroalimentación y adaptabilidad.

---

## Diapositiva 3 — Propuesta de solución

**Boceto de la nueva pantalla:**

```
┌───────────────────────────────────────────┐
│ Habitaciones disponibles                  │
├───────────────────────────────────────────┤
│  [ 9 ]      [ 0 ]      [ 0 ]             │ ← Resumen
│ Disponibles Reservadas Ocupadas           │
│                                           │
│ ¿Cuántas personas?                        │
│ (Todas) (1) (2) (3–4)                     │ ← Filtro
│                                           │
│ ▼ Sencilla (3 disponibles)                │
│   🚪 Habitación 101   👤 1 persona        │
│                          [ Reservar ]     │ ← Acción
│ ▼ Doble (3 disponibles)                   │
│ ▼ Suite (3 disponibles)                   │
└───────────────────────────────────────────┘
```

**Relación cambio → problema:**
- Resumen → P4
- Filtro de personas → P3
- Botón Reservar → P2
- Actualización → P5
- Limpieza de textos → P1 y P6

---

## Diapositiva 4 — Comparación antes y después

| Antes | Después |
|-------|---------|
| Solo lista de disponibles | Resumen + filtro + lista |
| Chip verde redundante en cada fila | Sin chip; capacidad con ícono |
| Sin acción en las filas | Botón "Reservar" por habitación |
| `StatelessWidget` | `StatefulWidget` + `RefreshIndicator` |
| "3 disponible(s)" / "2 persona(s)" | "3 disponibles" / "2 personas" |

**Cambios principales a destacar:** (1) acción directa, (2) filtro por huéspedes, (3) resumen general, (4) actualización, (5) textos limpios.

---

## Diapositiva 5 — Implementación técnica

**`rooms_screen.dart` pasa a `StatefulWidget`** para guardar el filtro y reconstruir la vista.

```dart
Future<void> _irAReservar(Habitacion habitacion) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReserveScreen(
        hotel: widget.hotel,
        numeroInicial: habitacion.numero,
      ),
    ),
  );
  if (mounted) setState(() {}); // la habitación reservada desaparece
}
```

**Widgets usados:** `RefreshIndicator`, `ListView`, `Card`, `ExpansionTile`, `ListTile`, `ChoiceChip`, `Wrap`, `FilledButton.tonal`, `Row`/`Expanded`.

**Cambio mínimo fuera de la pantalla:** parámetro opcional `numeroInicial` en `ReserveScreen` (no altera su comportamiento si no se envía).

---

## Diapositiva 6 — Demostración funcional

**Acciones a mostrar en vivo:**
1. Abrir "Consultar habitaciones": se ve el resumen y el filtro.
2. Seleccionar "3–4": solo aparecen Suites.
3. Pulsar "Reservar" en la 104: `ReserveScreen` abre con "104".
4. Confirmar la reserva y volver: la 104 desaparece y el resumen cambia.
5. Poner 0 días: aparece el error de validación.
6. Reservar dos veces la misma habitación: `HotelException`.

---

## Diapositiva 7 — Evidencias y resultados

**Automatizadas (`flutter test`): 5/5 ✅**

| Prueba | Qué verifica | Resultado |
|--------|--------------|-----------|
| A1 | Resumen + filtro visibles, 9 botones "Reservar" | **Comprobado** |
| A2 | Filtro "3–4" deja solo las Suites | **Comprobado** |
| A3 | Botón "Reservar" abre con "101" | **Comprobado** |
| A4 | Estado vacío con sugerencia | **Comprobado** |

**Manuales (por ejecutar en Chrome):** 0 días, doble reserva, pantalla angosta, refresh.

**Rigor:** lo no verificado se reporta como *esperado*, no como demostrado.

---

## Diapositiva 8 — Conclusiones

- **Problema más importante:** la pantalla no permitía actuar (P2).
- **Solución elegida:** botón de reserva directa con el número precargado, porque elimina el paso manual que causaba errores.
- **Principio de UX aplicado:** reducir pasos y prevenir errores (más que decorar).
- **Widget clave:** `FilledButton.tonal` + `Navigator.push` con `numeroInicial`.
- **Qué conservé y por qué:** toda la lógica en `Hotel`; la interfaz solo presenta y delega.
- **Cómo comprobé que funciona:** pruebas de las diapositivas 6 y 7.
- **Hipótesis aún no comprobada:** que el filtro reduce el tiempo de elección (requiere prueba con usuarios).
