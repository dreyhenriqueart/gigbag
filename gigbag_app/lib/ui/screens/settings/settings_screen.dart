import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/fixed_height_card.dart';
import '../../widgets/standard_top_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StandardTopBarRow(
              leading: SizedBox(width: 48, height: 48),
              centerTitle: Text('Ajustes'),
              trailing: SizedBox(width: 48, height: 48),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenHorizontal,
                  0,
                  AppLayout.screenHorizontal,
                  12,
                ),
                children: [
                  FixedHeightCard(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                      title: const Text(
                        'Sobre',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Gigbag — checklist de equipamentos por evento',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FixedHeightCard(
                    child: ListTile(
                      leading:
                          const Icon(Icons.delete_forever_outlined, color: AppColors.textSecondary),
                      title: const Text(
                        'Apagar todos os dados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Remove inventário, eventos e briefings deste navegador.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () async {
                        final ok = await showConfirmDialog(
                          context,
                          title: 'Apagar todos os dados?',
                          message:
                              'Esta ação é irreversível. Todos os equipamentos, eventos e briefings serão removidos deste navegador.',
                          confirmLabel: 'Apagar',
                          destructive: true,
                        );
                        if (!ok) return;
                        if (!context.mounted) return;
                        await context.read<GigbagStore>().resetAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dados apagados.')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

