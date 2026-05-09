import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/gig_event.dart';
import '../../../state/gigbag_store.dart';
import '../../../domain/equipment.dart';
import '../../formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/equipment_list_card.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';

class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({super.key, this.existing});

  final GigEvent? existing;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _dateDisplay;

  late DateTime _startsAt;
  late Set<String> _selectedEquipmentIds;

  bool _saving = false;

  static const double _fieldGap = 10;
  static const double _saveBottomGap = 32;
  static const double _scrollBottomAboveSave = 16;

  List<String> _sortedCategoryKeys(Iterable<Equipment> equipments) {
    final keys = <String>{};
    for (final e in equipments) {
      final k = (e.category ?? '').trim();
      if (k.isNotEmpty) keys.add(k);
    }
    final list = keys.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<({String label, List<Equipment> items})> _groupByCategory(List<Equipment> equipmentsSortedByName) {
    final byCat = <String, List<Equipment>>{};
    final uncategorized = <Equipment>[];

    for (final e in equipmentsSortedByName) {
      final cat = (e.category ?? '').trim();
      if (cat.isEmpty) {
        uncategorized.add(e);
      } else {
        (byCat[cat] ??= []).add(e);
      }
    }

    final sections = <({String label, List<Equipment> items})>[];
    for (final cat in _sortedCategoryKeys(equipmentsSortedByName)) {
      final items = byCat[cat];
      if (items == null || items.isEmpty) continue;
      sections.add((label: cat, items: items));
    }
    if (uncategorized.isNotEmpty) {
      sections.add((label: 'Sem categoria', items: uncategorized));
    }
    return sections;
  }

  TextStyle _boxedFieldTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  InputDecoration _bagsSearchDecoration(BuildContext context, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintStyle: Theme.of(context).textTheme.bodySmall,
    );
  }

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _startsAt = widget.existing?.startsAt ?? DateTime.now().add(const Duration(hours: 1));
    _dateDisplay = TextEditingController(text: formatDate(_startsAt));
    _selectedEquipmentIds = widget.existing?.equipmentIds.toSet() ?? {};
    _title.addListener(_syncTitleButton);
  }

  void _syncTitleButton() {
    setState(() {});
  }

  @override
  void dispose() {
    _title.removeListener(_syncTitleButton);
    _title.dispose();
    _dateDisplay.dispose();
    super.dispose();
  }

  static const Locale _pickerLocale = Locale('pt', 'BR');

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      locale: _pickerLocale,
      initialDate: _startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (time == null) return;
    setState(() {
      _startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateDisplay.text = formatDate(_startsAt);
    });
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _saving = true);

    final store = context.read<GigbagStore>();
    final title = _title.text;
    final equipmentIds = _selectedEquipmentIds.toList()..sort();

    if (widget.existing == null) {
      await store.addEvent(
        title: title,
        startsAt: _startsAt,
        location: null,
        equipmentIds: equipmentIds,
      );
    } else {
      await store.updateEvent(
        id: widget.existing!.id,
        title: title,
        startsAt: _startsAt,
        location: widget.existing!.location,
        equipmentIds: equipmentIds,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final allEquipments = store.equipments;
    final equipmentsSorted = [...allEquipments]..sort((a, b) => a.name.compareTo(b.name));
    final equipmentSections = _groupByCategory(equipmentsSorted);
    final isEdit = widget.existing != null;
    final appBarTitle = isEdit
        ? (_title.text.trim().isEmpty ? widget.existing!.title : _title.text.trim())
        : 'Nova bag';

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
              centerTitle: Text(
                appBarTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const SizedBox(width: 44, height: 44),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenHorizontal,
                  0,
                  AppLayout.screenHorizontal,
                  _scrollBottomAboveSave,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _title,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: _boxedFieldTextStyle(context),
                        decoration: _bagsSearchDecoration(context, hint: 'Nome'),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'O nome da bag é obrigatório.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _fieldGap),
                      TextField(
                        controller: _dateDisplay,
                        readOnly: true,
                        showCursor: false,
                        style: _boxedFieldTextStyle(context).copyWith(color: AppColors.textSecondary),
                        decoration: _bagsSearchDecoration(context, hint: 'Data'),
                        onTap: _pickDateTime,
                      ),
                      const SizedBox(height: AppLayout.screenGap),
                      Text(
                        'Equipamento',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppLayout.bagsMonthCardsGap),
                      if (equipmentsSorted.isEmpty)
                        Text(
                          'Você ainda não tem equipamentos cadastrados. Vá em Equipamentos e adicione ao menos um item.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        )
                      else
                        for (var si = 0; si < equipmentSections.length; si++) ...[
                          if (si > 0) const SizedBox(height: 16),
                          Text(
                            equipmentSections[si].label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < equipmentSections[si].items.length; i++) ...[
                            if (i > 0) const SizedBox(height: _fieldGap),
                            EquipmentListCard(
                              equipment: equipmentSections[si].items[i],
                              onTap: () {
                                final id = equipmentSections[si].items[i].id;
                                setState(() {
                                  if (_selectedEquipmentIds.contains(id)) {
                                    _selectedEquipmentIds.remove(id);
                                  } else {
                                    _selectedEquipmentIds.add(id);
                                  }
                                });
                              },
                              trailing: GigCardStatusDot(
                                color: _selectedEquipmentIds.contains(equipmentSections[si].items[i].id)
                                    ? AppColors.accentTeal
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenHorizontal,
                0,
                AppLayout.screenHorizontal,
                _saveBottomGap,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppLayout.primaryCtaButtonHeight,
                child: FilledButton(
                  onPressed: (_saving || _title.text.trim().isEmpty) ? null : _save,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.accentTeal.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Text(
                          'salvar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
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
