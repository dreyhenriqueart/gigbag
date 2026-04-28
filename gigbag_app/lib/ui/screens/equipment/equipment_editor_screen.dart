import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/equipment.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';

class EquipmentEditorScreen extends StatefulWidget {
  const EquipmentEditorScreen({super.key, this.existing});

  final Equipment? existing;

  @override
  State<EquipmentEditorScreen> createState() => _EquipmentEditorScreenState();
}

class _EquipmentEditorScreenState extends State<EquipmentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _notes;

  bool _saving = false;

  /// Igual ao espaçamento entre cards na lista de Equipamento (`ListView.separated`).
  static const double _fieldGap = 10;

  static const double _saveButtonHeight = 56;

  /// Espaço entre o botão Salvar e o canto inferior (acima do inset seguro).
  static const double _saveBottomGap = 32;

  /// Espaço entre o fim do conteúdo rolável e o topo do botão Salvar (evita corte do texto).
  static const double _scrollBottomAboveSave = 16;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _category = TextEditingController(text: widget.existing?.category ?? '');
    _notes = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Caixas Nome / Categoria: texto 14, Primary Text (`bodyMedium` no tema).
  TextStyle _boxedFieldTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  /// Notas: texto 14, sempre Secondary Text (digitado e hint).
  TextStyle _notesFieldTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary);
  }

  /// Mesmo esquema das caixas da Bags (`InputDecoration` + tema), hints em 14.
  InputDecoration _bagsSearchDecoration(BuildContext context, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintStyle: Theme.of(context).textTheme.bodySmall,
    );
  }

  /// Notas: sem contorno; hint Secondary Text 14.
  InputDecoration _notesFloatingDecoration(BuildContext context) {
    return InputDecoration(
      hintText: 'Faça anotações sobre esse equipamento',
      hintStyle: _notesFieldTextStyle(context),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isDense: true,
    );
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _saving = true);
    final store = context.read<GigbagStore>();
    final name = _name.text;
    final category = _category.text;
    final notes = _notes.text;

    if (widget.existing == null) {
      await store.addEquipment(name: name, category: category, notes: notes);
    } else {
      await store.updateEquipment(
        id: widget.existing!.id,
        name: name,
        category: category,
        notes: notes,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final appBarTitle = isEdit ? 'Editar equipamento' : 'Novo equipamento';
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
              trailing: const SizedBox(width: 48, height: 48),
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
                        controller: _name,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: _boxedFieldTextStyle(context),
                        decoration: _bagsSearchDecoration(context, hint: 'Nome'),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe um nome.';
                          if (v.trim().length < 2) return 'Nome muito curto.';
                          return null;
                        },
                      ),
                      const SizedBox(height: _fieldGap),
                      TextFormField(
                        controller: _category,
                        style: _boxedFieldTextStyle(context),
                        decoration: _bagsSearchDecoration(context, hint: 'Categoria'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppLayout.screenGap),
                      Text(
                        'Notas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notes,
                        style: _notesFieldTextStyle(context),
                        cursorColor: AppColors.accentTeal,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: null,
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                        decoration: _notesFloatingDecoration(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.screenHorizontal,
                0,
                AppLayout.screenHorizontal,
                _saveBottomGap,
              ),
              child: SizedBox(
                width: double.infinity,
                height: _saveButtonHeight,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
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
                            fontSize: 20,
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
