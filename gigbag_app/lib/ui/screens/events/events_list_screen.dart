import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/gig_event.dart';
import '../../../state/gigbag_store.dart';
import '../../formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';
import '../../widgets/empty_state.dart';
import 'event_detail_screen.dart';
import 'event_editor_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  Future<void> _openEditor(BuildContext context, {GigEvent? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventEditorScreen(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final events = store.events;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardTopBarRow(
              leading: const SizedBox(width: 48, height: 48),
              centerTitle: const Text('Eventos'),
              trailing: PillIconButton(
                icon: Icons.add,
                onPressed: () => _openEditor(context),
              ),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: events.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenHorizontal,
                        0,
                        AppLayout.screenHorizontal,
                        24,
                      ),
                      child: EmptyState(
                        title: 'Nenhum evento criado',
                        subtitle:
                            'Crie um evento e selecione quais equipamentos você vai levar.',
                        icon: Icons.event_outlined,
                        actionLabel: 'Criar evento',
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
                      itemCount: events.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) => _EventTile(
                        event: events[i],
                        equipmentCount: events[i].equipmentIds.length,
                        onOpen: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(eventId: events[i].id),
                            ),
                          );
                        },
                        onEdit: () => _openEditor(context, existing: events[i]),
                        onDelete: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Excluir evento?',
                            message: 'Os briefings deste evento também serão apagados.',
                            confirmLabel: 'Excluir',
                            destructive: true,
                          );
                          if (!ok) return;
                          if (!ctx.mounted) return;
                          await ctx.read<GigbagStore>().deleteEvent(events[i].id);
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

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.equipmentCount,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final GigEvent event;
  final int equipmentCount;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      formatDateTime(event.startsAt),
      if ((event.location ?? '').trim().isNotEmpty) event.location!.trim(),
      '$equipmentCount item(ns)',
    ].join(' • ');

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onOpen,
        title: Text(event.title),
        subtitle: Text(subtitle),
        leading: const Icon(Icons.event),
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

