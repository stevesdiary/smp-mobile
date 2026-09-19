import '../models/notification_model.dart';
import '../services/api_client.dart';

class NotificationsRepository {
  final ApiClient _client;
  NotificationsRepository(this._client);

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _client.get('/notifications') as List<dynamic>;
    return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAllRead() async {
    await _client.post('/notifications/mark-all-read', {});
  }

  Future<void> markRead(List<String> ids) async {
    await _client.post('/notifications/mark-read', {'ids': ids});
  }
}

final notificationsRepository = NotificationsRepository(apiClient);
