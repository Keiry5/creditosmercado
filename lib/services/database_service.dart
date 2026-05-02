import 'package:hive_flutter/hive_flutter.dart';
import '../models/loan.dart';
import '../models/visit.dart';

class DatabaseService {
  static const String loanBox = 'loans';
  static const String visitBox = 'visits';

  static Future<void> init() async {
    await Hive.openBox<Loan>(loanBox);
    await Hive.openBox<Visit>(visitBox);
  }

  static Box<Loan> getLoansBox() => Hive.box<Loan>(loanBox);
  static Box<Visit> getVisitsBox() => Hive.box<Visit>(visitBox);
}