import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wifiber/components/widgets/map_picker_page.dart';
import 'package:wifiber/services/location_service.dart';

class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng?) onLocationChanged;
  final String? Function(LatLng?)? validator;
  final bool isRequired;
  final String label;
  final String? helperText;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationChanged,
    this.validator,
    this.isRequired = true,
    this.label = 'Koordinat Lokasi',
    this.helperText,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  LatLng? _selectedLocation;
  bool _isFetchingLocation = false;
  String? _locationError;
  bool _isMapLoading = true;
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _mapController = MapController();
    if (_selectedLocation != null) {
      _isMapLoading = false;
    }
  }

  @override
  void didUpdateWidget(LocationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialLocation != widget.initialLocation) {
      setState(() {
        _selectedLocation = widget.initialLocation;
        if (_selectedLocation != null && !_isMapLoading) {
          // sudah ada peta, jangan loading ulang
        } else if (_selectedLocation != null) {
          _isMapLoading = false;
        }
      });

      if (widget.initialLocation != null &&
          _mapController != null &&
          !_isMapLoading) {
        _moveMapToLocation(widget.initialLocation!);
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Helper untuk memindahkan peta
  void _moveMapToLocation(LatLng location, {double zoom = 15.0}) {
    if (_mapController != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController!.move(location, zoom);
        } catch (e) {
          debugPrint('Error moving map: $e');
        }
      });
    }
  }

  Future<void> _pickCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      final permission = await LocationService.requestLocationPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final location = await LocationService.getCurrentPosition();
        if (location != null) {
          setState(() {
            _selectedLocation = location;
            _isMapLoading = false;
          });
          widget.onLocationChanged(_selectedLocation);

          _moveMapToLocation(location);
        }
      } else {
        setState(() {
          _locationError = 'Location permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialLocation: _selectedLocation),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
        _locationError = null;
        _isMapLoading = false;
      });
      widget.onLocationChanged(_selectedLocation);

      _moveMapToLocation(result);
    }
  }

  String _getLocationDisplayText() {
    if (_selectedLocation != null) {
      return '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
    }
    return 'Pilih Lokasi';
  }

  void _onMapReady() {
    if (mounted) {
      setState(() {
        _isMapLoading = false;
      });

      if (_selectedLocation != null && _mapController != null) {
        _moveMapToLocation(_selectedLocation!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError =
        widget.validator?.call(_selectedLocation) != null ||
        _locationError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.isRequired ? '' : ' (Opsional)'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: hasError ? Colors.red : Colors.grey.shade300,
              width: hasError ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: _openMapPicker,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedLocation != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _selectedLocation != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getLocationDisplayText(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _selectedLocation != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: _selectedLocation != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isFetchingLocation
                            ? null
                            : _pickCurrentLocation,
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        tooltip: 'Gunakan Lokasi Saat Ini',
                      ),
                    ],
                  ),

                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _selectedLocation!,
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                                backgroundColor: Colors.grey.shade100,
                                onMapReady: _onMapReady,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'id.kodinus.wifiber',
                                ),

                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
                                      width: 32,
                                      height: 32,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                      alignment: Alignment.topCenter,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (_isMapLoading)
                              Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),

                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Lokasi telah dipilih. Ketuk untuk mengubah.',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt,
                            size: 32,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk untuk pilih lokasi di peta',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        if (widget.validator?.call(_selectedLocation) != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.validator!(_selectedLocation)!,
            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
          ),
        ],

        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _locationError!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
