import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/equipment.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';
import '../../widgets/empty_state.dart';
import 'equipment_editor_screen.dart';

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Equipment? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EquipmentEditorScreen(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final items = store.equipments;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardTopBarRow(
              leading: const SizedBox(width: 48, height: 48),
              centerTitle: const Text('Equipamentos'),
              trailing: PillIconButton(
                icon: Icons.add,
                onPressed: () => _openEditor(context),
              ),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenHorizontal,
                        0,
                        AppLayout.screenHorizontal,
                        24,
                      ),
                      child: EmptyState(
                        title: 'Nenhum equipamento cadastrado',
                        subtitle:
                            'Cadastre seu inventário para depois selecionar o que levar em cada evento.',
                        icon: Icons.cases_outlined,
                        actionLabel: 'Adicionar equipamento',
                        onAction: () => _openEditor(context),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenHorizontal,
                        0,
                        AppLayout.screenHorizontal,
                        12,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) => _EquipmentTile(
                        equipment: items[i],
                        onEdit: () => _openEditor(context, existing: items[i]),
                        onDelete: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Excluir equipamento?',
                            message:
                                'Este equipamento também será removido dos eventos e briefings.',
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

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.equipment,
    required this.onEdit,
    required this.onDelete,
  });

  final Equipment equipment;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if ((equipment.category ?? '').trim().isNotEmpty) equipment.category!.trim(),
      if ((equipment.notes ?? '').trim().isNotEmpty) equipment.notes!.trim(),
    ].join(' • ');

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        title: Text(equipment.name),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        leading: const Icon(Icons.cases),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Excluir',
              onPressed: () => onDelete(),
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

