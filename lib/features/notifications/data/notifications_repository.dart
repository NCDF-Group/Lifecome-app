import '../../../core/network/api_client.dart';
import '../domain/models/notification_item.dart';

/// The patient's in-app notification feed (the backend's `/me/notifications`).
class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<NotificationItem>> list() async {
    final json = await _client.getMap('/me/notifications');
    return [
      for (final item in json['items'] as List<dynamic>)
        NotificationItem.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> markRead(String id) async {
    await _client.post('/me/notifications/$id/read', data: const {});
  }

  Future<void> markAllRead() async {
    await _client.post('/me/notifications/read-all', data: const {});
  }
}
