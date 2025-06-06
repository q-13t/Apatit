package edu.chat.configuration;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

// import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Service;
import org.springframework.web.filter.OncePerRequestFilter;

import com.google.gson.JsonObject;

import edu.chat.routes.UserRoutes;
import edu.chat.utils.JWTUtil;
import io.micrometer.common.lang.NonNull;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Service
@ConfigurationProperties(prefix = "jwt")
@WebFilter(urlPatterns = "/*", filterName = "JWTFilter")
@Order(1)
public class JWTFilter extends OncePerRequestFilter {
    private Logger log = LogManager.getLogger(JWTFilter.class.getName());

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

    private Pattern excludedUrls = Pattern.compile("/ping|/user/login|/user/register|/actuator/.+|/$");

    private boolean shouldNotBeFiltered(@NonNull HttpServletRequest request) {
        Matcher matcher = excludedUrls.matcher(request.getRequestURI());
        boolean isExcluded = matcher.matches();
        log.info("Request URI: " + request.getRequestURI() + " - Method: " + request.getMethod() + " - Excluded: " + isExcluded);
        return isExcluded;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull FilterChain filterChain) throws ServletException, IOException {
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