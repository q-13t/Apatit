enum Pages { profile, settings, chat, chats, newChat }

final pagesWrapper = {Pages.profile: 'Profile', Pages.settings: 'Settings', Pages.chat: 'Chat', Pages.chats: 'Messages', Pages.newChat: 'New Chat'};

enum Status { online, offline }

final statusWrapper = {Status.online: 'Online', Status.offline: 'Offline'};

enum MessageType { text, image, video, audio, file }

final messageTypeWrapper = {MessageType.text: 'Text', MessageType.image: 'Image', MessageType.video: 'Video', MessageType.audio: 'Audio', MessageType.file: 'File'};

enum MessageStatus { sent, seen, delivered, read, failed }

final messageStatusWrapper = {MessageStatus.sent: 'Sent', MessageStatus.seen: 'Seen', MessageStatus.delivered: 'Delivered', MessageStatus.read: 'Read', MessageStatus.failed: 'Failed'};

enum WSMType { getMessage, sendMessage, deleteMessage, updateMessage, getChats, sendFile, deleteFile, updateFile, getUsersByName, getPFP }

// ignore: non_constant_identifier_names
final WSMTWrapper = {
  WSMType.getMessage: "getMessage",
  WSMType.sendMessage: "sendMessage",
  WSMType.deleteMessage: "deleteMessage",
  WSMType.updateMessage: "updateMessage",
  WSMType.getChats: "getChats",
  WSMType.sendFile: "sendFile",
  WSMType.deleteFile: "deleteFile",
  WSMType.updateFile: "updateFile",
  WSMType.getUsersByName: "getUsersByName",
  WSMType.getPFP: "getPFP",
};
