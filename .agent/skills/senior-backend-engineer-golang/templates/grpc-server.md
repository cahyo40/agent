# gRPC Server Patterns

## Protobuf Definition

```protobuf
// api/proto/user.proto
syntax = "proto3";

package user.v1;

option go_package = "myproject/api/proto/user/v1;userv1";

import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

service UserService {
    rpc CreateUser(CreateUserRequest) returns (UserResponse);
    rpc GetUser(GetUserRequest) returns (UserResponse);
    rpc UpdateUser(UpdateUserRequest) returns (UserResponse);
    rpc DeleteUser(DeleteUserRequest) returns (google.protobuf.Empty);
    rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
    
    // Server streaming
    rpc WatchUsers(WatchUsersRequest) returns (stream UserEvent);
}

message User {
    string id = 1;
    string email = 2;
    string name = 3;
    bool is_active = 4;
    google.protobuf.Timestamp created_at = 5;
    google.protobuf.Timestamp updated_at = 6;
}

message CreateUserRequest {
    string email = 1;
    string name = 2;
    string password = 3;
}

message GetUserRequest {
    string id = 1;
}

message UpdateUserRequest {
    string id = 1;
    optional string email = 2;
    optional string name = 3;
    optional bool is_active = 4;
}

message DeleteUserRequest {
    string id = 1;
}

message ListUsersRequest {
    int32 page = 1;
    int32 page_size = 2;
}

message ListUsersResponse {
    repeated User users = 1;
    int32 total = 2;
    int32 page = 3;
    int32 page_size = 4;
}

message UserResponse {
    User user = 1;
}

message WatchUsersRequest {}

message UserEvent {
    enum EventType {
        EVENT_TYPE_UNSPECIFIED = 0;
        EVENT_TYPE_CREATED = 1;
        EVENT_TYPE_UPDATED = 2;
        EVENT_TYPE_DELETED = 3;
    }
    EventType type = 1;
    User user = 2;
}
```

---

## gRPC Server Setup

```go
// cmd/grpc/main.go
package main

import (
    "context"
    "log"
    "net"
    "os"
    "os/signal"
    "syscall"

    "google.golang.org/grpc"
    "google.golang.org/grpc/health"
    "google.golang.org/grpc/health/grpc_health_v1"
    "google.golang.org/grpc/reflection"

    userv1 "myproject/api/proto/user/v1"
    "myproject/internal/config"
    "myproject/internal/delivery/grpc/interceptor"
    "myproject/internal/delivery/grpc/service"
    "myproject/internal/platform/logger"
)

func main() {
    cfg := config.Load()
    log := logger.New(cfg.LogLevel)

    // Create gRPC server with interceptors
    server := grpc.NewServer(
        grpc.ChainUnaryInterceptor(
            interceptor.Recovery(log),
            interceptor.RequestID(),
            interceptor.Logger(log),
            interceptor.Validator(),
        ),
        grpc.ChainStreamInterceptor(
            interceptor.StreamRecovery(log),
            interceptor.StreamLogger(log),
        ),
    )

    // Register services
    userService := service.NewUserService(userUsecase)
    userv1.RegisterUserServiceServer(server, userService)

    // Health check
    healthServer := health.NewServer()
    grpc_health_v1.RegisterHealthServer(server, healthServer)
    healthServer.SetServingStatus("user.v1.UserService", grpc_health_v1.HealthCheckResponse_SERVING)

    // Reflection for development
    if cfg.Environment != "production" {
        reflection.Register(server)
    }

    // Start listening
    lis, err := net.Listen("tcp", ":"+cfg.GRPCPort)
    if err != nil {
        log.Fatal("failed to listen", err)
    }

    go func() {
        log.Info("Starting gRPC server on port " + cfg.GRPCPort)
        if err := server.Serve(lis); err != nil {
            log.Fatal("failed to serve", err)
        }
    }()

    // Graceful shutdown
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Info("Shutting down gRPC server...")
    server.GracefulStop()
    log.Info("Server stopped")
}
```

---

## gRPC Service Implementation

```go
// internal/delivery/grpc/service/user_service.go
package service

import (
    "context"

    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
    "google.golang.org/protobuf/types/known/emptypb"
    "google.golang.org/protobuf/types/known/timestamppb"

    userv1 "myproject/api/proto/user/v1"
    "myproject/internal/domain"
)

type UserService struct {
    userv1.UnimplementedUserServiceServer
    usecase domain.UserUsecase
}

func NewUserService(uc domain.UserUsecase) *UserService {
    return &UserService{usecase: uc}
}

func (s *UserService) CreateUser(ctx context.Context, req *userv1.CreateUserRequest) (*userv1.UserResponse, error) {
    // Validate request
    if req.Email == "" || req.Name == "" || req.Password == "" {
        return nil, status.Error(codes.InvalidArgument, "email, name, and password are required")
    }

    user, err := s.usecase.Register(ctx, &domain.CreateUserRequest{
        Email:    req.Email,
        Name:     req.Name,
        Password: req.Password,
    })
    if err != nil {
        return nil, mapError(err)
    }

    return &userv1.UserResponse{
        User: toProtoUser(user),
    }, nil
}

func (s *UserService) GetUser(ctx context.Context, req *userv1.GetUserRequest) (*userv1.UserResponse, error) {
    if req.Id == "" {
        return nil, status.Error(codes.InvalidArgument, "id is required")
    }

    user, err := s.usecase.GetByID(ctx, req.Id)
    if err != nil {
        return nil, mapError(err)
    }

    return &userv1.UserResponse{
        User: toProtoUser(user),
    }, nil
}

func (s *UserService) ListUsers(ctx context.Context, req *userv1.ListUsersRequest) (*userv1.ListUsersResponse, error) {
    page := int(req.Page)
    pageSize := int(req.PageSize)

    if page < 1 {
        page = 1
    }
    if pageSize < 1 || pageSize > 100 {
        pageSize = 20
    }

    users, total, err := s.usecase.List(ctx, page, pageSize)
    if err != nil {
        return nil, mapError(err)
    }

    protoUsers := make([]*userv1.User, len(users))
    for i, u := range users {
        protoUsers[i] = toProtoUser(u)
    }

    return &userv1.ListUsersResponse{
        Users:    protoUsers,
        Total:    int32(total),
        Page:     int32(page),
        PageSize: int32(pageSize),
    }, nil
}

func (s *UserService) DeleteUser(ctx context.Context, req *userv1.DeleteUserRequest) (*emptypb.Empty, error) {
    if req.Id == "" {
        return nil, status.Error(codes.InvalidArgument, "id is required")
    }

    if err := s.usecase.Delete(ctx, req.Id); err != nil {
        return nil, mapError(err)
    }

    return &emptypb.Empty{}, nil
}

// toProtoUser converts domain User to protobuf User
func toProtoUser(u *domain.User) *userv1.User {
    return &userv1.User{
        Id:        u.ID,
        Email:     u.Email,
        Name:      u.Name,
        IsActive:  u.IsActive,
        CreatedAt: timestamppb.New(u.CreatedAt),
        UpdatedAt: timestamppb.New(u.UpdatedAt),
    }
}

// mapError maps domain errors to gRPC status codes
func mapError(err error) error {
    var appErr *domain.AppError
    if errors.As(err, &appErr) {
        switch {
        case errors.Is(appErr.Err, domain.ErrNotFound):
            return status.Error(codes.NotFound, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrConflict):
            return status.Error(codes.AlreadyExists, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrBadRequest):
            return status.Error(codes.InvalidArgument, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrUnauthorized):
            return status.Error(codes.Unauthenticated, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrForbidden):
            return status.Error(codes.PermissionDenied, appErr.Message)
        }
    }
    return status.Error(codes.Internal, "internal server error")
}
```

---

## gRPC Interceptors

```go
// internal/delivery/grpc/interceptor/logger.go
package interceptor

import (
    "context"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/status"

    "myproject/internal/platform/logger"
)

func Logger(log *logger.Logger) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        start := time.Now()
        requestID := getRequestID(ctx)

        resp, err := handler(ctx, req)

        duration := time.Since(start)
        code := status.Code(err)

        log.Info("gRPC request",
            "request_id", requestID,
            "method", info.FullMethod,
            "code", code.String(),
            "duration_ms", duration.Milliseconds(),
        )

        if err != nil {
            log.Error("gRPC error",
                "request_id", requestID,
                "method", info.FullMethod,
                "error", err.Error(),
            )
        }

        return resp, err
    }
}

func Recovery(log *logger.Logger) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (resp interface{}, err error) {
        defer func() {
            if r := recover(); r != nil {
                log.Error("gRPC panic recovered",
                    "method", info.FullMethod,
                    "panic", r,
                    "stack", string(debug.Stack()),
                )
                err = status.Error(codes.Internal, "internal server error")
            }
        }()

        return handler(ctx, req)
    }
}
```

---

## gRPC Client

```go
// internal/client/user_client.go
package client

import (
    "context"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"

    userv1 "myproject/api/proto/user/v1"
)

type UserClient struct {
    client userv1.UserServiceClient
    conn   *grpc.ClientConn
}

func NewUserClient(addr string) (*UserClient, error) {
    conn, err := grpc.Dial(
        addr,
        grpc.WithTransportCredentials(insecure.NewCredentials()),
        grpc.WithDefaultCallOptions(
            grpc.WaitForReady(true),
        ),
        grpc.WithUnaryInterceptor(clientLoggingInterceptor()),
    )
    if err != nil {
        return nil, err
    }

    return &UserClient{
        client: userv1.NewUserServiceClient(conn),
        conn:   conn,
    }, nil
}

func (c *UserClient) Close() error {
    return c.conn.Close()
}

func (c *UserClient) GetUser(ctx context.Context, id string) (*userv1.User, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    resp, err := c.client.GetUser(ctx, &userv1.GetUserRequest{Id: id})
    if err != nil {
        return nil, err
    }

    return resp.User, nil
}
```
