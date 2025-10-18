import 'package:flutter/material.dart';

class AppColors {
  // Colores inspirados en cultura maya
  static const Color primaryColor = Color(0xFF8B4513); // Marrón tierra
  static const Color secondaryColor = Color(0xFFDAA520); // Dorado
  static const Color accentColor = Color(0xFF228B22); // Verde selva
  static const Color backgroundColor = Color(0xFFF5F5DC); // Beige claro
  static const Color errorColor = Color(0xFFD32F2F); // Rojo error
  static const Color successColor = Color(0xFF388E3C); // Verde éxito
  static const Color warningColor = Color(0xFFF57C00); // Naranja advertencia
  static const Color infoColor = Color(0xFF1976D2); // Azul información

  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF212121); // Gris oscuro
  static const Color textSecondaryColor = Color(0xFF757575); // Gris medio
  static const Color textLightColor = Color(0xFFFFFFFF); // Blanco

  // Colores de fondo
  static const Color cardColor = Color(0xFFFFFFFF); // Blanco
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5DC); // Beige claro

  // Colores de estado
  static const Color approvedColor = Color(0xFF4CAF50); // Verde aprobado
  static const Color failedColor = Color(0xFFF44336); // Rojo reprobado
  static const Color pendingColor = Color(0xFFFF9800); // Naranja pendiente
  static const Color completedColor = Color(0xFF2196F3); // Azul completado

  // Colores de nivel
  static const Color basicLevelColor = Color(0xFF4CAF50); // Verde
  static const Color intermediateLevelColor = Color(0xFFFFC107); // Amarillo
  static const Color advancedLevelColor = Color(0xFFF44336); // Rojo

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF654321)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
