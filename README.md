# Apatite
Apatite is a combination of Spring Boot backend and Flutter front end to provide a chat application.

This is a backend portion of the project.
You can navigate to the front end  by clicking [here](https://github.com/q-13t/Apatite/tree/Apk).

# 🚨 Caution 🚨
This is a pet project and should not be taken as a serious product and\or tutorial for learning Java Spring. Feel free to look at the code but be cautious that it was written by an amateur. And it definitely has bugs.

# 🏃‍♀️ How to run locally:

Clone the repository using `git clone -b Java-Backend https://github.com/q-13t/Apatite.git`
Then launch the backend portion using one of 2 options:

1. Using Docker compose (preferred)
    Simply run `docker compose up` from the root of the repository. This will build the docker images and start the containers.
2. Using Maven
    Run `mvn spring-boot:run` from the root of the repository. This will `NOT` build the database. The database is located in the `db` directory, you can use the init script to create a Postgresql database locally. You will need to change the `application.properties` file to and change the following properties:
        - server.port=3030
        - websocket.port=3031

The server exposes 2 ports for communication:
-   3030 for REST API
-   3031 for Websocket

# 🌟Features:
Majority of features are on [the front end](https://github.com/q-13t/Apatite/tree/Apk).

## JWT authentication

The project uses JWT authentication for user authentication. The secret key can be found in the `jwt.secret` property in the `application.properties` file.
You can change the secret key or expiration time by editing the file.

## Database

The project uses Postgresql database for development and testing. The database creation script is located in the `db` directory.

## Websocket

The project uses Websocket for real-time communication between users.

## MVC

The project uses the Model-View-Controller (MVC) architecture for the backend.

## REST API

The project is build around REST APIs. The API is located in the `src/main/java/edu/chat/controllers` directory.

## Ping

The server exposes a `/ping` endpoint to check if the server is running. So that clients can automatically reconnect if they are disconnected.

# 🧾Licensing:
This project is licensed under the MIT License. See the LICENSE file for details.

# 🤗Any contributions and/or suggestions are welcomed!