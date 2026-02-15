package com.example.gateway;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class GatewayController {

  private final DownstreamClient downstream;

  public GatewayController(DownstreamClient downstream) {
    this.downstream = downstream;
  }

  @PostMapping("/entry")
  public Map<String, Object> entry(
      @RequestHeader HttpHeaders headers,
      @RequestBody Map<String, Object> body
  ) {
    String xType = headers.getFirst("X-type");
    String session = headers.getFirst("X-Session");

    Object target = body.get("targetService");
    Object payloadObj = body.get("payload");

    if (!(target instanceof String)) {
      throw new IllegalArgumentException("targetService must be a string (service-a|service-b|service-c)");
    }
    if (!(payloadObj instanceof Map)) {
      throw new IllegalArgumentException("payload must be a JSON object");
    }

    String targetService = (String) target;
    Map payload = (Map) payloadObj;

    Map downstreamResp = downstream.call(targetService, xType, session, payload);

    Map<String, Object> resp = new HashMap<>();
    resp.put("gateway", "frontend-gateway");
    resp.put("version", "v2");
    resp.put("note", "gateway v2: ready for full v2 rollout");
    resp.put("time", Instant.now().toString());
    resp.put("routedTo", targetService);
    resp.put("xType", xType == null ? "not-provided" : xType);
    resp.put("session", session == null ? "no-session" : session);
    resp.put("downstream", downstreamResp);
    return resp;
  }
}
