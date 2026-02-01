---
name: senior-grpc-developer
description: "Expert gRPC development including protocol buffers, service definitions, streaming, interceptors, and high-performance RPC communication"
---

# Senior gRPC Developer

## Overview

Build high-performance RPC systems with gRPC including Protocol Buffers, streaming patterns, interceptors, and service mesh integration.

## When to Use This Skill

- Use when building microservices
- Use when high-performance RPC needed
- Use when strong typing required
- Use when bidirectional streaming

## How It Works

### Step 1: Protocol Buffers

```protobuf
// user.proto
syntax = "proto3";

package user.v1;

option go_package = "github.com/example/user/v1";

// User service definition
service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse);
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);
  
  // Streaming
  rpc WatchUsers(WatchUsersRequest) returns (stream UserEvent);
  rpc BulkCreateUsers(stream CreateUserRequest) returns (BulkCreateResponse);
  rpc Chat(stream ChatMessage) returns (stream ChatMessage);
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  UserStatus status = 4;
  google.protobuf.Timestamp created_at = 5;
}

enum UserStatus {
  USER_STATUS_UNSPECIFIED = 0;
  USER_STATUS_ACTIVE = 1;
  USER_STATUS_INACTIVE = 2;
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}
```

### Step 2: Server Implementation (Go)

```go
package main

import (
    "context"
    "net"
    "google.golang.org/grpc"
    pb "github.com/example/user/v1"
)

type userServer struct {
    pb.UnimplementedUserServiceServer
    repo UserRepository
}

func (s *userServer) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
    user, err := s.repo.FindByID(ctx, req.GetId())
    if err != nil {
        return nil, status.Error(codes.NotFound, "user not found")
    }
    return &pb.GetUserResponse{User: toProto(user)}, nil
}

// Server streaming
func (s *userServer) WatchUsers(req *pb.WatchUsersRequest, stream pb.UserService_WatchUsersServer) error {
    events := s.repo.Watch(stream.Context())
    for event := range events {
        if err := stream.Send(event); err != nil {
            return err
        }
    }
    return nil
}

// Bidirectional streaming
func (s *userServer) Chat(stream pb.UserService_ChatServer) error {
    for {
        msg, err := stream.Recv()
        if err == io.EOF {
            return nil
        }
        if err != nil {
            return err
        }
        // Process and respond
        response := processMessage(msg)
        if err := stream.Send(response); err != nil {
            return err
        }
    }
}

func main() {
    lis, _ := net.Listen("tcp", ":50051")
    s := grpc.NewServer(
        grpc.UnaryInterceptor(loggingInterceptor),
    )
    pb.RegisterUserServiceServer(s, &userServer{})
    s.Serve(lis)
}
```

### Step 3: Client Implementation

```go
// Go client
conn, _ := grpc.Dial("localhost:50051", grpc.WithInsecure())
defer conn.Close()

client := pb.NewUserServiceClient(conn)

// Unary call
resp, err := client.GetUser(context.Background(), &pb.GetUserRequest{Id: "123"})

// Server streaming
stream, _ := client.WatchUsers(ctx, &pb.WatchUsersRequest{})
for {
    event, err := stream.Recv()
    if err == io.EOF {
        break
    }
    fmt.Println(event)
}
```

```typescript
// Node.js client
import { UserServiceClient } from './generated/user_grpc_pb';
import { GetUserRequest } from './generated/user_pb';
import * as grpc from '@grpc/grpc-js';

const client = new UserServiceClient(
  'localhost:50051',
  grpc.credentials.createInsecure()
);

const request = new GetUserRequest();
request.setId('123');

client.getUser(request, (err, response) => {
  if (err) throw err;
  console.log(response.getUser());
});
```

### Step 4: Interceptors & Middleware

```go
// Logging interceptor
func loggingInterceptor(
    ctx context.Context,
    req interface{},
    info *grpc.UnaryServerInfo,
    handler grpc.UnaryHandler,
) (interface{}, error) {
    start := time.Now()
    resp, err := handler(ctx, req)
    log.Printf("Method: %s, Duration: %v, Error: %v", 
        info.FullMethod, time.Since(start), err)
    return resp, err
}

// Auth interceptor
func authInterceptor(
    ctx context.Context,
    req interface{},
    info *grpc.UnaryServerInfo,
    handler grpc.UnaryHandler,
) (interface{}, error) {
    md, ok := metadata.FromIncomingContext(ctx)
    if !ok {
        return nil, status.Error(codes.Unauthenticated, "no metadata")
    }
    
    token := md.Get("authorization")
    if len(token) == 0 {
        return nil, status.Error(codes.Unauthenticated, "no token")
    }
    
    // Validate token...
    return handler(ctx, req)
}
```

## Best Practices

### ✅ Do This

- ✅ Use proto3 syntax
- ✅ Version your services
- ✅ Use interceptors for logging
- ✅ Define error codes properly
- ✅ Use deadlines/timeouts

### ❌ Avoid This

- ❌ Don't skip SSL/TLS
- ❌ Don't ignore streaming errors
- ❌ Don't hardcode addresses
- ❌ Don't skip retry policies

## Related Skills

- `@microservices-architect` - Microservices patterns
- `@senior-backend-engineer-golang` - Go development
