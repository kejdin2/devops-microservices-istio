package com.example.serviceb;

import java.time.Instant;
import java.util.HashMap;
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
      "service", "service-b",
      "version", "v1",
      "time", Instant.now().toString()
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

    long count;
    String redisStatus = "ok";
    try {
      String key = "service-b:v1:count:" + session;
      Long v = redis.opsForValue().increment(key);
      count = (v == null) ? -1 : v;
    } catch (Exception e) {
      redisStatus = "redis-not-available";
      count = -1;
    }

    Map<String, Object> resp = new HashMap<>();
    resp.put("service", "service-b");
    resp.put("version", "v1");
    resp.put("xType", xType);
    resp.put("session", session);
    resp.put("requestBody", body);

    // recognizable response difference for B:
    resp.put("operation", "order-processing");
    resp.put("status", "accepted-v1");

    resp.put("redisStatus", redisStatus);
    resp.put("redisCountForSession", count);
    return resp;
  }
}
