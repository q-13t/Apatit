package edu.chat.utils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Service;

import edu.chat.services.UserService;
import edu.chat.views.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
@ConfigurationProperties(prefix = "jwt")
public class JWTUtil {

    @Autowired
    private static UserService userService;
    private static String SECRET_KEY;
    private static int EXPIRATION_TIME;

    public String getSecret() {
        return SECRET_KEY;
    }

    public void setSecret(String secret) {
        SECRET_KEY = secret;
    }

    public int getExpires() {
        return EXPIRATION_TIME;
    }

    public void setExpires(int expires) {
        EXPIRATION_TIME = expires;
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsExtractor) {
        final Claims claims = extractAllClaims(token);
        return claimsExtractor.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(getKey()).build().parseClaimsJws(token).getBody();
    }

    public Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public String generateToken(User userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername());
    }

    private static SecretKey getKey() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }

    private String createToken(Map<String, Object> claims, String username) {
        long timeMillis = System.currentTimeMillis();
        Date current_date = new Date(timeMillis);
        Date expiration = new Date(timeMillis + EXPIRATION_TIME + 1000 * 60 * 60);
        return Jwts.builder().setClaims(claims).setSubject(username).setIssuedAt(current_date).setExpiration(expiration).signWith(getKey()).compact();
    }

}
