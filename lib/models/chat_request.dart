class ChatRequest {
  String userId;
  String sessionId;
  Message message;
  Context context;
  Metadata metadata;

  ChatRequest({
    required this.userId,
    required this.sessionId,
    required this.message,
    required this.context,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "session_id": sessionId,
        "message": message.toJson(),
        "context": context.toJson(),
        "metadata": metadata.toJson(),
      };
}

class Message {
  String text;
  String timestamp;
  List<Attachment> attachments;

  Message({
    required this.text,
    required this.timestamp,
    required this.attachments,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "timestamp": timestamp,
        "attachments": attachments.map((a) => a.toJson()).toList(),
      };
}

class Attachment {
  String type;
  String url;
  String? filename;

  Attachment({required this.type, required this.url, this.filename});

  Map<String, dynamic> toJson() => {
        "type": type,
        "url": url,
        if (filename != null) "filename": filename,
      };
}

class Context {
  List<String> previousIntents;
  UserPreferences userPreferences;

  Context({required this.previousIntents, required this.userPreferences});

  Map<String, dynamic> toJson() => {
        "previous_intents": previousIntents,
        "user_preferences": userPreferences.toJson(),
      };
}

class UserPreferences {
  String language;
  String timezone;

  UserPreferences({required this.language, required this.timezone});

  Map<String, dynamic> toJson() => {
        "language": language,
        "timezone": timezone,
      };
}

class Metadata {
  String sourcePlatform;
  String clientIp;

  Metadata({required this.sourcePlatform, required this.clientIp});

  Map<String, dynamic> toJson() => {
        "source_platform": sourcePlatform,
        "client_ip": clientIp,
      };
}
