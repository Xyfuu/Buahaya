import '../../domain/models/invite.dart';
import '../../domain/models/shopping.dart';
import '../../domain/repositories/notification_repository.dart';
import 'mock_seed.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<ListInvite> _invites = MockSeed.invites();

  @override
  Future<List<ListInvite>> fetchInvites() async => List.of(_invites);

  @override
  Future<ShoppingList?> respond({required String inviteId, required bool accept}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final invite = _invites.firstWhere((i) => i.id == inviteId);
    _invites.removeWhere((i) => i.id == inviteId);
    if (!accept) return null;
    return ShoppingList(
      id: 'shared-$inviteId',
      name: invite.listName,
      createdAt: DateTime.now(),
      members: [
        ListMember(
            id: 'owner-$inviteId',
            name: invite.inviterName,
            handle: '@${invite.inviterName.toLowerCase()}',
            role: MemberRole.owner),
        const ListMember(id: 'u1', name: 'Roy', handle: '@roykanji'),
      ],
    );
  }
}
