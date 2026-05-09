import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/equipment.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';

class BriefingScreen extends StatelessWidget {
  const BriefingScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final event = store.events.firstWhereOrNull((e) => e.id == eventId);
    if (event == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardTopBarRow(
                leading: PillIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: const Text('Briefing'),
                trailing: const SizedBox(width: 44, height: 44),
              ),
              const Expanded(child: Center(child: Text('Evento não encontrado.'))),
            ],
          ),
        ),
      );
    }

    final equipmentsById = {for (final e in store.equipments) e.id: e};
    final equipments = event.equipmentIds
        .map((id) => equipmentsById[id])
        .whereType<Equipment>()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final checklist = store.checklistFor(eventId: eventId);
    final total = equipments.length;
    final missing =
        equipments.where((e) => !checklist.checkedEquipmentIds.contains(e.id)).toList();

    final headerTitle = Text(
      'Briefing ${event.title}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    Future<void> onConclude() async {
      if (total == 0) return;
      if (missing.isNotEmpty) {
        final missingNames = missing.map((e) => '• ${e.name}').join('\n');
        final ok = await showConfirmDialog(
          context,
          title: 'Concluir briefing?',
          message:
              'Ainda faltam ${missing.length} item(ns):\n\n$missingNames\n\nDeseja concluir o briefing mesmo assim?',
          confirmLabel: 'Concluir',
        );
        if (!context.mounted) return;
        if (!ok) return;
      }
      await context.read<GigbagStore>().completeChecklist(eventId: eventId);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: total == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StandardTopBarRow(
                    leading: PillIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    centerTitle: headerTitle,
                    trailing: const SizedBox(width: 44, height: 44),
                  ),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
                        child: Text('Esta bag não tem equipamentos selecionados.'),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StandardTopBarRow(
                    leading: PillIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    centerTitle: headerTitle,
                    trailing: PillIconButton(
                      icon: Icons.done_rounded,
                      onPressed: onConclude,
                    ),
                  ),
                  const SizedBox(height: AppLayout.screenGap),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenHorizontal,
                        0,
                        AppLayout.screenHorizontal,
                        0,
                      ),
                      itemCount: equipments.length,
                      itemBuilder: (ctx, i) {
                        final e = equipments[i];
                        final value = checklist.checkedEquipmentIds.contains(e.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => ctx.read<GigbagStore>().toggleChecklistItem(
                                  eventId: eventId,
                                  equipmentId: e.id,
                                  checked: !value,
                                ),
                            borderRadius: BorderRadius.circular(22),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 64, maxHeight: 64),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBase.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: value ? AppColors.accentTeal : AppColors.stroke,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if ((e.category ?? '').trim().isNotEmpty) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        e.category!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 10),
                                    GigCardStatusDot(
                                      color: value ? AppColors.accentTeal : AppColors.secondaryBase,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (missing.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenHorizontal,
                        8,
                        AppLayout.screenHorizontal,
                        16,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Itens faltantes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
