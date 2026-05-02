import 'package:creditosmercado/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/loan_list_screen.dart';
import '../screens/new_loan_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/routes_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen(userType: UserType.admin,)),
      GoRoute(path: '/loans', builder: (context, state) => const LoanListScreen()),
      GoRoute(path: '/new-loan', builder: (context, state) => const NewLoanScreen()),
      GoRoute(
        path: '/payment/:loanId',
        builder: (context, state) => PaymentScreen(loanId: state.pathParameters['loanId']!),
      ),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
      GoRoute(path: '/routes', builder: (context, state) => const RoutesScreen()),
    ],
  );
});