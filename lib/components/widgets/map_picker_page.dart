import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wifiber/components/widgets/map_picker.dart';
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
          TextButton(
            onPressed: _selected == null
                ? null
                : () {
                    Navigator.of(context).pop(_selected);
                  },
            child: const Text('SIMPAN', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Stack(
        children: [
          MapPicker(
            initialLocation: _selected,
            onLocationPicked: (latlng) {
              setState(() {
                _selected = latlng;
              });
            },
          ),
          if (_error != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isFetching ? null : _getCurrentLocation,
        child: _isFetching
            ? const CircularProgressIndicator()
            : const Icon(Icons.my_location),
      ),
    );
  }
}

