# Requirements

## Backend Java Spring

- [ ] the authentication should be done thought the token

## user mapping

- [ ] login -> return a token`POST` username, password -> token
- [ ] register -> add user to database and return token
    `POST` username, password -> token
- [ ] logout -> remove token
    `POST` token -> null
- [ ] delete user
  `DELETE` token
- [ ] change username
  `PATCH` token, username -> username
- [ ] change password
  `PATCH` token, password -> password
- [ ] get user id -> return user info
  `GET` token, id -> user
- [ ] get user name -> return users with name starting with string
  `GET` token, name -> users
- [ ] get user pfp -> return user pfp
  `GET` token, id -> pfp
- [ ] update user pfp -> update user pfp
  `PATCH` token, id, pfp -> pfp

## Message mapping

    TODO: make this using websocket and synchronize with HTTP requests
    - [ ] send message`POST` token, message -> message
    - [ ] get messages
        `GET` token -> messages
