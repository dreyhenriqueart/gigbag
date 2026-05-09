import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/equipment.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';
import '../../widgets/equipment_list_card.dart';
import '../equipment/equipment_editor_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Equipment? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EquipmentEditorScreen(existing: existing)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final items = store.equipments;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardTopBarRow(
              leading: PillIconButton(
                icon: Icons.close_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: const Text('Equipamento'),
              trailing: const SizedBox(width: 44, height: 44),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenHorizontal,
                  0,
                  AppLayout.screenHorizontal,
                  100,
                ),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => EquipmentListCard(
                  equipment: items[i],
                  onTap: () => _openEditor(context, existing: items[i]),
                  onLongPress: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Excluir equipamento?',
                      message: 'Este item será removido do inventário e dos eventos.',
                      confirmLabel: 'Excluir',
                      destructive: true,
                    );
                    if (!ok) return;
                    if (!ctx.mounted) return;
                    await ctx.read<GigbagStore>().deleteEquipment(items[i].id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
