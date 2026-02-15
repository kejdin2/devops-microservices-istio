# DevOps Microservices with Istio — Practical Assignment

## Overview
This project implements a microservices architecture deployed on Kubernetes and managed through Istio service mesh.  
The objective is to demonstrate modern DevOps practices including containerization, traffic management, canary releases, A/B testing and rollback strategies.

The system contains multiple services communicating through an API gateway and uses Redis for shared session state.

---

## Architecture

Client → Frontend Gateway → Service A / Service B / Service C → Redis

All communication between services is controlled by Istio.

Key concepts demonstrated:

- Kubernetes deployments (v1 and v2)
- Istio VirtualServices & DestinationRules
- Canary deployments
- Header-based A/B testing
- Full rollout to new version
- Rollback to stable version
- Automated test scripts
