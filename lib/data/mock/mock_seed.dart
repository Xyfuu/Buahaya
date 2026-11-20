import '../../core/constants/app_assets.dart';
import '../../domain/models/fruit.dart';
import '../../domain/models/invite.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/shopping.dart';
import '../../domain/models/store.dart';

/// Data awal untuk repository mock (sesuai desain Figma).
abstract final class MockSeed {
  static const apple = Fruit(id: 'apple', name: 'Apple', emoji: '🍎', imageUrl: AppAssets.fruitApple);
  static const orange = Fruit(id: 'orange', name: 'Orange', emoji: '🍊', imageUrl: AppAssets.fruitOrange);
  static const banana = Fruit(id: 'banana', name: 'Banana', emoji: '🍌', imageUrl: AppAssets.fruitBanana);
  static const mango = Fruit(id: 'mango', name: 'Mango', emoji: '🥭', imageUrl: AppAssets.fruitMango);
  static const tomato = Fruit(id: 'tomato', name: 'Tomato', emoji: '🍅', imageUrl: AppAssets.fruitTomato);
  static const watermelon = Fruit(id: 'watermelon', name: 'Watermelon', emoji: '🍉', imageUrl: AppAssets.fruitWatermelon);
  static const grape = Fruit(id: 'grape', name: 'Grape', emoji: '🍇', imageUrl: AppAssets.fruitGrape);
  static const strawberry = Fruit(id: 'strawberry', name: 'Strawberry', emoji: '🍓', imageUrl: AppAssets.fruitStrawberry);
  static const pineapple = Fruit(id: 'pineapple', name: 'Pineapple', emoji: '🍍', imageUrl: AppAssets.fruitPineapple);

  static const catalog = [
    apple, orange, banana, mango, tomato,
  ];

  static const profile = UserProfile(
    id: 'u1',
    fullName: 'Roy Kanji',
    username: 'roykanji',
    email: 'ryukiyoshi@gmail.com',
    avatarUrl: AppAssets.profile,
    shoppingListCount: 12,
    freshCheckCount: 48,
    partnerCount: 2,
  );

  static ShoppingList activeList() => ShoppingList(
        id: 'list-1',
        name: 'Weekly fresh fruit',
        store: 'Grand Lucky Supermarket',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        items: const [
          ShoppingItem(fruit: apple, planned: 5, inCart: 3),
          ShoppingItem(fruit: orange, planned: 8),
          ShoppingItem(fruit: banana, planned: 6),
        ],
        members: const [
          ListMember(id: 'u1', name: 'Roy', handle: '@roykanji', role: MemberRole.owner),
          ListMember(id: 'u2', name: 'Budi Santoso', handle: '@budis'),
          ListMember(
              id: 'u3', name: 'Rani Wijaya', handle: '@raniw', status: MemberStatus.pending),
        ],
      );

  static List<ShoppingTrip> history() => [
        ShoppingTrip(
          id: 't1',
          name: 'Pasar Segar Abadi trip',
          finishedAt: DateTime(2025, 7, 12, 10, 57),
          duration: const Duration(minutes: 42),
          store: 'Pasar Segar Abadi',
          fruits: const [
            TripFruit(fruit: apple, count: 5),
            TripFruit(fruit: banana, count: 6),
            TripFruit(fruit: orange, count: 4),
          ],
        ),
        ShoppingTrip(
          id: 't2',
          name: 'Abadi Nan Jaya trip',
          finishedAt: DateTime(2025, 6, 15, 17, 30),
          duration: const Duration(minutes: 54),
          store: 'Abadi Nan Jaya',
          partners: const ['@Budi', '@Rani'],
          fruits: const [
            TripFruit(fruit: apple, count: 8),
            TripFruit(fruit: banana, count: 6),
            TripFruit(fruit: orange, count: 6),
          ],
        ),
      ];

  static List<ListInvite> invites() => [
        ListInvite(
          id: 'inv-1',
          inviterName: 'Nadia',
          listName: 'Monthly Shoppinggg',
          receivedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ];

  static const userLat = -6.2437;
  static const userLng = 106.7992;

  static const stores = [
    FruitStore(
        id: 's1', name: 'Pasar Segar Abadi', distanceKm: 0.8,
        opensAtMinutes: 360, closesAtMinutes: 1080,
        lat: -6.2386, lng: 106.7958, area: 'Kebayoran Baru',
        address: 'Jl. Melawai Raya No. 12, Kebayoran Baru',
        imageUrl: AppAssets.storePasarAbadi),
    FruitStore(
        id: 's2', name: 'Kebun Buah Harmoni', distanceKm: 1.2,
        opensAtMinutes: 420, closesAtMinutes: 1260,
        lat: -6.2520, lng: 106.8050, area: 'Kebayoran Baru',
        address: 'Jl. Wolter Monginsidi No. 45, Kebayoran Baru',
        imageUrl: AppAssets.storeHarmoni),
    FruitStore(
        id: 's3', name: 'Rumah Duta Total Buah', distanceKm: 1.4,
        opensAtMinutes: 480, closesAtMinutes: 1080,
        lat: -6.2330, lng: 106.8100, area: 'Kebayoran Baru',
        address: 'Jl. Suryo No. 8, Senopati',
        imageUrl: AppAssets.storeRumahDuta),
    FruitStore(
        id: 's4', name: 'Abadi Nan Jaya', distanceKm: 2.0,
        opensAtMinutes: 360, closesAtMinutes: 1200,
        lat: -6.2600, lng: 106.7900, area: 'Kebayoran Baru',
        address: 'Jl. Cipaku I No. 21, Kebayoran Baru',
        imageUrl: AppAssets.storeAbadiNanJaya),
    FruitStore(
        id: 's5', name: 'Toko Buah Lestari Jaya', distanceKm: 2.8,
        opensAtMinutes: 420, closesAtMinutes: 1200,
        lat: -6.2250, lng: 106.7820, area: 'Kebayoran Baru',
        address: 'Jl. Gandaria Tengah No. 3',
        imageUrl: AppAssets.storeLestari),
  ];
}
