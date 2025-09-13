import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/infrastructure.dart';
import 'package:wifiber/providers/infrastructure_provider.dart';
import 'package:wifiber/controllers/infrastructure_controller.dart';
import 'package:wifiber/components/widgets/infrastructure_widget.dart';
import 'package:wifiber/components/widgets/location_widgets.dart';
import 'package:wifiber/services/location_service.dart';

class InfrastructureHome extends StatefulWidget {
  const InfrastructureHome({super.key});

  @override
  State<InfrastructureHome> createState() => _InfrastructureHomeState();
}

class _InfrastructureHomeState extends State<InfrastructureHome> {
  InfrastructureController? _controller;
  late MapController _mapController;
  late DraggableScrollableController _draggableController;
  InfrastructureProvider? _provider;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _draggableController = DraggableScrollableController();
    _setupSystemUI();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<InfrastructureProvider>(context, listen: false);
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider ??= Provider.of<InfrastructureProvider>(context, listen: false);
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_provider == null) return;

      _controller = InfrastructureController(
        provider: _provider!,
        mapController: _mapController,
        draggableController: _draggableController,
      );

      await _provider!.loadData(InfrastructureType.olt);
      _provider!.addListener(_onProviderChanged);

      if (mounted) {
        _controller!.animateMapToDataCenter();
      }
    });
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _onProviderChanged() {
    if (mounted && _controller != null) {
      _controller!.animateMapToDataCenter();
    }
  }

  void _onLocationButtonPressed() async {
    if (_provider == null || _controller == null) return;

    final hasPermission = await _controller!.handleLocationPermission(context);
    if (hasPermission) {
      await _controller!.getUserLocationAndUpdateMap();
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: Colors.transparent,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: colorScheme.surface,
        body: Consumer<InfrastructureProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                _buildMap(provider),
                _buildBackButton(context),
                _buildLocationFAB(provider),
                _buildDraggableSheet(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap(InfrastructureProvider provider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(-6.17511, 106.86503),
          initialZoom: 13.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.kodinus.wifiber',
            additionalOptions: {'userAgentPackageName': 'com.kodinus.wifiber'},
          ),
          MarkerLayer(
            markers: [
              if (provider.hasUserLocation)
                LocationWidgets.buildUserLocationMarker(provider.userLocation!),

              ...InfrastructureWidgets.buildMapMarkers(
                provider.items,
                provider.activeType,
                (item) => _showMarkerInfo(item, provider.activeType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFAB(InfrastructureProvider provider) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: LocationWidgets.buildLocationFAB(
        onPressed: _onLocationButtonPressed,
        isLoading: provider.isLocationLoading,
        hasLocation: provider.hasUserLocation,
      ),
    );
  }

  Widget _buildDraggableSheet(InfrastructureProvider provider) {
    return DraggableScrollableSheet(
      minChildSize: 0.25,
      initialChildSize: 0.25,
      maxChildSize: 0.9,
      snap: true,
      controller: _draggableController,
      snapSizes: const [0.25, 0.5, 0.9],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildFilterButtons(provider),
              if (provider.locationError != null)
                LocationWidgets.buildLocationError(
                  error: provider.locationError!,
                  onRetry: _onLocationButtonPressed,
                ),
              if (provider.hasUserLocation && !provider.isLocationLoading)
                _buildNearestItemInfo(provider),
              Expanded(
                child: _buildScrollableContent(scrollController, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      onVerticalDragStart: _controller?.handleDragStart,
      onVerticalDragUpdate: (details) =>
          _controller?.handleDragUpdate(details, context),
      onVerticalDragEnd: _controller?.handleDragEnd,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 16, top: 8),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: 40,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(InfrastructureProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          InfrastructureWidgets.buildFilterButton(
            'OLT',
            provider.activeType == InfrastructureType.olt,
            () => _controller?.onFilterTap(InfrastructureType.olt),
          ),
          const SizedBox(width: 8),
          InfrastructureWidgets.buildFilterButton(
            'ODP',
            provider.activeType == InfrastructureType.odp,
            () => _controller?.onFilterTap(InfrastructureType.odp),
          ),
          const SizedBox(width: 8),
          InfrastructureWidgets.buildFilterButton(
            'ODC',
            provider.activeType == InfrastructureType.odc,
            () => _controller?.onFilterTap(InfrastructureType.odc),
          ),
        ],
      ),
    );
  }

  Widget _buildNearestItemInfo(InfrastructureProvider provider) {
    final nearestItem = provider.getNearestItem();
    if (nearestItem == null) return const SizedBox.shrink();

    final distance = provider.userLocation != null
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(nearestItem.lat!, nearestItem.lng!),
          )
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.activeType.displayName} Terdekat',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  nearestItem.getCode(provider.activeType),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (distance != null)
            LocationWidgets.buildDistanceChip(
              distance < 1000
                  ? '${distance.round()} m'
                  : '${(distance / 1000).toStringAsFixed(1)} km',
            ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
    ScrollController scrollController,
    InfrastructureProvider provider,
  ) {
    if (provider.isLoading) {
      return InfrastructureWidgets.buildLoadingState(scrollController);
    }

    if (provider.hasError) {
      return InfrastructureWidgets.buildErrorState(
        scrollController,
        provider.error!,
        () => _controller?.refreshCurrentData(),
      );
    }

    if (!provider.hasData) {
      return InfrastructureWidgets.buildEmptyState(
        scrollController,
        provider.activeType.displayName,
      );
    }

    final itemsWithDistance = provider.getItemsWithDistance();
    final nearestItem = provider.getNearestItem();

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemsWithDistance.length,
      itemBuilder: (context, index) {
        final itemWithDistance = itemsWithDistance[index];
        final item = itemWithDistance.item;
        final isNearest =
            nearestItem != null &&
            item.getCode(provider.activeType) ==
                nearestItem.getCode(provider.activeType);

        return _buildDataItemWithDistance(
          itemWithDistance,
          provider.activeType,
          isNearest,
          () => _showMarkerInfo(item, provider.activeType),
        );
      },
    );
  }

  Widget _buildDataItemWithDistance(
    InfrastructureItemWithDistance itemWithDistance,
    InfrastructureType type,
    bool isNearest,
    VoidCallback onTap,
  ) {
    final item = itemWithDistance.item;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(type.icon, color: AppColors.primary),
        title: Text("${type.displayName} ${item.getCode(type)}"),
        subtitle: Wrap(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (item.status == 'active' ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status == 'active' ? "Aktif" : "Tidak Aktif",
                style: TextStyle(
                  fontSize: 12,
                  color: (item.status == 'active' ? Colors.green : Colors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isNearest) LocationWidgets.buildNearestItemIndicator(),
            if (itemWithDistance.distance != null)
              LocationWidgets.buildDistanceChip(
                itemWithDistance.formattedDistance,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showMarkerInfo(InfrastructureItem item, InfrastructureType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(item, type),
                if (item.hasValidCoordinates()) ...[
                  const SizedBox(height: 16),
                  _buildMapSection(item),
                  const SizedBox(height: 16),
                  _buildActionButtons(item),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(InfrastructureItem item, InfrastructureType type) {
    final kode = item.getCode(type);
    final provider = Provider.of<InfrastructureProvider>(
      context,
      listen: false,
    );
    final distance = provider.userLocation != null && item.hasValidCoordinates()
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(item.lat!, item.lng!),
          )
        : null;

    return InfrastructureWidgets.buildDetailSection(
      '${type.displayName} Info',
      [
        InfrastructureWidgets.buildDetailItem(Icons.info, 'Kode', kode),
        InfrastructureWidgets.buildDetailItem(
          Icons.info,
          'Nama',
          item.name ?? 'N/A',
        ),
        InfrastructureWidgets.buildDetailItem(
          Icons.info,
          'Status',
          item.status != null
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (item.status == 'active' ? Colors.green : Colors.red)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status == 'active' ? "Aktif" : "Tidak Aktif",
                    style: TextStyle(
                      fontSize: 12,
                      color: (item.status == 'active'
                          ? Colors.green
                          : Colors.red),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : 'N/A',
        ),
        InfrastructureWidgets.buildDetailItem(
          Icons.info,
          'Total Port',
          item.totalPort ?? 'N/A',
        ),
        if (distance != null)
          InfrastructureWidgets.buildDetailItem(
            Icons.location_on,
            'Distance',
            distance < 1000
                ? '${distance.round()} m'
                : '${(distance / 1000).toStringAsFixed(1)} km',
          ),
        if (item.description != null)
          InfrastructureWidgets.buildDetailItem(
            Icons.info,
            'Deskripsi',
            item.description!,
          ),
        if (item.hasValidCoordinates())
          InfrastructureWidgets.buildDetailItem(
            Icons.info,
            'Koordinat',
            '${item.latitude}, ${item.longitude}',
          ),
      ],
    );
  }

  Widget _buildMapSection(InfrastructureItem item) {
    return InfrastructureWidgets.buildDetailSection('Peta', [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(item.lat!, item.lng!),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  InfrastructureWidgets.buildMapMarkers(
                    [item],
                    Provider.of<InfrastructureProvider>(
                      context,
                      listen: false,
                    ).activeType,
                    (_) {},
                  ).first,
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildActionButtons(InfrastructureItem item) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _controller?.launchMaps(item),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.map),
            label: const Text('Buka di Maps'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.close),
            label: const Text('Tutup'),
          ),
        ),
      ],
    );
  }
}
