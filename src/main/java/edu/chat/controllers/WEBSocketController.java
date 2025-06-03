package edu.chat.controllers;

import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.java_websocket.WebSocket;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_6455;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.web.ServerProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import edu.chat.routes.ParticipantsRouts;
import edu.chat.routes.UserRoutes;
import edu.chat.services.WEBSocketService;
import edu.chat.views.enums.WEBSocketRequestType;

@Component
public class WEBSocketController extends WebSocketServer {
    private static WEBSocketController WEBSC;
    private static HashMap<Integer, WebSocket> clients = new HashMap<>();
    private static Logger log = LogManager.getLogger(WEBSocketController.class.getName());

    @Autowired
    private UserRoutes userService;

    @Autowired
    private WEBSocketService webSocketService;

    @Autowired
    private ServerProperties serverProperties;

    @Autowired
    private ParticipantsRouts participantsRouts;

    public static String getServerData() {
        return WEBSC.getAddress().getAddress().getHostAddress() + ":" + WEBSC.getPort();
    }

    public static String parseUserShort(WebSocket conn) {
        return conn.getRemoteSocketAddress().getAddress().getHostAddress() + ":" + conn.getRemoteSocketAddress().getPort();
    }

    public WEBSocketController() {
    }

    @Bean
    public WEBSocketController initController() {
        WEBSC = new WEBSocketController(new InetSocketAddress(serverProperties.getAddress(), 8081));
        WEBSC.setConnectionLostTimeout(60_000);
        WEBSC.start();
        Thread connectionStatusThread = new Thread("WEBSocketConnectionStatusThread") {
            @Override
            public void run() {
                StringBuilder SB = new StringBuilder();
                while (true) {
                    try {
                        Thread.sleep(60_000);
                    } catch (InterruptedException e) {
                    }
                    SB.replace(0, SB.length(), "");
                    Collection<WebSocket> connections = WEBSC.getConnections();
                    SB.append("Server Connections: [" + connections.size() + "]");
                    // for (WebSocket webSocketWorker : connections) {
                    // SB.append("\n"+webSocketWorker.getRemoteSocketAddress() );
                    // }
                    log.info(SB.toString());
                }
            }
        };
        connectionStatusThread.setDaemon(true);
        connectionStatusThread.start();
        return WEBSC;
    }

    public WEBSocketController(int port) throws UnknownHostException {
        super(new InetSocketAddress(port));
    }

    public WEBSocketController(InetSocketAddress address) {
        super(address);
    }

    public WEBSocketController(int port, Draft_6455 draft) {
        super(new InetSocketAddress(port), Collections.<Draft>singletonList(draft));
    }

    private static JsonObject prepareErrorResponse(String message) {
        JsonObject response = new JsonObject();
        response.addProperty("type", "error");
        response.addProperty("message", message);
        return response;
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        log.info("New connection: " + parseUserShort(conn));
        // clients.put(conn.getRemoteSocketAddress().getAddress().getHostAddress() + ":"
        // + conn.getRemoteSocketAddress().getPort(), conn);
        log.info("Total connections: " + clients.size());
        log.info("Handshake: " + handshake.getResourceDescriptor() + " " + handshake.getFieldValue("Sec-WebSocket-Key") + " " + handshake.getFieldValue("Sec-WebSocket-Protocol"));
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        log.info("Closed connection: " + parseUserShort(conn));
        clients.values().remove(conn);
        log.info("Total connections: [" + clients.size() + "]");
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        // log.info("Message from " + parseUserShort(conn) + ": " + message);
        JsonObject request = new Gson().fromJson(message, JsonObject.class);
        try {
            userService.validateToken(request.get("token").getAsString());
        } catch (Exception e) {
            log.error("Error processing request: " + e.getMessage());
            conn.send(prepareErrorResponse("Error processing request: " + e.getMessage()).toString());
            return;
        }

        // Here all the checks passed
        JsonObject response = new JsonObject();
        WEBSocketRequestType requestType = WEBSocketRequestType.valueOf(request.get("type").getAsString());
        JsonObject data = request.getAsJsonObject("data");
        String token = request.get("token").getAsString();
        try {
            switch (requestType) {
            case bind: {
                log.info("Binding user: " + data.get("id").getAsInt());
                clients.put(data.get("id").getAsInt(), conn);
                break;
            }
            case getUsersByName: {
                response = webSocketService.prepareGetUsersByUsernameResponse(requestType, data, token);
                break;
            }
            case getPFP: {
                response = webSocketService.prepareGetPFPResponse(requestType, data);
                break;
            }
            case newChatPrivate: {
                response = webSocketService.prepareNewChatPrivateResponse(requestType, data);
                break;
            }
            case getChats: {
                response = webSocketService.prepareGetChatsResponse(requestType, data, token);
                break;
            }
            case sendMessage: {
                response.addProperty("type", requestType.toString());
                if (webSocketService.prepareSendMessageResponse(requestType, data)) {
                    response.addProperty("success", true);
                    // Handle dispatch to users
                    int chat_id = data.get("chat_id").getAsInt();
                    List<Integer> ids = participantsRouts.getFromChat(chat_id);
                    ids.remove((Integer) data.get("user_id").getAsInt());// Exclude sender
                    JsonObject participantMessage = new JsonObject();
                    participantMessage.addProperty("type", WEBSocketRequestType.newMessage.toString());
                    participantMessage.add("data", data);
                    for (Integer id : ids) {
                        log.debug("Sending data to user: " + id);
                        if (clients.containsKey(id)) {
                            clients.get(id).send(participantMessage.toString());
                        }
                    }
                } else {
                    response.addProperty("success", false);
                }
                break;
            }
            case deleteChat: {
                response = webSocketService.prepareDeleteChatResponse(requestType, data);
                break;
            }
            case getMessages: {
                response = webSocketService.prepareGetMessagesResponse(requestType, data);
                break;
            }

            default: {
                throw new UnsupportedOperationException("Unsupported request type: " + requestType);
            }
            }
        } catch (Exception e) {
            log.error("Error processing request: " + e.getMessage());
            response = prepareErrorResponse("Error processing request: " + e.getMessage());
        }
        conn.send(response.toString());
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        log.error(ex.getMessage());
    }

    @Override
    public void onStart() {
        log.info("ChatServer started on: " + getServerData());
    }

}
