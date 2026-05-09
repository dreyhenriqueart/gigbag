import 'package:flutter/material.dart';

/// Padrão global de espaçamento (solicitado):
/// 48pt entre: barra superior → header → próximo bloco, etc.
class AppLayout {
  static const double screenGap = 48;

  /// Letreiros de secção (ex.: "Gig Bags >", "Este mês") até o primeiro card da lista.
  static const double contentLabelToCardGap = 16;

  /// Tela Bags: espaço entre rótulo do mês e cards, e entre bloco de cards e o mês seguinte.
  static const double bagsMonthCardsGap = 24;

  // Mantém a mesma “coluna” visual das referências
  static const double screenHorizontal = 16;

  /// Botões primários à largura total: **Salvar**, **Briefing** (e equivalentes).
  static const double primaryCtaButtonHeight = 56;

  static EdgeInsets screenEdgeInsets({double bottom = 0}) {
    return EdgeInsets.fromLTRB(screenHorizontal, screenGap, screenHorizontal, bottom);
  }
}
