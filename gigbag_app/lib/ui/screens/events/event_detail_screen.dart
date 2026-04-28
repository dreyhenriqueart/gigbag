import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/gig_event.dart';
import '../../../state/gigbag_store.dart';
import '../../formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/equipment_list_card.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';
import 'briefing_screen.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _title;
  TextEditingController? _dateDisplay;
  DateTime? _startsAt;
  Set<String>? _selectedEquipmentIds;

  late String _baselineTitle;
  late DateTime _baselineStartsAt;
  late Set<String> _baselineEquipmentIds;

  bool _ready = false;
  bool _saving = false;

  static const double _fieldGap = 10;
  static const double _saveButtonHeight = 56;
  static const double _saveBottomGap = 32;
  static const double _scrollBottomAboveButtons = 16;
  static const double _betweenBriefingAndSave = 16;

  static const Locale _pickerLocale = Locale('pt', 'BR');

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

  void _initFromEvent(GigEvent event) {
    if (_ready) return;
    _startsAt = event.startsAt;
    _selectedEquipmentIds = event.equipmentIds.toSet();
    _title = TextEditingController(text: event.title);
    _dateDisplay = TextEditingController(text: formatDate(event.startsAt));
    _baselineTitle = event.title;
    _baselineStartsAt = event.startsAt;
    _baselineEquipmentIds = event.equipmentIds.toSet();
    _title!.addListener(() => setState(() {}));
    _ready = true;
  }

  bool get _isDirty {
    if (!_ready || _title == null || _startsAt == null || _selectedEquipmentIds == null) {
      return false;
    }
    if (_title!.text.trim() != _baselineTitle.trim()) return true;
    if (_startsAt != _baselineStartsAt) return true;
    if (!const SetEquality<String>().equals(_selectedEquipmentIds!, _baselineEquipmentIds)) return true;
    return false;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      locale: _pickerLocale,
      initialDate: _startsAt!,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt!),
    );
    if (time == null) return;
    setState(() {
      _startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateDisplay!.text = formatDate(_startsAt!);
    });
  }

  Future<void> _save(GigEvent eventFromStore) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _saving = true);

    final store = context.read<GigbagStore>();
    final equipmentIds = _selectedEquipmentIds!.toList()..sort();

    await store.updateEvent(
      id: widget.eventId,
      title: _title!.text,
      startsAt: _startsAt!,
      location: eventFromStore.location,
      equipmentIds: equipmentIds,
    );

    if (!mounted) return;
    setState(() {
      _saving = false;
      _baselineTitle = _title!.text.trim();
      _baselineStartsAt = _startsAt!;
      _baselineEquipmentIds = Set<String>.from(_selectedEquipmentIds!);
    });
  }

  Future<void> _openBriefing() async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BriefingScreen(eventId: widget.eventId),
      ),
    );
    if (!mounted) return;
    if (completed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Briefing concluído.')),
      );
    }
  }

  Widget _primaryBarButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: _saveButtonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.accentTeal,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.accentTeal.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _title?.dispose();
    _dateDisplay?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final event = store.events.firstWhereOrNull((e) => e.id == widget.eventId);

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
                centerTitle: const Text('Bag'),
                trailing: const SizedBox(width: 48, height: 48),
              ),
              const Expanded(child: Center(child: Text('Evento não encontrado.'))),
            ],
          ),
        ),
      );
    }

    _initFromEvent(event);

    final equipmentsSorted = [...store.equipments]..sort((a, b) => a.name.compareTo(b.name));
    final briefingEnabled = _selectedEquipmentIds!.isNotEmpty;

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
                _title!.text.trim().isEmpty ? event.title : _title!.text.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const SizedBox(width: 48, height: 48),
            ),
            const SizedBox(height: AppLayout.screenGap),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenHorizontal,
                  0,
                  AppLayout.screenHorizontal,
                  _scrollBottomAboveButtons,
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
                              fontSize: 20,
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
                        for (var i = 0; i < equipmentsSorted.length; i++) ...[
                          if (i > 0) const SizedBox(height: _fieldGap),
                          EquipmentListCard(
                            equipment: equipmentsSorted[i],
                            onTap: () {
                              final id = equipmentsSorted[i].id;
                              setState(() {
                                if (_selectedEquipmentIds!.contains(id)) {
                                  _selectedEquipmentIds!.remove(id);
                                } else {
                                  _selectedEquipmentIds!.add(id);
                                }
                              });
                            },
                            trailing: GigCardStatusDot(
                              color: _selectedEquipmentIds!.contains(equipmentsSorted[i].id)
                                  ? AppColors.accentTeal
                                  : AppColors.textSecondary,
                            ),
                          ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _primaryBarButton(
                    onPressed: briefingEnabled ? _openBriefing : null,
                    child: const Text(
                      'briefing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_isDirty) ...[
                    const SizedBox(height: _betweenBriefingAndSave),
                    _primaryBarButton(
                      onPressed: (_saving || _title!.text.trim().isEmpty)
                          ? null
                          : () => _save(event),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
