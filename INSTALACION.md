# Instalación y ejecución

Este proyecto está pensado para **Flutter**. Sigue estos pasos para dejarlo funcionando.

## 1. Instalar Flutter

1. Descarga el SDK desde la documentación oficial: <https://docs.flutter.dev/get-started/install/windows>
2. Extrae el contenido en una carpeta, por ejemplo `C:\flutter`.
3. Agrega `C:\flutter\bin` a la variable de entorno **Path**:
   - Abrir "Editar las variables de entorno del sistema" → `Path` → Editar → Nuevo → `C:\flutter\bin`.
4. Abre una **nueva** terminal y verifica:

```powershell
flutter doctor
```

> Si el comando no se reconoce, cierra y vuelve a abrir la terminal para que tome el nuevo `Path`.

## 2. Instalar dependencias del proyecto

```powershell
cd hotel_cartagena_flutter
flutter pub get
```

## 3. Ejecutar la aplicación

En el navegador (más rápido para pruebas):

```powershell
flutter run -d chrome
```

O en un emulador/dispositivo conectado:

```powershell
flutter run
```

## 4. Ejecutar las pruebas

```powershell
flutter test
```

## 5. Ver la presentación

Abre `PRESENTACION_RoomsScreen.html` con cualquier navegador.
- Flechas `←` `→` para navegar.
- Tecla `P` para imprimir / guardar como PDF.

## Estructura del proyecto

```
hotel_cartagena_flutter/
├── lib/
│   ├── main.dart
│   ├── enums/            # tipo_habitacion, estado_habitacion
│   ├── models/           # habitacion, huesped, recepcionista, reserva, check_in, check_out
│   ├── services/hotel.dart   # lógica y reglas de negocio (NO se modificó)
│   ├── widgets/mensajes.dart # SnackBars de éxito/error
│   └── screens/          # login, register, home, rooms, reserve, checkin, checkout
├── test/widget_test.dart
├── evidencias/           # capturas y registro de pruebas
├── INFORME_RoomsScreen.md
├── PRESENTACION_RoomsScreen.md
├── PRESENTACION_RoomsScreen.html
├── INSTALACION.md
├── pubspec.yaml
└── analysis_options.yaml
```

## Archivos modificados para la actividad

| Archivo | Cambio |
|---------|--------|
| `lib/screens/rooms_screen.dart` | Rediseño completo: filtro, resumen, botón Reservar, `StatefulWidget`, `RefreshIndicator`, textos |
| `lib/screens/reserve_screen.dart` | Parámetro opcional `numeroInicial` (compatible con el uso anterior) |

> `lib/services/hotel.dart` **no se modificó**: las reglas de negocio siguen en la clase `Hotel`.
