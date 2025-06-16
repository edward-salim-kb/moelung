import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String remainingLabel;
  final String? imageUrl; // Added imageUrl

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.remainingLabel,
    this.imageUrl, // Added imageUrl
  });

  String get startDateLabel => DateFormat('dd MMM yyyy').format(startDate);
  String get endDateLabel => DateFormat('dd MMM yyyy').format(endDate);
}
