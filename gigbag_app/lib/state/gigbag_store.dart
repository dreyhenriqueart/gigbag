import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/local_storage.dart';
import '../domain/checklist_state.dart';
import '../domain/equipment.dart';
import '../domain/gig_event.dart';

class GigbagStore extends ChangeNotifier {
  GigbagStore(this._storage);

  final LocalStorage _storage;
  final _uuid = const Uuid();

  bool _initialized = false;
  bool get initialized => _initialized;

  List<Equipment> _equipments = [];
  List<Equipment> get equipments => List.unmodifiable(_equipments);

  List<GigEvent> _events = [];
  List<GigEvent> get events => List.unmodifiable(_events);

  Map<String, ChecklistState> _checklists = {};

  ChecklistState checklistFor({required String eventId}) {
    final key = ChecklistState.storageKey(eventId: eventId);
    return _checklists[key] ?? _storage.defaultChecklist(eventId: eventId);
  }

  Future<void> init() async {
    _equipments = await _storage.loadEquipments();
    _events = await _storage.loadEvents();
    _checklists = await _storage.loadChecklists();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveEquipments(_equipments);
    await _storage.saveEvents(_events);
    await _storage.saveChecklists(_checklists);
  }

  // --- Equipamentos

  Future<void> addEquipment({
    required String name,
    String? category,
    String? notes,
  }) async {
    final now = DateTime.now();
    final equipment = Equipment(
      id: _uuid.v4(),
      name: name.trim(),
      category: (category ?? '').trim().isEmpty ? null : category!.trim(),
      notes: (notes ?? '').trim().isEmpty ? null : notes!.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _equipments = [..._equipments, equipment]..sort((a, b) => a.name.compareTo(b.name));
    await _persist();
    notifyListeners();
  }

  Future<void> updateEquipment({
    required String id,
    required String name,
    String? category,
    String? notes,
  }) async {
    final idx = _equipments.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final now = DateTime.now();
    final updated = _equipments[idx].copyWith(
      name: name.trim(),
      category: (category ?? '').trim().isEmpty ? null : category!.trim(),
      notes: (notes ?? '').trim().isEmpty ? null : notes!.trim(),
      updatedAt: now,
    );
    final next = [..._equipments];
    next[idx] = updated;
    _equipments = next..sort((a, b) => a.name.compareTo(b.name));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteEquipment(String id) async {
    _equipments = _equipments.where((e) => e.id != id).toList();
    // Remover de eventos
    _events = _events
        .map((ev) => ev.copyWith(
              equipmentIds: ev.equipmentIds.where((eid) => eid != id).toList(),
              updatedAt: DateTime.now(),
            ))
        .toList();
    // Remover de checklists
    _checklists = _checklists.map((k, v) {
      final checked = v.checkedEquipmentIds.where((eid) => eid != id).toSet();
      return MapEntry(k, v.copyWith(checkedEquipmentIds: checked, updatedAt: DateTime.now()));
    });
    await _persist();
    notifyListeners();
  }

  // --- Eventos

  Future<void> addEvent({
    required String title,
    required DateTime startsAt,
    String? location,
    required List<String> equipmentIds,
  }) async {
    if (title.trim().isEmpty) return;
    final now = DateTime.now();
    final event = GigEvent(
      id: _uuid.v4(),
      title: title.trim(),
      startsAt: startsAt,
      location: (location ?? '').trim().isEmpty ? null : location!.trim(),
      equipmentIds: [...equipmentIds],
      createdAt: now,
      updatedAt: now,
    );
    _events = [..._events, event]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    await _persist();
    notifyListeners();
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required DateTime startsAt,
    String? location,
    required List<String> equipmentIds,
  }) async {
    if (title.trim().isEmpty) return;
    final idx = _events.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final now = DateTime.now();
    final updated = _events[idx].copyWith(
      title: title.trim(),
      startsAt: startsAt,
      location: (location ?? '').trim().isEmpty ? null : location!.trim(),
      equipmentIds: [...equipmentIds],
      updatedAt: now,
    );
    final next = [..._events];
    next[idx] = updated;
    _events = next..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events = _events.where((e) => e.id != id).toList();
    _checklists.removeWhere((k, v) => v.eventId == id);
    await _persist();
    notifyListeners();
  }

  // --- Briefing / Checklist

  Future<void> toggleChecklistItem({
    required String eventId,
    required String equipmentId,
    required bool checked,
  }) async {
    final key = ChecklistState.storageKey(eventId: eventId);
    final prev = checklistFor(eventId: eventId);
    final nextSet = {...prev.checkedEquipmentIds};
    if (checked) {
      nextSet.add(equipmentId);
    } else {
      nextSet.remove(equipmentId);
    }
    _checklists[key] = prev.copyWith(
      checkedEquipmentIds: nextSet,
      updatedAt: DateTime.now(),
      // se desmarcou algo, consideramos briefing "não concluído"
      completedAt: null,
    );
    await _persist();
    notifyListeners();
  }

  /// Marca o briefing como concluído para o fluxo de UI e repõe o checklist
  /// para um novo briefing na próxima abertura (todos os itens desmarcados).
  Future<void> completeChecklist({required String eventId}) async {
    await resetChecklist(eventId: eventId);
  }

  Future<void> resetChecklist({required String eventId}) async {
    final key = ChecklistState.storageKey(eventId: eventId);
    _checklists[key] = _storage.defaultChecklist(eventId: eventId);
    await _persist();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _storage.resetAllData();
    _equipments = [];
    _events = [];
    _checklists = {};
    notifyListeners();
  }
}

