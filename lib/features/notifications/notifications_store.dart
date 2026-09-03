import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../business/business_persistence_web.dart';
import '../kyc/kyc_models.dart';
import '../kyc/kyc_store.dart';
import '../points/points_store.dart';

/// What a notification is about, which is also how it is coloured and where
/// tapping it goes.
enum NotificationKind { moneyIn, moneyOut, points, identity, security }

class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime at;

  /// The tab to open, for the ones that lead somewhere.
  final int? tab;

  /// A named route, for the ones that are their own screen.
  final String? route;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.tab,
    this.route,
  });

  IconData get icon {
    switch (kind) {
      case NotificationKind.moneyIn:
        return Icons.south_west_rounded;
      case NotificationKind.moneyOut:
        return Icons.north_east_rounded;
      case NotificationKind.points:
        return Icons.auto_awesome_rounded;
      case NotificationKind.identity:
        return Icons.verified_user_outlined;
      case NotificationKind.security:
        return Icons.security_rounded;
    }
  }

  Color get tint {
    switch (kind) {
      case NotificationKind.moneyIn:
        return const Color(0xFF00B876);
      case NotificationKind.moneyOut:
        return const Color(0xFF1858F2);
      case NotificationKind.points:
        return const Color(0xFF7CB800);
      case NotificationKind.identity:
        return const Color(0xFF9A6207);
      case NotificationKind.security:
        return const Color(0xFF1858F2);
    }
  }

  /// "2m ago" rather than a timestamp nobody reads.
  String get age {
    final d = DateTime.now().difference(at);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }
}

/// When the notifications sheet was last opened, so the badge counts what has
/// happened since rather than a number somebody typed in.
class NotificationsSeenNotifier extends StateNotifier<DateTime> {
  NotificationsSeenNotifier() : super(_restore());

  static const _key = 'gabis.notifications.seen';

  static DateTime _restore() {
    final raw = readRaw(_key);
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void markAllRead() {
    final now = DateTime.now();
    state = now;
    writeRaw(_key, now.toIso8601String());
  }
}

final notificationsSeenProvider =
    StateNotifierProvider<NotificationsSeenNotifier, DateTime>(
        (ref) => NotificationsSeenNotifier());

/// Everything worth telling the user about, newest first, built from what has
/// actually happened on the account: money that moved, points that landed, and
/// the state of their verification.
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final items = <AppNotification>[];

  for (final tx in ref.watch(transactionsProvider)) {
    if (tx.status == TransactionStatus.failed) {
      items.add(AppNotification(
        id: 'tx-${tx.id}',
        kind: NotificationKind.security,
        title: 'Payment failed',
        body: '${tx.amount.format()} to ${tx.counterparty ?? 'an account'} '
            'did not go through.',
        at: tx.createdAt,
        tab: HomeTab.transactions,
      ));
      continue;
    }

    items.add(AppNotification(
      id: 'tx-${tx.id}',
      kind: tx.isCredit ? NotificationKind.moneyIn : NotificationKind.moneyOut,
      title: tx.isCredit ? 'Money received' : 'Money sent',
      body: tx.isCredit
          ? 'You received ${tx.amount.format()}'
              '${tx.counterparty == null ? '' : ' from ${tx.counterparty}'}.'
          : '${tx.amount.format()} sent'
              '${tx.counterparty == null ? '' : ' to ${tx.counterparty}'}.',
      at: tx.createdAt,
      tab: HomeTab.transactions,
    ));
  }

  for (final entry in ref.watch(pointsProvider).entries) {
    if (entry.kind != PointsKind.earned) continue;
    items.add(AppNotification(
      id: 'points-${entry.at.millisecondsSinceEpoch}-${entry.amount}',
      kind: NotificationKind.points,
      title: '${entry.amount} points earned',
      body: entry.reason,
      at: entry.at,
      route: '/points',
    ));
  }

  // Verification is the one thing the app asks of the user rather than tells
  // them, so it stays at the top until it is done.
  final kyc = ref.watch(kycProvider).profile;
  if (kyc.status != KycStatus.verified) {
    items.add(AppNotification(
      id: 'kyc-${kyc.status.name}',
      kind: NotificationKind.identity,
      title: kyc.status == KycStatus.inProgress
          ? 'Verification in progress'
          : 'Verify your identity',
      body: kyc.status == KycStatus.inProgress
          ? 'We are checking your details. This usually takes a moment.'
          : 'Confirm who you are to open a naira account and raise your limits.',
      at: DateTime.now(),
      route: '/verify',
    ));
  }

  items.sort((a, b) => b.at.compareTo(a.at));
  return items;
});

/// How many of those arrived since the sheet was last opened.
final unreadNotificationsProvider = Provider<int>((ref) {
  final seen = ref.watch(notificationsSeenProvider);
  return ref
      .watch(notificationsProvider)
      .where((n) => n.at.isAfter(seen))
      .length;
});
