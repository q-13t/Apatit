package edu.chat.configuration;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.filter.OncePerRequestFilter;

import com.google.gson.JsonObject;

import edu.chat.routes.UserRoutes;
import edu.chat.utils.JWTUtil;

@Service
@ConfigurationProperties(prefix = "jwt")
public class JWTFilter extends OncePerRequestFilter {
    // private Logger log = Logger.getLogger(UserController.class.getName());

    @Autowired
    private UserRoutes userRoutes;

    @Autowired
    private JWTUtil jwtTokenUtil;

    private static String SECRET_KEY;

    public String getSecret() {
        return SECRET_KEY;
    }

    public void setSecret(String secret) {
        SECRET_KEY = secret;
    }

    private List<String> excludedUrls = Arrays.asList("/user/login", "/user/register");

    private boolean shouldNotBeFiltered(HttpServletRequest request) {
        return excludedUrls.contains(request.getRequestURI());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        if (shouldNotBeFiltered(request)) {
            filterChain.doFilter(request, response);
            return;
        }
        JsonObject json = new JsonObject();
        final String authHeader = request.getHeader("Authorization");
        String jwt = null;
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            json.addProperty("message", "Missing Authorization Header");
            response.getWriter().write(json.toString());
            return;
        }
        jwt = authHeader.substring(7);
        try {
            String username = jwtTokenUtil.extractUsername(jwt);
            if (!userRoutes.checkUserExists(username)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                json.addProperty("message", "User does not exist");
                response.getWriter().write(json.toString());
                return;
            } else if (jwtTokenUtil.isTokenExpired(jwt)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                json.addProperty("message", "Token is expired");
                response.getWriter().write(json.toString());
                return;
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            json.addProperty("message", "Token is invalid");
            response.getWriter().write(json.toString());
            return;
        }

        filterChain.doFilter(request, response);
    }
}