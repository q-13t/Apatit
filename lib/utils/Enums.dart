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
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.file: 'file',
};

enum MessageStatus { sent, seen, delivered, failed }

final messageStatusWrapper = {
  MessageStatus.sent: 'sent',
  MessageStatus.seen: 'seen',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
};

enum WSMType {
  error,
  getMessages,
  sendMessage,
  deleteMessage,
  updateMessage,
  getChats,
  sendFile,
  deleteFile,
  updateFile,
  getUsersByName,
  getPFP,
  newChatPrivate,
  bind,
  deleteChat,
  newMessage,
  loadMessages,
}

// ignore: non_constant_identifier_names
final WSMTWrapper = {
  WSMType.getMessages: "getMessages",
  WSMType.sendMessage: "sendMessage",
  WSMType.deleteMessage: "deleteMessage",
  WSMType.updateMessage: "updateMessage",
  WSMType.getChats: "getChats",
  WSMType.sendFile: "sendFile",
  WSMType.deleteFile: "deleteFile",
  WSMType.updateFile: "updateFile",
  WSMType.getUsersByName: "getUsersByName",
  WSMType.getPFP: "getPFP",
  WSMType.newChatPrivate: "newChatPrivate",
  WSMType.bind: "bind",
  WSMType.deleteChat: "deleteChat",
  WSMType.newMessage: "newMessage",
  WSMType.loadMessages: "loadMessages",
};
