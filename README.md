# Apatite
Apatite is a combination of Spring Boot backend and Flutter front end to provide a chat application.

This is a backend portion of the project.
You can navigate to the back end  by clicking [here](https://github.com/q-13t/Apatite-Server).

# 🚨 Caution 🚨
This is a pet project and should not be taken as a serious product and\or tutorial for learning Flutter. Feel free to look at the code but be cautious that it was written by an amateur. And it definitely has bugs.

# 📜NOTE:
1. All password fields in this project are a plain text inputs for the sake of demonstration purposes.
2. Due to limited PC recourses, the client applications were running laggy. This is not an issue on a real device.

# 🌟Features:

## Dynamic server PING
The client will send a ping request before the application starts the communication in order to check if the server is up. Additionally if the server becomes unresponsive/connection is lost the client will go into ping loop that will dispatch ping requests periodically to ensure connectivity.


https://github.com/user-attachments/assets/52012ac3-5c67-4c88-a17c-7cfc54364ae8


## Authentication and Authorization
Naturally, client is able to register and login into personal account. Additionally fingerprint authentication is available once single login or registration has taken place.


https://github.com/user-attachments/assets/4db262f9-89c1-4cca-885f-0c9bffa9cb04


## Profile settings
Users are able to change their profile pictures, nicknames and passwords. The app provides a simple mechanism to select and update the profile picture.


https://github.com/user-attachments/assets/73cf548a-af1e-4824-b740-c036230ae241


## Chat
The main idea of the app is to provide a messaging platform for users. The chat can be either private or group. Users are able to dynamically create private chats by clicking a floating action button. Furthermore once the chat is created users can add or remove other participants to/from the chat making it private or public at any time.


https://github.com/user-attachments/assets/14f7d129-6217-4ebc-a656-6cbde364a810


## Chat settings
Users are able to change the chat name, chat picture and chat participants.


https://github.com/user-attachments/assets/759b5d31-f4b3-4b74-866b-fc4e5d50bfe3


## Messages
The messages are transmitted using websocket (see [backend](https://github.com/q-13t/Apatite-Server)) for real time communication. The message is dispatched to the other participants only once it has been added to the database. The app provides a scrollable mechanism with message limitation for ram preservation. Thus if the new message is added whilst user is up or user is not in the app the message will have status sent. Once recipient reads the message the status will be updated to all users correspondingly.


https://github.com/user-attachments/assets/4a5ea853-f570-4547-ac4b-08a71e7a49e3


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


https://github.com/user-attachments/assets/335767fa-ec64-48c6-bde5-0bfff2386b47


# 🧾Licensing:
This project is licensed under the MIT License. See the LICENSE file for details.

# 🤗Any contributions and/or suggestions are welcomed!
