import 'dart:convert';

import '../kyc/kyc_models.dart';
import 'business_store.dart';

/// Where a payment should actually land.
///
/// One shape, three possible sources: the NUBAN a licensed partner issued
/// through verification, the vendor's own bank details, and — when the rail
/// issues them — a virtual account belonging to a single customer. The page
/// that renders this does not care which, which is what lets the third arrive
/// without a redesign.
class PaymentDestination {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const PaymentDestination({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  /// A NUBAN that a partner has actually issued. An account that looks real
  /// but cannot receive money is worse than none, so an unissued one is
  /// refused here rather than printed on a payment page.
  static PaymentDestination? fromNairaAccount(NairaAccount? account) {
    if (account == null || !account.live) return null;
    return PaymentDestination(
      bankName: account.bankName,
      accountNumber: account.accountNumber,
      accountName: account.accountName,
    );
  }

  /// The account the vendor already gives people over WhatsApp.
  static PaymentDestination? fromCompany(ConnectedCompany? company) {
    if (company == null) return null;
    if (company.payoutAccountNumber.trim().isEmpty) return null;
    return PaymentDestination(
      bankName: company.payoutBank,
      accountNumber: company.payoutAccountNumber,
      accountName: company.payoutAccountName.trim().isEmpty
          ? company.name
          : company.payoutAccountName,
    );
  }

  Map<String, dynamic> toJson() => {
        'bank': bankName,
        'acct': accountNumber,
        'name': accountName,
      };
}

/// Builds the link that goes into a WhatsApp message.
///
/// Everything the page needs travels in the URL fragment rather than a query
/// string, so the invoice details are never sent to the server or written into
/// its logs — the browser keeps what is after the # to itself. The page is
/// static, which is why this works today with no ledger behind it.
class PaymentLink {
  static const base = 'https://gabis.pages.dev/pay';

  static String? forInvoice(Invoice invoice, PaymentDestination? destination) {
    if (destination == null) return null;

    final payload = {
      'v': 1,
      'id': invoice.id,
      'to': invoice.client,
      'amt': invoice.amount,
      'cur': invoice.currency,
      'for': invoice.isMilestone
          ? '${invoice.description} (part ${invoice.milestone} of ${invoice.milestones})'
          : invoice.description,
      'due': invoice.due.toIso8601String().split('T').first,
      'dest': destination.toJson(),
    };

    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '$base#$encoded';
  }
}

/// The link a client opens to see everything they owe one business.
///
/// The same trick as [PaymentLink]: the whole statement rides in the fragment,
/// so a client sees their invoices without gabis issuing them a login, holding
/// a password, or writing their balance into a server log. It also means the
/// page is static and the link keeps working with no session to expire — the
/// cost being that a link shared onward shows what it shows, which is why it
/// carries no phone number, email or address.
class PortalLink {
  static const base = 'https://gabis.pages.dev/portal';

  /// Null when there is nothing to show, rather than a link to an empty page.
  static String? forClient(
    String client,
    List<Invoice> invoices,
    PaymentDestination? destination,
  ) {
    // Drafts are stages of work that have not been billed yet — a client
    // seeing one would be asked for money nobody has asked them for. They
    // appear here only once the business releases them.
    final mine = invoices
        .where((i) => i.client == client && i.status != 'draft')
        .toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    if (mine.isEmpty) return null;

    final payload = {
      'v': 1,
      'to': client,
      'cur': mine.first.currency,
      'inv': [
        for (final i in mine)
          {
            'id': i.id,
            'amt': i.amount,
            'cur': i.currency,
            'for': i.description,
            'due': i.due.toIso8601String().split('T').first,
            'st': i.status,
            if (i.milestone != null) 'm': i.milestone,
            if (i.milestones != null) 'mn': i.milestones,
          }
      ],
      if (destination != null) 'dest': destination.toJson(),
    };

    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '$base#$encoded';
  }
}
