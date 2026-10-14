import '../../../core/network/api_client.dart';
import '../domain/models/notification_item.dart';

/// The patient's in-app notification feed (the backend's `/me/notifications`).
/// Failures surface as an `ApiException`.
abstract interface class NotificationsRepository {
  Future<NotificationFeed> getFeed();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class DioNotificationsRepository implements NotificationsRepository {
  DioNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<NotificationFeed> getFeed() async =>
      NotificationFeed.fromJson(await _client.get('/me/notifications'));

  @override
  Future<void> markRead(String id) async {
    await _client.post('/me/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _client.post('/me/notifications/read-all');
  }
}
