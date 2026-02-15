package com.example.gateway;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class DownstreamClient {

  private final RestClient rest = RestClient.create();

  @Value("${downstream.serviceA}")
  private String serviceA;

  @Value("${downstream.serviceB}")
  private String serviceB;

  @Value("${downstream.serviceC}")
  private String serviceC;

  public Map call(String targetService, String xType, String session, Map payload) {
    String baseUrl = switch (targetService) {
      case "service-a" -> serviceA;
      case "service-b" -> serviceB;
      case "service-c" -> serviceC;
      default -> throw new IllegalArgumentException("Unknown targetService: " + targetService);
    };

    return rest.post()
        .uri(baseUrl + "/api/handle")
        .contentType(MediaType.APPLICATION_JSON)
        .header("X-type", xType == null ? "not-provided" : xType)
        .header("X-Session", session == null ? "no-session" : session)
        .body(payload)
        .retrieve()
        .body(Map.class);
  }
}
