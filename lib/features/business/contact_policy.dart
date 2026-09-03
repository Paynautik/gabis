import 'business_store.dart';

/// Whether this debtor may be contacted right now, and if not, why not.
class ContactDecision {
  final bool allowed;

  /// Written for the person about to press the button, not for a log file.
  final String? reason;

  /// Which approach this would be: 1 for the first, 2 for the second. The
  /// message is written from this, so the count and the wording cannot drift
  /// apart.
  final int attempt;

  const ContactDecision.allow({this.attempt = 1})
      : allowed = true,
        reason = null;
  const ContactDecision.deny(this.reason, {this.attempt = 1}) : allowed = false;
}

/// The rules that decide whether a chase may go out.
///
/// These are enforced here rather than left to whoever is holding the phone,
/// because that is the difference between a policy and a hope. Nigeria's NDPR,
/// Kenya's Data Protection Act 2019 and Ghana's Act 843 all turn on the same
/// three things: a lawful basis for holding the contact details, a limit on
/// how often you may use them, and an honoured refusal.
class ContactPolicy {
  /// Nobody is chased about money before breakfast or after dinner.
  static const dayStartHour = 8;
  static const dayEndHour = 20;

  /// One approach a day, and three in any rolling week. Past that it stops
  /// being a reminder and starts being harassment.
  static const maxPerDay = 1;
  static const maxPerWeek = 3;

  static ContactDecision check({
    required Payer payer,
    required List<CallLog> priorCalls,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();

    if (payer.doNotContact) {
      return const ContactDecision.deny(
          'This person asked not to be contacted. Send an invoice instead, or reach them through their own bank.');
    }

    if ((payer.consentBasis ?? '').trim().isEmpty) {
      return const ContactDecision.deny(
          'No lawful basis recorded for contacting this person. Add one on their record first.');
    }

    if (at.hour < dayStartHour || at.hour >= dayEndHour) {
      return ContactDecision.deny(
          'Outside contact hours. Reminders go out between '
          '${dayStartHour.toString().padLeft(2, '0')}:00 and '
          '${dayEndHour.toString().padLeft(2, '0')}:00.');
    }

    final mine = priorCalls.where((c) => c.payerName == payer.name).toList()
      ..sort((a, b) => a.placedAt.compareTo(b.placedAt));
    final attempt = mine.length + 1;

    // Someone who has said no is not a lead to be worked. A refusal ends the
    // automated reminders; what follows is a conversation between two people,
    // or a matter for the courts, and neither belongs on this button.
    if (mine.isNotEmpty && mine.last.outcome == 'refused') {
      return ContactDecision.deny(
          '${payer.name.split(' ').first} refused the last approach. '
          'Automated reminders stop there — speak to them directly, or agree '
          'a new date on their record first.',
          attempt: attempt);
    }

    final today = mine
        .where((c) =>
            c.placedAt.year == at.year &&
            c.placedAt.month == at.month &&
            c.placedAt.day == at.day)
        .length;
    if (today >= maxPerDay) {
      return ContactDecision.deny(
          'Already contacted today. One approach a day keeps this a reminder rather than a chase.',
          attempt: attempt);
    }

    final week = mine
        .where((c) => at.difference(c.placedAt).inDays < 7)
        .length;
    if (week >= maxPerWeek) {
      return ContactDecision.deny(
          'Three approaches already this week. The next one can go out '
          'once seven days have passed since the first.',
          attempt: attempt);
    }

    return ContactDecision.allow(attempt: attempt);
  }

  /// The line that has to travel with every automated reminder: who is asking,
  /// and how to make it stop.
  static String optOutLine(String company) =>
      'Sent by $company through gabis. Reply STOP to opt out of reminders.';
}
