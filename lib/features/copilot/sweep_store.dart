import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payday sweep: the copilot works out what is genuinely spare and moves it to
/// savings — but only on an explicit approval, and only up to a cap the user
/// sets. Nothing here moves money on its own.

class SweepTransfer {
  final int amountNaira;
  final DateTime at;
  final String note;

  const SweepTransfer({
    required this.amountNaira,
    required this.at,
    required this.note,
  });
}

class SweepState {
  /// Whether the user has armed the rule. Armed still means each sweep is
  /// confirmed — arming only decides whether we offer it on payday.
  final bool armed;

  /// Ceiling per sweep, so a good month cannot move an alarming amount.
  final int capNaira;

  /// Weeks of normal spending held back before anything counts as spare.
  final double reserveWeeks;

  final int savingsNaira;
  final List<SweepTransfer> history;

  const SweepState({
    this.armed = false,
    this.capNaira = 200000,
    this.reserveWeeks = 2,
    this.savingsNaira = 0,
    this.history = const [],
  });

  SweepState copyWith({
    bool? armed,
    int? capNaira,
    double? reserveWeeks,
    int? savingsNaira,
    List<SweepTransfer>? history,
  }) =>
      SweepState(
        armed: armed ?? this.armed,
        capNaira: capNaira ?? this.capNaira,
        reserveWeeks: reserveWeeks ?? this.reserveWeeks,
        savingsNaira: savingsNaira ?? this.savingsNaira,
        history: history ?? this.history,
      );

  /// What would actually move, once the cap is applied.
  int applyCap(int recommended) => recommended.clamp(0, capNaira);
}

class SweepNotifier extends StateNotifier<SweepState> {
  SweepNotifier() : super(const SweepState());

  void setArmed(bool value) => state = state.copyWith(armed: value);

  void setCap(int naira) => state = state.copyWith(capNaira: naira);

  void setReserveWeeks(double weeks) =>
      state = state.copyWith(reserveWeeks: weeks);

  /// Records an approved sweep. Returns the amount actually moved.
  int sweep(int recommendedNaira, {String note = 'Payday sweep'}) {
    final amount = state.applyCap(recommendedNaira);
    if (amount <= 0) return 0;

    state = state.copyWith(
      savingsNaira: state.savingsNaira + amount,
      history: [
        SweepTransfer(amountNaira: amount, at: DateTime.now(), note: note),
        ...state.history,
      ],
    );
    return amount;
  }

  void undoLast() {
    if (state.history.isEmpty) return;
    final last = state.history.first;
    state = state.copyWith(
      savingsNaira: (state.savingsNaira - last.amountNaira).clamp(0, 1 << 62),
      history: state.history.sublist(1),
    );
  }
}

final sweepProvider =
    StateNotifierProvider<SweepNotifier, SweepState>((ref) => SweepNotifier());
