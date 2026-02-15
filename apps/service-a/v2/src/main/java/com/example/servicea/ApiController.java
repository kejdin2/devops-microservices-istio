package com.example.servicea;

import java.time.Instant;
import java.util.Map;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ApiController {

  private final StringRedisTemplate redis;

  public ApiController(StringRedisTemplate redis) {
    this.redis = redis;
  }

    @GetMapping("/info")
  public Map<String, Object> info() {
    return Map.of(
      "service", "service-a",
      "version", "v2",
      "time", Instant.now().toString(),
      "note", "v2 response format"
    );
  }


    @PostMapping("/handle")
  public Map<String, Object> handle(
      @RequestHeader HttpHeaders headers,
      @RequestBody Map<String, Object> body
  ) {
    String xType = headers.getFirst("X-type");
    if (xType == null) xType = "not-provided";

    String session = headers.getFirst("X-Session");
    if (session == null || session.isBlank()) session = "no-session";

    Long count;
    String redisStatus = "ok";

    try {
      String key = "service-a:v2:count:" + session;
      count = redis.opsForValue().increment(key);
    } catch (Exception e) {
      redisStatus = "redis-not-available";
      count = -1L; // IMPORTANT: avoid null (also makes output clearer)
    }

    java.util.Map<String, Object> resp = new java.util.HashMap<>();
    resp.put("service", "service-a");
    resp.put("version", "v2");
    resp.put("message", "Hello from service-a V2 (new logic)");
    resp.put("xType", xType);
    resp.put("session", session);
    resp.put("requestBody", body);
    resp.put("redisStatus", redisStatus);
    resp.put("redisCountForSession", count);

    return resp;
  }

}
