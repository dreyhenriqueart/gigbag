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
              leading: SizedBox(width: 44, height: 44),
              centerTitle: Text('Ajustes'),
              trailing: SizedBox(width: 44, height: 44),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.secondaryBase,
                            child: Icon(Icons.info_outline, color: AppColors.bg, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sobre',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Gigbag — checklist de equipamentos por evento',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FixedHeightCard(
                    child: InkWell(
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
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.secondaryBase,
                              child:
                                  Icon(Icons.delete_forever_outlined, color: AppColors.bg, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apagar todos os dados',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Remove inventário, eventos e briefings deste navegador.',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

