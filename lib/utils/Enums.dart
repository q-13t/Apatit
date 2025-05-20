enum Pages { profile, settings, chat, chats, newChat }

final pagesWrapper = {
  Pages.profile: 'Profile',
  Pages.settings: 'Settings',
  Pages.chat: 'Chat',
  Pages.chats: 'Messages',
  Pages.newChat: 'New Chat',
};

enum Status { online, offline }

final statusWrapper = {Status.online: 'Online', Status.offline: 'Offline'};

enum MessageType { text, image, video, audio, file }

final messageTypeWrapper = {
  MessageType.text: 'Text',
  MessageType.image: 'Image',
  MessageType.video: 'Video',
  MessageType.audio: 'Audio',
  MessageType.file: 'File',
};

enum MessageStatus { sent, seen, delivered, read, failed }

final messageStatusWrapper = {
  MessageStatus.sent: 'Sent',
  MessageStatus.seen: 'Seen',
  MessageStatus.delivered: 'Delivered',
  MessageStatus.read: 'Read',
  MessageStatus.failed: 'Failed',
};

enum WebSocketMessageType {
  getMessage,
  sendMessage,
  deleteMessage,
  updateMessage,
  getChats,
  sendFile,
  deleteFile,
  updateFile,
  getUsersByName,
}

final webSocketMessageTypeWrapper = {
  WebSocketMessageType.getMessage: "getMessage",
  WebSocketMessageType.sendMessage: "sendMessage",
  WebSocketMessageType.deleteMessage: "deleteMessage",
  WebSocketMessageType.updateMessage: "updateMessage",
  WebSocketMessageType.getChats: "getChats",
  WebSocketMessageType.sendFile: "sendFile",
  WebSocketMessageType.deleteFile: "deleteFile",
  WebSocketMessageType.updateFile: "updateFile",
  WebSocketMessageType.getUsersByName: "getUsersByName",
};
