import 'package:flutter/material.dart';

import '../theme/app_layout.dart';

/// Barra superior no mesmo padrão da Home: [AppLayout.screenEdgeInsets] no topo,
/// linha com ícone à esquerda, título central (16 / w400) e elemento à direita (44×44).
class StandardTopBarRow extends StatelessWidget {
  const StandardTopBarRow({
    super.key,
    required this.leading,
    required this.centerTitle,
    required this.trailing,
  });

  final Widget leading;
  /// Tipicamente um [Text] com ellipsis; o estilo padrão é aplicado por [centerTitleStyle].
  final Widget centerTitle;
  final Widget trailing;

  static TextStyle centerTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppLayout.screenEdgeInsets(bottom: 0),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Center(
              child: DefaultTextStyle.merge(
                style: centerTitleStyle(context),
                textAlign: TextAlign.center,
                child: centerTitle,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
