class NotificationPayloadModel {
  String topic = '';
  NotificationContent notification = NotificationContent(title: '', body: '');

  NotificationPayloadModel({required this.topic, required this.notification});

  NotificationPayloadModel.fromJson(Map<String, dynamic> data) {
    topic = data['message']['topic'];
    notification = data['message']['notification'] != null
        ? NotificationContent.fromJson(data['message']['notification'])
        : NotificationContent(title: '', body: '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = {
      'topic': topic,
      'notification': notification.toJson(),
    };
    return data;
  }
}

class NotificationContent {
  String title = '', body = '';

  NotificationContent({required this.title, required this.body});

  NotificationContent.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    body = data['body'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}
