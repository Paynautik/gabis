import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../../features/business/business_persistence_web.dart';
import '../../features/business/business_store.dart';
import '../../features/points/points_store.dart';
import '../../shared/providers/app_providers.dart';
import '../firebase/auth_service.dart';

/// Everything gabis keeps in local storage, in one place.
///
/// These are per-browser, not per-account, so they must be cleared when the
/// person using the browser changes. A shop owner signing out on a shared
/// laptop should not leave their debtors' names and phone numbers behind for
/// whoever signs in next.
class LocalData {
  static const businessLedger = 'gabis.business.v1';
  static const points = 'gabis.points.v1';
  static const pendingPoints = 'gabis.points.pending';
  static const demoData = 'gabis.demoData';
  static const profileName = 'gabis.profile.name';
  static const profileAvatar = 'gabis.profile.avatar';

  /// Who the local copy belongs to, so a different account can be detected.
  static const owner = 'gabis.owner';

  /// Cleared on sign-out. The demo flag is deliberately included: it is a
  /// preference of the account, and it comes back from Firestore on sign-in.
  static const clearedOnSignOut = [
    businessLedger,
    points,
    pendingPoints,
    demoData,
    profileName,
    profileAvatar,
    owner,
  ];

  static void wipe() {
    for (final key in clearedOnSignOut) {
      removeRaw(key);
    }
  }

  /// Points caught on the landing page before signing in are the one thing
  /// worth carrying across, since nobody was signed in to own them.
  static void wipeKeepingPendingPoints() {
    final pending = readRaw(pendingPoints);
    wipe();
    if (pending != null && pending != '0') writeRaw(pendingPoints, pending);
  }
}

/// Signing in and out, with the local copy kept honest on both sides.
class SessionService {
  final Ref _ref;

  SessionService(this._ref);

  /// Called after a successful sign-in. If the browser's local data belongs to
  /// somebody else, it is wiped before anything reads it — otherwise the new
  /// user briefly sees the previous user's ledger.
  void adoptUser(String uid) {
    final previous = readRaw(LocalData.owner);
    if (previous != null && previous != uid) {
      LocalData.wipeKeepingPendingPoints();
    }
    writeRaw(LocalData.owner, uid);
    _invalidateUserState();
  }

  Future<void> signOut() async {
    LocalData.wipe();
    await _ref.read(authServiceProvider).signOut();
    _ref.read(authStateProvider.notifier).state = false;
    _ref.read(isBusinessModeProvider.notifier).state = false;
    _ref.read(homeTabProvider.notifier).state = 0;
    _invalidateUserState();
  }

  /// Rebuilds every store that holds user data, so nothing survives in memory
  /// after the storage behind it has gone.
  void _invalidateUserState() {
    _ref.invalidate(pointsProvider);
    _ref.invalidate(businessProvider);
    _ref.invalidate(demoDataProvider);
    _ref.invalidate(accountsProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(cardsProvider);
    _ref.invalidate(profileNameProvider);
    _ref.invalidate(userAvatarProvider);
  }
}

final sessionProvider = Provider<SessionService>((ref) => SessionService(ref));
