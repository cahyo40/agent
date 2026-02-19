---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 8/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## Development Tooling

### Air - Hot Reload

**Output:** `.air.toml`

```toml
root = "."
tmp_dir = "tmp"

[build]
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/api/main.go"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "docs", "migrations"]
  exclude_regex = ["_test.go"]
  include_ext = ["go", "tpl", "tmpl", "html", "env"]
  kill_delay = "0s"
  send_interrupt = false
  stop_on_error = true

[log]
  time = false

[color]
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[misc]
  clean_on_exit = true
```

### GolangCI-Lint Configuration

**Output:** `.golangci.yml`

```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports
    - misspell
    - unconvert
    - bodyclose
    - noctx
    - prealloc

linters-settings:
  govet:
    enable-all: true
  misspell:
    locale: US
  goimports:
    local-prefixes: github.com/yourusername/project-name

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
```

### EditorConfig

**Output:** `.editorconfig`

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.go]
indent_style = tab
indent_size = 4

[*.{yaml,yml,json,toml}]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

---


## Troubleshooting

### Common Issues

**Issue: `connection refused` ke PostgreSQL**
```bash
# Check PostgreSQL status
sudo service postgresql status

# Start PostgreSQL
sudo service postgresql start

# Verify connection
psql -U postgres -h localhost
```

**Issue: `migrate` command not found**
```bash
# Install migrate CLI
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Ensure $GOPATH/bin is in PATH
export PATH=$PATH:$(go env GOPATH)/bin
```

**Issue: Port already in use**
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>

# Atau ganti port di .env
HTTP_PORT=:8081
```

**Issue: Module not found**
```bash
# Clear module cache
go clean -modcache

# Re-download dependencies
go mod download
```

---

**End of Workflow: Golang Backend Project Setup**

Generated workflow dengan Clean Architecture pattern. Ready untuk dikembangkan menjadi production-ready backend API.
