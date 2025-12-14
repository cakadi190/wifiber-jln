import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/models/infrastructure.dart';
import 'package:wifiber/providers/infrastructure_provider.dart';
import 'package:wifiber/controllers/infrastructure_controller.dart';
import 'package:wifiber/components/widgets/infrastructure_widget.dart';
import 'package:wifiber/components/widgets/location_widgets.dart';
import 'package:wifiber/services/location_service.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/screens/dashboard/customers/customer_detail_modal.dart';

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
            userAgentPackageName: 'id.kodinus.wifiber',
            additionalOptions: {'userAgentPackageName': 'id.kodinus.wifiber'},
          ),
          MarkerLayer(
            markers: [
              if (provider.hasUserLocation)
                LocationWidgets.buildUserLocationMarker(provider.userLocation!),

              if (provider.activeType == InfrastructureType.customer)
                ..._buildCustomerMarkers(provider.customers)
              else
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

  List<Marker> _buildCustomerMarkers(List<Customer> customers) {
    return customers
        .where((customer) => customer.hasValidCoordinates())
        .map(
          (customer) => Marker(
            point: LatLng(customer.lat!, customer.lng!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () =>
                  _showMarkerInfo(customer, InfrastructureType.customer),
              child: Container(
                decoration: BoxDecoration(
                  color: _getCustomerStatusColor(
                    customer.status,
                  ).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        )
        .toList();
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
            'ODC',
            provider.activeType == InfrastructureType.odc,
            () => _controller?.onFilterTap(InfrastructureType.odc),
          ),
          const SizedBox(width: 8),
          InfrastructureWidgets.buildFilterButton(
            'ODP',
            provider.activeType == InfrastructureType.odp,
            () => _controller?.onFilterTap(InfrastructureType.odp),
          ),
          const SizedBox(width: 8),
          InfrastructureWidgets.buildFilterButton(
            'Pelanggan',
            provider.activeType == InfrastructureType.customer,
            () => _controller?.onFilterTap(InfrastructureType.customer),
          ),
        ],
      ),
    );
  }

  Widget _buildNearestItemInfo(InfrastructureProvider provider) {
    if (provider.activeType == InfrastructureType.customer) {
      final nearestCustomer = provider.getNearestCustomer();
      if (nearestCustomer == null) {
        return const SizedBox.shrink();
      }

      final distance =
          provider.userLocation != null && nearestCustomer.hasValidCoordinates()
          ? LocationService.calculateDistance(
              provider.userLocation!,
              LatLng(nearestCustomer.lat!, nearestCustomer.lng!),
            )
          : null;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_pin_circle,
              color: _getCustomerStatusColor(nearestCustomer.status),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pelanggan Terdekat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    nearestCustomer.name,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nearestCustomer.address.isNotEmpty)
                    Text(
                      nearestCustomer.address,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCustomerStatusColor(
                      nearestCustomer.status,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    nearestCustomer.statusDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getCustomerStatusColor(nearestCustomer.status),
                    ),
                  ),
                ),
                if (distance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LocationWidgets.buildDistanceChip(
                      distance < 1000
                          ? '${distance.round()} m'
                          : '${(distance / 1000).toStringAsFixed(1)} km',
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

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

    if (provider.activeType == InfrastructureType.customer) {
      return _buildCustomerList(scrollController, provider);
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

  Widget _buildCustomerList(
    ScrollController scrollController,
    InfrastructureProvider provider,
  ) {
    final customersWithDistance = provider.getCustomersWithDistance();
    final nearestCustomer = provider.getNearestCustomer();

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: customersWithDistance.length,
      itemBuilder: (context, index) {
        final customerWithDistance = customersWithDistance[index];
        final customer = customerWithDistance.customer;
        final isNearest =
            nearestCustomer != null && nearestCustomer.id == customer.id;

        return _buildCustomerListTile(
          customerWithDistance,
          isNearest,
          () => _showMarkerInfo(customer, InfrastructureType.customer),
        );
      },
    );
  }

  Widget _buildCustomerListTile(
    CustomerWithDistance customerWithDistance,
    bool isNearest,
    VoidCallback onTap,
  ) {
    final customer = customerWithDistance.customer;
    final statusColor = _getCustomerStatusColor(customer.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(customer.phone, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                customer.statusDisplay,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
            if (customer.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                customer.address,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isNearest) LocationWidgets.buildNearestItemIndicator(),
            if (customerWithDistance.distance != null)
              LocationWidgets.buildDistanceChip(
                customerWithDistance.formattedDistance,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCustomerStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
      case 'active':
        return Colors.green;
      case 'inactive':
      case 'isolir':
      case 'suspended':
        return Colors.red;
      case 'free':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  void _showMarkerInfo(dynamic item, InfrastructureType type) {
    if (type == InfrastructureType.customer) {
      if (item is Customer) {
        CustomerDetailModal.show(context, item);
      }
      return;
    }

    if (item is! InfrastructureItem) return;
    final infrastructureItem = item;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildInfoSection(infrastructureItem, type),
                    if (infrastructureItem.hasValidCoordinates()) ...[
                      const SizedBox(height: 16),
                      _buildMapSection(infrastructureItem),
                    ],

                    if (type == InfrastructureType.olt &&
                        infrastructureItem.id != null) ...[
                      const SizedBox(height: 16),
                      _buildRelatedOdcSection(infrastructureItem.id!),
                    ],

                    if (type == InfrastructureType.odc &&
                        infrastructureItem.id != null) ...[
                      const SizedBox(height: 16),
                      _buildRelatedOdpSection(infrastructureItem.id!),
                    ],

                    if (type == InfrastructureType.odp &&
                        infrastructureItem.id != null) ...[
                      const SizedBox(height: 16),
                      _buildRelatedCustomersSection(infrastructureItem.id!),
                    ],

                    if (infrastructureItem.hasValidCoordinates()) ...[
                      const SizedBox(height: 16),
                      _buildActionButtons(infrastructureItem),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRelatedOdpSection(String odcId) {
    return FutureBuilder<List<InfrastructureItem>>(
      future: _provider!.loadOdpsByOdcId(odcId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return InfrastructureWidgets.buildDetailSection('ODP Terhubung', [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          return InfrastructureWidgets.buildDetailSection('ODP Terhubung', [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data ODP: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        }

        final odpList = snapshot.data ?? [];

        if (odpList.isEmpty) {
          return InfrastructureWidgets.buildDetailSection('ODP Terhubung', [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Tidak ada ODP yang terhubung dengan ODC ini',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.cable, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'ODP Terhubung (${odpList.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...odpList.map((odp) => _buildOdpListItem(odp)),
          ],
        );
      },
    );
  }

  Widget _buildOdpListItem(InfrastructureItem odp) {
    final provider = Provider.of<InfrastructureProvider>(
      context,
      listen: false,
    );

    final distance = provider.userLocation != null && odp.hasValidCoordinates()
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(odp.lat!, odp.lng!),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(InfrastructureType.odp.icon, color: AppColors.primary),
        title: Text(odp.kodeOdp ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (odp.name != null)
              Text(odp.name!, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (odp.status == 'active' ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                odp.status == 'active' ? "Aktif" : "Tidak Aktif",
                style: TextStyle(
                  fontSize: 12,
                  color: (odp.status == 'active' ? Colors.green : Colors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: distance != null
            ? LocationWidgets.buildDistanceChip(
                distance < 1000
                    ? '${distance.round()} m'
                    : '${(distance / 1000).toStringAsFixed(1)} km',
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          _showMarkerInfo(odp, InfrastructureType.odp);
        },
      ),
    );
  }

  Widget _buildRelatedOdcSection(String oltId) {
    return FutureBuilder<List<InfrastructureItem>>(
      future: _provider!.loadOdcsByOltId(oltId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return InfrastructureWidgets.buildDetailSection('ODC Terhubung', [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          return InfrastructureWidgets.buildDetailSection('ODC Terhubung', [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data ODC: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        }

        final odcList = snapshot.data ?? [];

        if (odcList.isEmpty) {
          return InfrastructureWidgets.buildDetailSection('ODC Terhubung', [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Tidak ada ODC yang terhubung dengan OLT ini',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.hub, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'ODC Terhubung (${odcList.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...odcList.map((odc) => _buildOdcListItem(odc)),
          ],
        );
      },
    );
  }

  Widget _buildOdcListItem(InfrastructureItem odc) {
    final provider = Provider.of<InfrastructureProvider>(
      context,
      listen: false,
    );

    final distance = provider.userLocation != null && odc.hasValidCoordinates()
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(odc.lat!, odc.lng!),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(InfrastructureType.odc.icon, color: AppColors.primary),
        title: Text(odc.kodeOdc ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (odc.name != null)
              Text(odc.name!, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (odc.status == 'active' ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                odc.status == 'active' ? "Aktif" : "Tidak Aktif",
                style: TextStyle(
                  fontSize: 12,
                  color: (odc.status == 'active' ? Colors.green : Colors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: distance != null
            ? LocationWidgets.buildDistanceChip(
                distance < 1000
                    ? '${distance.round()} m'
                    : '${(distance / 1000).toStringAsFixed(1)} km',
              )
            : null,
        onTap: () {
          Navigator.pop(context);

          _showMarkerInfo(odc, InfrastructureType.odc);
        },
      ),
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

  Widget _buildRelatedCustomersSection(String odpId) {
    return FutureBuilder<List<Customer>>(
      future: _provider!.loadCustomersByOdpId(odpId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Pelanggan Terhubung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Pelanggan Terhubung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gagal memuat data pelanggan',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final customerList = snapshot.data ?? [];

        if (customerList.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Pelanggan Terhubung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak ada pelanggan yang terhubung',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.people, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pelanggan Terhubung (${customerList.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...customerList.map((customer) => _buildCustomerListItem(customer)),
          ],
        );
      },
    );
  }

  Widget _buildCustomerListItem(Customer customer) {
    final provider = Provider.of<InfrastructureProvider>(
      context,
      listen: false,
    );

    final distance =
        provider.userLocation != null && customer.hasValidCoordinates()
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(customer.lat!, customer.lng!),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 24),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              customer.customerId,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              customer.packageName,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      customer.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.statusDisplay,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(customer.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone, size: 10, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: distance != null
            ? LocationWidgets.buildDistanceChip(
                distance < 1000
                    ? '${distance.round()} m'
                    : '${(distance / 1000).toStringAsFixed(1)} km',
              )
            : null,
        onTap: () => _showCustomerDetails(customer),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'customer':
      case 'active':
        return Colors.green;
      case 'registrant':
        return Colors.orange;
      case 'inactive':
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCustomerDetails(Customer customer) {
    final provider = Provider.of<InfrastructureProvider>(
      context,
      listen: false,
    );

    final distance =
        provider.userLocation != null && customer.hasValidCoordinates()
        ? LocationService.calculateDistance(
            provider.userLocation!,
            LatLng(customer.lat!, customer.lng!),
          )
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              customer.customerId,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailSection('Informasi Pribadi', [
                    _buildDetailRow(
                      Icons.person,
                      'Nama Lengkap',
                      customer.name,
                    ),
                    if (customer.nickname != null)
                      _buildDetailRow(
                        Icons.person_outline,
                        'Nama Panggilan',
                        customer.nickname!,
                      ),
                    _buildDetailRow(
                      Icons.phone,
                      'Nomor Telepon',
                      customer.phone,
                    ),
                    _buildDetailRow(
                      Icons.credit_card,
                      'NIK',
                      customer.identityNumber,
                    ),
                    _buildDetailRow(Icons.home, 'Alamat', customer.address),
                    _buildDetailRow(
                      Icons.info,
                      'Status',
                      null,
                      customWidget: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            customer.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          customer.statusDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(customer.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _buildDetailSection('Paket & Layanan', [
                    _buildDetailRow(
                      Icons.wifi,
                      'Paket Internet',
                      customer.packageName,
                    ),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Harga Paket',
                      'Rp ${_formatCurrency(customer.packagePrice)}',
                    ),
                    if (customer.discount != '0')
                      _buildDetailRow(
                        Icons.discount,
                        'Diskon',
                        customer.formattedDiscount,
                      ),
                    _buildDetailRow(
                      Icons.payment,
                      'Total Bayar',
                      customer.formattedPrice,
                      highlight: true,
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Jatuh Tempo',
                      'Tanggal ${customer.dueDate}',
                    ),
                    _buildDetailRow(
                      Icons.vpn_key,
                      'PPPoE Secret',
                      customer.pppoeSecret,
                    ),
                    if (customer.routerName != null)
                      _buildDetailRow(
                        Icons.router,
                        'Router',
                        customer.routerName!,
                      ),
                  ]),
                  const SizedBox(height: 16),

                  if (customer.hasValidCoordinates() || distance != null)
                    _buildDetailSection('Lokasi', [
                      if (distance != null)
                        _buildDetailRow(
                          Icons.near_me,
                          'Jarak',
                          distance < 1000
                              ? '${distance.round()} meter'
                              : '${(distance / 1000).toStringAsFixed(2)} km',
                        ),
                      if (customer.hasValidCoordinates())
                        _buildDetailRow(
                          Icons.location_on,
                          'Koordinat',
                          '${customer.latitude}, ${customer.longitude}',
                        ),
                    ]),
                  const SizedBox(height: 24),

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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String? value, {
    Widget? customWidget,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                if (customWidget != null)
                  customWidget
                else
                  Text(
                    value ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: highlight
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: highlight ? AppColors.primary : Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String amount) {
    final value = int.tryParse(amount) ?? 0;
    return CurrencyHelper.formatCurrencyWithoutRp(value);
  }
}
