import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/checklist_state.dart';
import '../domain/equipment.dart';
import '../domain/gig_event.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  static const _equipmentsKey = 'gigbag.equipments.v1';
  static const _eventsKey = 'gigbag.events.v1';
  static const _checklistsKey = 'gigbag.checklists.v1';

  final SharedPreferences _prefs;

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  Future<List<Equipment>> loadEquipments() async {
    final raw = _prefs.getString(_equipmentsKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => Equipment.fromJson(m.cast<String, Object?>()))
        .toList();
  }

  Future<void> saveEquipments(List<Equipment> equipments) async {
    final encoded = jsonEncode(equipments.map((e) => e.toJson()).toList());
    await _prefs.setString(_equipmentsKey, encoded);
  }

  Future<List<GigEvent>> loadEvents() async {
    final raw = _prefs.getString(_eventsKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => GigEvent.fromJson(m.cast<String, Object?>()))
        .toList();
  }

  Future<void> saveEvents(List<GigEvent> events) async {
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(_eventsKey, encoded);
  }

  Future<Map<String, ChecklistState>> loadChecklists() async {
    final raw = _prefs.getString(_checklistsKey);
    if (raw == null || raw.trim().isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = <String, ChecklistState>{};
    for (final entry in decoded.entries) {
      final map = (entry.value as Map<String, dynamic>).cast<String, Object?>();
      final state = ChecklistState.fromJson(map);

      // Migração: versões antigas salvavam por direção (eventId:outbound / eventId:inbound).
      // Agora o briefing é único por evento (chave = eventId).
      final normalizedKey = ChecklistState.storageKey(eventId: state.eventId);
      final prev = result[normalizedKey];
      if (prev == null) {
        result[normalizedKey] = state;
      } else {
        final mergedChecked = {...prev.checkedEquipmentIds, ...state.checkedEquipmentIds};
        final mergedCompletedAt = _maxDateTime(prev.completedAt, state.completedAt);
        final mergedUpdatedAt = _maxDateTime(prev.updatedAt, state.updatedAt)!;
        result[normalizedKey] = ChecklistState(
          eventId: state.eventId,
          checkedEquipmentIds: mergedChecked,
          completedAt: mergedCompletedAt,
          updatedAt: mergedUpdatedAt,
        );
      }
    }
    return result;
  }

  DateTime? _maxDateTime(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  Future<void> saveChecklists(Map<String, ChecklistState> checklists) async {
    final encoded = jsonEncode(
      checklists.map((k, v) => MapEntry(k, v.toJson())),
    );
    await _prefs.setString(_checklistsKey, encoded);
  }

  Future<void> resetAllData() async {
    await _prefs.remove(_equipmentsKey);
    await _prefs.remove(_eventsKey);
    await _prefs.remove(_checklistsKey);
  }

  ChecklistState defaultChecklist({required String eventId}) {
    final now = DateTime.now();
    return ChecklistState(
      eventId: eventId,
      checkedEquipmentIds: {},
      completedAt: null,
      updatedAt: now,
    );
  }
}

