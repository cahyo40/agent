---
name: elixir-phoenix-developer
description: "Expert Elixir and Phoenix development including functional programming, OTP, LiveView, and scalable real-time applications"
---

# Elixir Phoenix Developer

## Overview

Build scalable applications with Elixir and Phoenix including functional programming, OTP patterns, LiveView for real-time UI, and fault-tolerant systems.

## When to Use This Skill

- Use when building real-time applications
- Use when high concurrency needed
- Use when fault-tolerance required
- Use when functional programming preferred

## How It Works

### Step 1: Elixir Fundamentals

```elixir
# Pattern matching
{:ok, user} = get_user(id)
[head | tail] = [1, 2, 3, 4]
%{name: name, age: age} = %{name: "John", age: 30}

# Pipe operator
result = data
  |> filter_active()
  |> sort_by_date()
  |> take(10)
  |> format_response()

# Functions and guards
defmodule Math do
  def factorial(0), do: 1
  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end
end

# Enum operations
users
|> Enum.filter(&(&1.active))
|> Enum.map(&%{name: &1.name, email: &1.email})
|> Enum.sort_by(&(&1.name))

# Processes
spawn(fn -> do_heavy_work() end)

# GenServer
defmodule Counter do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def increment, do: GenServer.call(__MODULE__, :increment)
  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(initial), do: {:ok, initial}

  @impl true
  def handle_call(:increment, _from, state), do: {:reply, state + 1, state + 1}
  def handle_call(:get, _from, state), do: {:reply, state, state}
end
```

### Step 2: Phoenix Framework

```elixir
# Router
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MyAppWeb.AuthPlug
  end

  scope "/api", MyAppWeb do
    pipe_through :api
    
    resources "/users", UserController, except: [:new, :edit]
    post "/auth/login", AuthController, :login
  end
end

# Controller
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(:show, user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end

# Context
defmodule MyApp.Accounts do
  alias MyApp.Repo
  alias MyApp.Accounts.User

  def list_users(params \\ %{}) do
    User
    |> filter_by_status(params["status"])
    |> Repo.paginate(params)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

### Step 3: Phoenix LiveView

```elixir
defmodule MyAppWeb.ChatLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "chat:lobby")
    end

    {:ok, assign(socket, messages: [], message: "")}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    new_message = %{text: message, user: socket.assigns.current_user}
    Phoenix.PubSub.broadcast(MyApp.PubSub, "chat:lobby", {:new_message, new_message})
    {:noreply, assign(socket, message: "")}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &[message | &1])}
  end

  def render(assigns) do
    ~H"""
    <div class="chat-container">
      <div class="messages">
        <%= for msg <- @messages do %>
          <div class="message">
            <strong><%= msg.user.name %>:</strong> <%= msg.text %>
          </div>
        <% end %>
      </div>
      <form phx-submit="send_message">
        <input type="text" name="message" value={@message} />
        <button type="submit">Send</button>
      </form>
    </div>
    """
  end
end
```

### Step 4: OTP Supervision

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyApp.Repo,
      MyAppWeb.Endpoint,
      {Phoenix.PubSub, name: MyApp.PubSub},
      MyApp.TaskSupervisor,
      {MyApp.Cache, []},
      {MyApp.JobQueue, []}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

# Dynamic supervisor for worker processes
defmodule MyApp.TaskSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_worker(args) do
    spec = {MyApp.Worker, args}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
```

## Best Practices

### ✅ Do This

- ✅ Use pattern matching
- ✅ Embrace immutability
- ✅ Use supervision trees
- ✅ Leverage OTP behaviors
- ✅ Use LiveView for real-time

### ❌ Avoid This

- ❌ Don't mutate state
- ❌ Don't ignore process errors
- ❌ Don't skip tests
- ❌ Don't block processes

## Related Skills

- `@senior-backend-developer` - Backend patterns
- `@senior-software-architect` - System design
