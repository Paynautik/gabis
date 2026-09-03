import 'business_store.dart';

/// Whether this debtor may be contacted right now, and if not, why not.
class ContactDecision {
  final bool allowed;

  /// Written for the person about to press the button, not for a log file.
  final String? reason;

  const ContactDecision.allow() : allowed = true, reason = null;
  const ContactDecision.deny(this.reason) : allowed = false;
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

    final mine = priorCalls.where((c) => c.payerName == payer.name);

    final today = mine
        .where((c) =>
            c.placedAt.year == at.year &&
            c.placedAt.month == at.month &&
            c.placedAt.day == at.day)
        .length;
    if (today >= maxPerDay) {
      return const ContactDecision.deny(
          'Already contacted today. One approach a day keeps this a reminder rather than a chase.');
    }

    final week = mine
        .where((c) => at.difference(c.placedAt).inDays < 7)
        .length;
    if (week >= maxPerWeek) {
      return const ContactDecision.deny(
          'Three approaches already this week. The next one can go out '
          'once seven days have passed since the first.');
    }

    return const ContactDecision.allow();
  }

  /// The line that has to travel with every automated reminder: who is asking,
  /// and how to make it stop.
  static String optOutLine(String company) =>
      'Sent by $company through gabis. Reply STOP to opt out of reminders.';
}
