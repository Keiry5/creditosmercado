const String appName = 'CréditosPro';
const String appVersion = '1.0.0';

class AppConstants {
  // Colores principales de la app
  static const int primaryColor = 0xFF1565C0;     // Azul
  static const int accentColor = 0xFF4CAF50;      // Verde
  static const int warningColor = 0xFFFF9800;     // Naranja
  static const int dangerColor = 0xFFE53935;      // Rojo

  // Tasas de interés por defecto
  static const double defaultInterestRate = 20.0; // 20% anual

  // Duración por defecto de préstamos (días)
  static const int defaultLoanDays = 30;

  // Formatos
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyFormat = '\$#,##0.00';
}

// Mensajes comunes
class AppMessages {
  static const String loanSaved = 'Préstamo registrado exitosamente';
  static const String paymentSaved = 'Pago registrado correctamente';
  static const String errorOccurred = 'Ocurrió un error';
  static const String noData = 'No hay datos disponibles';
  static const String confirmDelete = '¿Estás seguro de eliminar este registro?';
}

// Rutas de navegación
class AppRoutes {
  static const String home = '/';
  static const String loans = '/loans';
  static const String newLoan = '/new-loan';
  static const String reports = '/reports';
  static const String routes = '/routes';
}