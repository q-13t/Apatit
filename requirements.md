# Requirements

## Backend Java Spring

- [X] the authentication should be done thought the token

## user mapping

- [X] login -> return a token `POST` username, password -> token
- [X] register -> add user to database and return token
  `POST` username, password -> token
- [X] delete user
  `DELETE` token
- [X] change username
  `PATCH` token, username -> username
- [X] change password
  `PATCH` token, password -> password
- [X] get user name -> return users with name starting with string
  `GET` token, name -> users
- [X] update user pfp -> update user pfp
  `PATCH` token, id, pfp -> pfp

## Message mapping

    TODO: make this using websocket and synchronize with HTTP requests
    - [ ] send message`POST` token, message -> message
    - [ ] get messages
        `GET` token -> messages
