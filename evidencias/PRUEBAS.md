# Registro de pruebas — `RoomsScreen` mejorada

**Fecha:** ____________________
**Dispositivo / navegador:** ____________________

## A. Pruebas automatizadas (`flutter test`)

Comando: `flutter test` → **5/5 tests pasan** (4 de `rooms_screen_test.dart` + 1 original de login).

| # | Prueba | Qué verifica | Resultado | ¿Cumple? |
|---|--------|--------------|-----------|----------|
| A1 | Muestra el resumen y el filtro | Aparecen "Disponibles / Reservadas / Ocupadas", el filtro "¿Cuántas personas?" y los 9 botones "Reservar" | **Comprobado** | ✅ |
| A2 | El filtro "3–4" deja solo las Suites | Aparecen 2 avisos "Sin habitaciones disponibles" y 3 botones "Reservar" | **Comprobado** | ✅ |
| A3 | El botón "Reservar" abre la reserva con el número | Se abre `ReserveScreen` y el campo número contiene "101" | **Comprobado** | ✅ |
| A4 | El estado vacío sugiere qué hacer | Con las Suites reservadas y filtro "3–4", aparece "No hay habitaciones disponibles" + "Ajusta el filtro…" | **Comprobado** | ✅ |

## B. Pruebas manuales (en Chrome)

| # | Escenario | Acción | Resultado esperado | Resultado obtenido | ¿Cumple? | Evidencia |
|---|-----------|--------|--------------------|--------------------|----------|-----------|
| M1 | Uso normal | Filtrar por 2 personas y reservar la 104 desde la lista | `ReserveScreen` abre con "104"; al volver, la 104 ya no aparece y el resumen se actualiza | *(pendiente)* | — | `05_...`, `02_...` |
| M2 | Datos incorrectos | En la reserva precargada, poner 0 días | El formulario y `Hotel` rechazan la reserva con mensaje de error | *(pendiente)* | — | |
| M3 | Error de negocio | Reservar dos veces la misma habitación | `HotelException`: "La habitación X no está disponible." | *(pendiente)* | — | |
| M4 | Sin resultados | Reservar las 3 Suites y filtrar por 3–4 personas | Estado vacío con sugerencia, sin errores | *(pendiente)* | — | `06_...` |
| M5 | Otro tamaño de pantalla | Ejecutar en ventana angosta (≈360 px) y ancha | Sin desbordes; contenido legible | *(pendiente)* | — | `07_...` |
| M6 | Refresco manual | Arrastrar hacia abajo en la lista | La vista se reconstruye sin errores | *(pendiente)* | — | |
| M7 | Resumen | Reservar una habitación | El contador de "Disponibles" baja y el de "Reservadas" sube | *(pendiente)* | — | `02_...` |

## Observaciones

- 
- 

## Conclusión

- **Comprobado:** A1, A2, A3, A4 (verificados por `flutter test`).
- **Observado:** el cambio a `StatefulWidget` y el `RefreshIndicator` están en el código; falta verificar el comportamiento en Chrome (M1, M6, M7).
- **Esperado:** que el filtro reduce el tiempo de elección (requiere prueba con usuarios).
