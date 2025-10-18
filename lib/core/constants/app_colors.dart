import 'package:flutter/material.dart';

class AppColors {
  // Paleta Maya Moderna - Colores primarios inspirados en la cultura maya
  static const Color primaryColor = Color(0xFF1B5E20); // Verde jade maya profundo
  static const Color primaryLight = Color(0xFF4CAF50); // Verde jade claro
  static const Color primaryDark = Color(0xFF0D3818); // Verde jade oscuro
  
  static const Color secondaryColor = Color(0xFFFF8F00); // Oro maya vibrante
  static const Color secondaryLight = Color(0xFFFFC947); // Oro claro
  static const Color secondaryDark = Color(0xFFE65100); // Oro quemado
  
  static const Color accentColor = Color(0xFF8D6E63); // Terracota maya
  static const Color accentLight = Color(0xFFBCAAA4); // Terracota clara
  
  // Colores de superficie modernos
  static const Color scaffoldBackgroundColor = Color(0xFFFAFAFA); // Blanco cálido
  static const Color surfaceColor = Color(0xFFFFFFFF); // Superficie principal
  static const Color cardColor = Color(0xFFFFFFFF); // Tarjetas
  static const Color dividerColor = Color(0xFFE1E1E1); // Divisores sutiles
  static const Color borderColor = Color(0xFFD7CCC8); // Bordes suaves
  
  // Sistema de texto mejorado
  static const Color textPrimaryColor = Color(0xFF1C1B1F); // Texto principal
  static const Color textSecondaryColor = Color(0xFF6F6F6F); // Texto secundario
  static const Color textTertiaryColor = Color(0xFF9E9E9E); // Texto terciario
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Texto sobre primario
  static const Color textOnSecondary = Color(0xFF1C1B1F); // Texto sobre secundario
  
  // Colores semánticos mejorados
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color infoColor = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);
  
  // Sistema de niveles con mejor accesibilidad
  static const Color basicLevelColor = Color(0xFF2E7D32); // Verde éxito
  static const Color basicLevelLight = Color(0xFFE8F5E8);
  static const Color intermediateLevelColor = Color(0xFFF57C00); // Naranja advertencia
  static const Color intermediateLevelLight = Color(0xFFFFF3E0);
  static const Color advancedLevelColor = Color(0xFFD32F2F); // Rojo desafío
  static const Color advancedLevelLight = Color(0xFFFFEBEE);
  
  // Alias para compatibilidad
  static const Color nivelBasicoColor = basicLevelColor;
  static const Color nivelIntermedioColor = intermediateLevelColor;
  static const Color nivelAvanzadoColor = advancedLevelColor;
  
  // Gradientes mejorados
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Gradiente maya especial para elementos destacados
  static const LinearGradient mayaGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Sombras y elevaciones
  static const Color shadowColor = Color(0x1F000000);
  static const Color shadowLightColor = Color(0x0A000000);
}
