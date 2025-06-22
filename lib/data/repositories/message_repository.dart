import '../models/message_model.dart';

abstract class MessageRepository {
  Future<List<MessageModel>> getMessages();
  Future<void> addMessage(String name, String message);
  Stream<List<MessageModel>> messagesStream();
}
