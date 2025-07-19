import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/bills_service.dart';

class BillsController {
  final BillsService _billsService = BillsService();

  Future<List<Bills>> fetchBills() async {
    final response = await _billsService.getBills();

    if (response.success) {
      return response.data;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Bills?> createBill(CreateBill createBill) async {
    final response = await _billsService.createBill(createBill);

    if (response.success) {
      if (response.data.isNotEmpty) {
        return response.data.first;
      }
      return null;
    } else {
      throw Exception(response.message);
    }
  }
}