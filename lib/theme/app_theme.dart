import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Paleta principal baseada no escudo do Sabadão FC
      colorScheme: const ColorScheme.dark(
        // Fundo principal (quase preto, moderno)
        surface: Color(0xFF0B0E14), // Superfícies secundárias (cards, dialogs)
        surfaceBright: Color(0xFF161B22),
        
        // Azul Royal do Escudo (Destaques, botões principais)
        primary: Color(0xFF0052CC), 
        onPrimary: Colors.white,
        
        // Azul Claro/Ciano do olho da coruja (Acentos, detalhes ativos)
        secondary: Color(0xFF008CFF), 
        onSecondary: Colors.black,
        
        // Branco do Escudo (Textos principais e ícones)
        onSurface: Color(0xFFF8F9FA),
        
        // Cinza Escuro para Bordas e Divisores
        outline: Color(0xFF21262D),
        
        // Cor de Erro padrão para modo escuro
        error: Color(0xFFCF6679),
        onError: Colors.black,
      ),

      // Customizações extras do Material 3
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF8F9FA)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8F9FA),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: const CardThemeData(
        color: Color(0xFF161B22),
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0052CC), // Azul Royal
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}