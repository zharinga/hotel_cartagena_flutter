import 'package:flutter/material.dart';

import '../enums/tipo_habitacion.dart';
import '../models/habitacion.dart';
import '../services/hotel.dart';
import 'reserve_screen.dart';

/// Ventana de consulta de habitaciones disponibles (RF03), rediseñada.
///
/// Versión mejorada a partir de la original ([StatelessWidget] con un
/// [ExpansionTile] por tipo). Los cambios principales son:
///
/// 1. Cada habitación tiene un botón "Reservar" que abre [ReserveScreen]
///    con el número ya cargado (resuelve el problema de tener que volver
///    al menú y escribir el número de memoria).
/// 2. Filtro "¿Cuántas personas?" para mostrar solo las habitaciones cuya
///    capacidad sirve al grupo (solo afecta la presentación).
/// 3. Resumen superior con habitaciones disponibles, reservadas y
///    ocupadas, para tener un panorama general del hotel.
/// 4. Es [StatefulWidget]: se actualiza al volver de una reserva y
///    admite [RefreshIndicator] para refrescar manualmente.
/// 5. Limpieza visual: se quitó el chip de estado redundante, la
///    capacidad usa ícono de persona, se corrigieron los plurales y el
///    estado vacío sugiere qué hacer.
///
/// Las reglas de negocio siguen viviendo en [Hotel]; esta pantalla solo
/// lee datos para presentarlos.
class RoomsScreen extends StatefulWidget {
  final Hotel hotel;

  const RoomsScreen({super.key, required this.hotel});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

/// Opción del filtro "¿Cuántas personas?".
///
/// [minimo] es la capacidad mínima que debe tener la habitación para
/// aparecer cuando se selecciona la opción.
class _FiltroPersonas {
  final String etiqueta;
  final int minimo;

  const _FiltroPersonas(this.etiqueta, this.minimo);
}

class _RoomsScreenState extends State<RoomsScreen> {
  /// Opciones del filtro, en orden de presentación. "Todas" equivale a
  /// no filtrar (capacidad mínima 1, es decir, cualquier habitación).
  static const _filtros = [
    _FiltroPersonas('Todas', 1),
    _FiltroPersonas('1', 1),
    _FiltroPersonas('2', 2),
    _FiltroPersonas('3–4', 3),
  ];

  /// Índice de la opción seleccionada en [_filtros].
  int _filtroSeleccionado = 0;

  /// Devuelve true si la habitación tiene capacidad suficiente para la
  /// opción de filtro seleccionada. Es solo una condición de
  /// presentación: no valida nada en [Hotel].
  bool _cumpleFiltro(Habitacion h, int minimo) => h.capacidad >= minimo;

  /// Forma el plural de una palabra según la cantidad (p. ej.
  /// "disponible" -> "disponibles", "persona" -> "personas").
  String _plural(int cantidad, String palabra) =>
      cantidad == 1 ? palabra : '${palabra}s';

  /// Abre la pantalla de reserva con el número de habitación ya
  /// escrito. Al regresar, reconstruye la lista para que la habitación
  /// recién reservada desaparezca (paso 4 de las mejoras).
  Future<void> _irAReservar(Habitacion habitacion) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReserveScreen(
          hotel: widget.hotel,
          numeroInicial: habitacion.numero,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  /// Recarga la vista. [Hotel] vive en memoria, así que basta con
  /// reconstruir el árbol para reflejar el estado actual.
  Future<void> _refrescar() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final minimo = _filtros[_filtroSeleccionado].minimo;

    return Scaffold(
      appBar: AppBar(title: const Text('Habitaciones disponibles')),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ResumenHotel(hotel: widget.hotel),
            const SizedBox(height: 16),
            Text(
              '¿Cuántas personas?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < _filtros.length; i++)
                  ChoiceChip(
                    label: Text(_filtros[i].etiqueta),
                    selected: _filtroSeleccionado == i,
                    onSelected: (_) =>
                        setState(() => _filtroSeleccionado = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._secciones(minimo),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta desplegable por tipo de habitación con las
  /// habitaciones disponibles que cumplen el filtro. Si ningún tipo
  /// tiene resultados, muestra un único mensaje con una sugerencia.
  List<Widget> _secciones(int minimo) {
    final Map<TipoHabitacion, List<Habitacion>> agrupadas =
        widget.hotel.consultarDisponiblesAgrupadas();

    final secciones = <Widget>[];
    bool hayAlMenosUna = false;

    for (final tipo in TipoHabitacion.values) {
      final habitaciones = agrupadas[tipo]!
          .where((h) => _cumpleFiltro(h, minimo))
          .toList();
      if (habitaciones.isNotEmpty) hayAlMenosUna = true;

      secciones.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            // Se muestra ya expandida para ver de inmediato cuántas
            // habitaciones hay de cada tipo.
            initiallyExpanded: true,
            title: Text(
              '$tipo (${habitaciones.length} '
              '${_plural(habitaciones.length, 'disponible')})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: habitaciones.isEmpty
                ? const [
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Sin habitaciones disponibles'),
                    ),
                  ]
                : habitaciones
                    .map(
                      (h) => _HabitacionTile(
                        habitacion: h,
                        onReservar: () => _irAReservar(h),
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }

    if (!hayAlMenosUna) {
      return [
        const Card(
          child: ListTile(
            leading: Icon(Icons.search_off),
            title: Text('No hay habitaciones disponibles'),
            subtitle: Text(
              'Ajusta el filtro de personas o vuelve más tarde.',
            ),
          ),
        ),
      ];
    }

    return secciones;
  }
}

/// Fila de una habitación disponible, con su capacidad y el botón que
/// abre la reserva con el número ya cargado.
class _HabitacionTile extends StatelessWidget {
  final Habitacion habitacion;
  final VoidCallback onReservar;

  const _HabitacionTile({
    required this.habitacion,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final capacidad = habitacion.capacidad;
    return ListTile(
      leading: const Icon(Icons.door_front_door),
      title: Text('Habitación ${habitacion.numero}'),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 18),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$capacidad ${capacidad == 1 ? 'persona' : 'personas'}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: FilledButton.tonal(
        onPressed: onReservar,
        child: const Text('Reservar'),
      ),
    );
  }
}

/// Resumen superior con el total de habitaciones por estado, leído
/// directamente de [Hotel.habitaciones] (solo lectura, sin validaciones).
class _ResumenHotel extends StatelessWidget {
  final Hotel hotel;

  const _ResumenHotel({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final disponibles =
        hotel.habitaciones.where((h) => h.estaDisponible).length;
    final reservadas = hotel.habitaciones.where((h) => h.estaReservada).length;
    final ocupadas = hotel.habitaciones.where((h) => h.estaOcupada).length;

    return Row(
      children: [
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.check_circle,
            titulo: 'Disponibles',
            valor: disponibles,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.event_available,
            titulo: 'Reservadas',
            valor: reservadas,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.bed,
            titulo: 'Ocupadas',
            valor: ocupadas,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta pequeña de conteo usada por [_ResumenHotel].
class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final int valor;
  final Color color;

  const _TarjetaResumen({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 4),
            Text(
              '$valor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(titulo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
