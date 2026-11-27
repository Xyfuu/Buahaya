import 'package:flutter/foundation.dart';

import '../domain/models/invite.dart';
import '../domain/models/shopping.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this._repo);

  final NotificationRepository _repo;

  List<ListInvite> invites = const [];

  bool get hasUnread => invites.isNotEmpty;
  ListInvite? get latest => invites.isEmpty ? null : invites.first;

  Future<void> load() async {
    try {
      invites = await _repo.fetchInvites();
    } catch (_) {}
    notifyListeners();
  }

  void reset() {
    invites = const [];
    notifyListeners();
  }

  Future<ShoppingList?> respond(ListInvite invite, {required bool accept}) async {
    ShoppingList? joined;
    try {
      joined = await _repo.respond(inviteId: invite.id, accept: accept);
    } catch (_) {}
    invites = invites.where((i) => i.id != invite.id).toList();
    notifyListeners();
    return joined;
  }
}
