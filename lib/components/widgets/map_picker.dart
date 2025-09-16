import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final void Function(LatLng) onLocationPicked;

  const MapPicker({
    super.key,
    this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng? _selected;
  final MapController _mapController = MapController();

  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void didUpdateWidget(MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation &&
        widget.initialLocation != null) {
      setState(() {
        _selected = widget.initialLocation;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.initialLocation!, 16);
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _selected = latlng;
    });
    widget.onLocationPicked(latlng);
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter =
        widget.initialLocation ?? _selected ?? _defaultLocation;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onTap: _onMapTap,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'id.kodinus.wifiber',
          maxZoom: 18,
          subdomains: const ['a', 'b', 'c'],
          errorTileCallback: (tile, error, stackTrace) {},
        ),
        if (_selected != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selected!,
                width: 50,
                height: 50,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                  shadows: [
                    Shadow(
                      blurRadius: 3,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            color: Colors.white70,
            child: const Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
