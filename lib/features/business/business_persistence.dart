import 'dart:convert';

import 'business_store.dart';
import 'business_persistence_stub.dart'
    if (dart.library.js_interop) 'business_persistence_web.dart';

/// The dashboard survives a reload: every mutation writes the whole ledger to
/// local storage, and the store rehydrates from it on startup. It is per
/// browser, not a server — but the data is genuinely the user's own, not a
/// fixture that resets under them.
class BusinessPersistence {
  static const _key = 'gabis.business.v1';

  static String? read() => readRaw(_key);

  /// Whether the operator has asked for the example book.
  static bool get demoEnabled => readRaw('gabis.demoData') == 'on';

  static void write(BusinessState state) => writeRaw(_key, jsonEncode(encode(state)));

  static void clear() => removeRaw(_key);

  // ── encode ────────────────────────────────────────────────────────────
  static Map<String, dynamic> encode(BusinessState s) => {
        'companies': s.companies.map(_company).toList(),
        'invoices': s.invoices.map(_invoice).toList(),
        'calls': s.calls.map(_call).toList(),
        'filings': s.filings.map(_filing).toList(),
        'sampleAttempts': s.sampleAttempts,
      };

  static Map<String, dynamic> _company(ConnectedCompany c) => {
        'name': c.name,
        'domain': c.domain,
        'paymentType': c.paymentType,
        'contactName': c.contactName,
        'contactPhone': c.contactPhone,
        'contactEmail': c.contactEmail,
        'termsDays': c.termsDays,
        'payers': c.payers.map(_payer).toList(),
      };

  static Map<String, dynamic> _payer(Payer p) => {
        'name': p.name,
        'email': p.email,
        'phone': p.phone,
        'totalAmount': p.totalAmount,
        'amountPaid': p.amountPaid,
        'installments': p.installments,
        'currentInstallment': p.currentInstallment,
        'nextDueDate': p.nextDueDate.toIso8601String(),
        'status': p.status,
        'doNotContact': p.doNotContact,
        'consentBasis': p.consentBasis,
        'payments': p.payments
            .map((r) => {
                  'timestamp': r.timestamp.toIso8601String(),
                  'amount': r.amount,
                  'note': r.note,
                })
            .toList(),
      };

  static Map<String, dynamic> _invoice(Invoice i) => {
        'id': i.id,
        'client': i.client,
        'amount': i.amount,
        'currency': i.currency,
        'description': i.description,
        'issued': i.issued.toIso8601String(),
        'due': i.due.toIso8601String(),
        'status': i.status,
        'companyDomain': i.companyDomain,
      };

  static Map<String, dynamic> _call(CallLog c) => {
        'payerName': c.payerName,
        'company': c.company,
        'amount': c.amount,
        'placedAt': c.placedAt.toIso8601String(),
        'tone': c.tone,
        'outcome': c.outcome,
        'transcript': c.transcript,
        'language': c.language,
        'channel': c.channel,
        'daysOverdue': c.daysOverdue,
        'attemptNumber': c.attemptNumber,
        'promisedDate': c.promisedDate?.toIso8601String(),
        'promiseKept': c.promiseKept,
        'amountRecovered': c.amountRecovered,
      };

  static Map<String, dynamic> _filing(TaxFiling f) => {
        'currency': f.currency,
        'jurisdiction': f.jurisdiction,
        'revenue': f.revenue,
        'rate': f.rate,
        'filedAt': f.filedAt.toIso8601String(),
        'period': f.period,
      };

  // ── decode ────────────────────────────────────────────────────────────
  static BusinessState? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;

      final companies = (map['companies'] as List).map((c) {
        final m = c as Map<String, dynamic>;
        return ConnectedCompany(
          name: m['name'] as String,
          domain: m['domain'] as String,
          paymentType: m['paymentType'] as String,
          contactName: (m['contactName'] as String?) ?? '',
          contactPhone: (m['contactPhone'] as String?) ?? '',
          contactEmail: (m['contactEmail'] as String?) ?? '',
          termsDays: (m['termsDays'] as int?) ?? 30,
          payers: (m['payers'] as List).map((p) {
            final pm = p as Map<String, dynamic>;
            return Payer(
              name: pm['name'] as String,
              email: pm['email'] as String,
              phone: pm['phone'] as String,
              totalAmount: (pm['totalAmount'] as num).toDouble(),
              amountPaid: (pm['amountPaid'] as num).toDouble(),
              installments: pm['installments'] as int,
              currentInstallment: pm['currentInstallment'] as int,
              nextDueDate: DateTime.parse(pm['nextDueDate'] as String),
              status: pm['status'] as String,
              doNotContact: (pm['doNotContact'] as bool?) ?? false,
              // Books written before consent was recorded keep working; the
              // contact rules ask for a basis before the next reminder.
              consentBasis: pm['consentBasis'] as String?,
              payments: (pm['payments'] as List)
                  .map((r) => PaymentRecord(
                        timestamp: DateTime.parse(r['timestamp'] as String),
                        amount: (r['amount'] as num).toDouble(),
                        note: r['note'] as String,
                      ))
                  .toList(),
            );
          }).toList(),
        );
      }).toList();

      final invoices = (map['invoices'] as List).map((i) {
        final m = i as Map<String, dynamic>;
        return Invoice(
          id: m['id'] as String,
          client: m['client'] as String,
          amount: (m['amount'] as num).toDouble(),
          currency: m['currency'] as String,
          description: m['description'] as String,
          issued: DateTime.parse(m['issued'] as String),
          due: DateTime.parse(m['due'] as String),
          status: m['status'] as String,
          companyDomain: m['companyDomain'] as String?,
        );
      }).toList();

      final calls = (map['calls'] as List).map((c) {
        final m = c as Map<String, dynamic>;
        return CallLog(
          payerName: m['payerName'] as String,
          company: m['company'] as String,
          amount: (m['amount'] as num).toDouble(),
          placedAt: DateTime.parse(m['placedAt'] as String),
          tone: m['tone'] as String,
          outcome: m['outcome'] as String,
          transcript: (m['transcript'] as List).cast<String>(),
          language: (m['language'] as String?) ?? 'English',
          channel: (m['channel'] as String?) ?? 'voice',
          daysOverdue: (m['daysOverdue'] as int?) ?? 0,
          attemptNumber: (m['attemptNumber'] as int?) ?? 1,
          promisedDate: m['promisedDate'] == null
              ? null
              : DateTime.parse(m['promisedDate'] as String),
          promiseKept: m['promiseKept'] as bool?,
          amountRecovered: ((m['amountRecovered'] as num?) ?? 0).toDouble(),
        );
      }).toList();

      final filings = (map['filings'] as List).map((f) {
        final m = f as Map<String, dynamic>;
        return TaxFiling(
          currency: m['currency'] as String,
          jurisdiction: m['jurisdiction'] as String,
          revenue: (m['revenue'] as num).toDouble(),
          rate: (m['rate'] as num).toDouble(),
          filedAt: DateTime.parse(m['filedAt'] as String),
          period: m['period'] as String,
        );
      }).toList();

      return BusinessState(
        companies: companies,
        invoices: invoices,
        calls: calls,
        filings: filings,
        sampleAttempts: (map['sampleAttempts'] as bool?) ?? false,
      );
    } catch (_) {
      // A shape we cannot read is worse than none: fall back to the seed.
      return null;
    }
  }
}
