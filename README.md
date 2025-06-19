# Apatite
Apatite is a combination of Spring Boot backend and Flutter front end to provide a chat application.

This is a backend portion of the project.
You can navigate to the back end  by clicking [here](https://github.com/q-13t/Apatite/tree/Java-Backend).

# 🚨 Caution 🚨
This is a pet project and should not be taken as a serious product and\or tutorial for learning Flutter. Feel free to look at the code but be cautious that it was written by an amateur. And it definitely has bugs.

# 📜NOTE:
1. All password fields in this project are a plain text inputs for the sake of demonstration purposes.
2. Due to limited PC recourses, the client applications were running laggy. This is not an issue on a real device.

# 🌟Features:

## Dynamic server PING
The client will send a ping request before the application starts the communication in order to check if the server is up. Additionally if the server becomes unresponsive/connection is lost the client will go into ping loop that will dispatch ping requests periodically to ensure connectivity.

## Authentication and Authorization
Naturally, client is able to register and login into personal account. Additionally fingerprint authentication is available once single login or registration has taken place.

## Profile settings
Users are able to change their profile pictures, nicknames and passwords. The app provides a simple mechanism to select and update the profile picture.

## Chat
The main idea of the app is to provide a messaging platform for users. The chat can be either private or group. Users are able to dynamically create private chats by clicking a floating action button. Furthermore once the chat is created users can add or remove other participants to/from the chat making it private or public at any time.

## Chat settings
Users are able to change the chat name, chat picture and chat participants.

## Messages
The messages are transmitted using websocket (see [backend](https://github.com/q-13t/Apatite/tree/Java-Backend)) for real time communication. The message is dispatched to the other participants only once it has been added to the database. The app provides a scrollable mechanism with message limitation for ram preservation. Thus if the new message is added whilst user is up or user is not in the app the message will have status sent. Once recipient reads the message the status will be updated to all users correspondingly.

## Media
There are 4 types of media users can send:
1. Image
A plain image file.
2. Video
A video that can be played.
3. Audio
An audio file that can be played.
4. File
An arbitrary file.

All media files can be downloaded into any desired directory on the phone using the download button and a directory selector.

# 🧾Licensing:
This project is licensed under the MIT License. See the LICENSE file for details.

# 🤗Any contributions and/or suggestions are welcomed!