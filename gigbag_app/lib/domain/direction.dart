enum BriefingDirection { outbound, inbound }

extension BriefingDirectionLabel on BriefingDirection {
  String get label {
    switch (this) {
      case BriefingDirection.outbound:
        return 'Ida';
      case BriefingDirection.inbound:
        return 'Volta';
    }
  }
}

