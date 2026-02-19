---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 4/7)
---
# 02 - Module Generator (Clean Architecture) (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Templates

### 9. DI Registration Template

**File:** `templates/di.go.tmpl`

```go
// In main.go or wire.go, add:

import (
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/delivery/http/handler"
	http{{.ModuleName}} "{{.ProjectModule}}/internal/{{.ModuleNameLower}}/delivery/http"
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/repository/postgres"
	{{.ModuleNameLower}}Usecase "{{.ProjectModule}}/internal/{{.ModuleNameLower}}/usecase"
)

// In initialization:
{{.ModuleNameLower}}Repo := postgres.New{{.ModuleName}}Repository(db)
{{.ModuleNameLower}}UC := {{.ModuleNameLower}}Usecase.New{{.ModuleName}}Usecase({{.ModuleNameLower}}Repo, logger)
{{.ModuleNameLower}}Handler := handler.New{{.ModuleName}}Handler({{.ModuleNameLower}}UC, logger)

// Register routes
api := router.Group("/api/v1")
http{{.ModuleName}}.Register{{.ModuleName}}Routes(api, {{.ModuleNameLower}}Handler)
```

---

