import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  double amount;
  
  @HiveField(2)
  String category;
  
  @HiveField(3)
  String? subcategory;
  
  @HiveField(4)
  String description;
  
  @HiveField(5)
  DateTime dateTime;
  
  @HiveField(6)
  String? receiptPath;
  
  @HiveField(7)
  String? location;
  
  @HiveField(8)
  Map<String, dynamic>? metadata;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.description,
    required this.dateTime,
    this.receiptPath,
    this.location,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'receiptPath': receiptPath,
      'location': location,
      'metadata': metadata,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      subcategory: map['subcategory'],
      description: map['description'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] ?? 0),
      receiptPath: map['receiptPath'],
      location: map['location'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? subcategory,
    String? description,
    DateTime? dateTime,
    String? receiptPath,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      receiptPath: receiptPath ?? this.receiptPath,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }
}