import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wifiber/components/widgets/map_picker.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/services/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selected;
  bool _isFetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetching = true;
      _error = null;
    });
    try {
      final permission = await LocationService.requestLocationPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final location = await LocationService.getCurrentPosition();
        if (location != null) {
          setState(() {
            _selected = location;
          });
        }
      } else {
        setState(() {
          _error = 'Location permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            onPressed: _selected == null
                ? null
                : () {
                    Navigator.of(context).pop(_selected);
                  },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Stack(
        children: [
          MapPicker(
            initialLocation: _selected,
            onLocationPicked: (latlng) {
              setState(() {
                _selected = latlng;
                _error = null;
              });
            },
          ),
          if (_error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.red.shade800,
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _error = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _isFetching ? null : _getCurrentLocation,
        child: _isFetching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}
