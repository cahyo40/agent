---
name: ruby-rails-developer
description: "Expert Ruby on Rails development including MVC architecture, ActiveRecord, Hotwire, and rapid application development"
---

# Ruby on Rails Developer

## Overview

Master Ruby on Rails for rapid application development. Leverage the "Convention over Configuration" philosophy, MVC architecture, ActiveRecord for database interactions, and Hotwire (Turbo/Stimulus) for modern reactive user interfaces.

## When to Use This Skill

- Use when building rapid MVPs or database-driven web apps
- Use when "Convention over Configuration" is preferred
- Use when needing a mature, battery-included framework
- Use when building server-side rendered apps with modern reactivity

## How It Works

### Step 1: Ruby Language Basics

```ruby
# Blocks and Procs
[1, 2, 3].each { |n| puts n * 2 }

# Classes and Modules
module Searchable
  def search(query)
    puts "Searching for #{query}..."
  end
end

class User
  include Searchable
  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end
end

# Syntactic sugar
user = User.new("John", "john@email.com")
puts user.name
```

### Step 2: Rails MVC & Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts do
    resources :comments
  end
  root "posts#index"
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, notice: "Post created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
```

### Step 3: ActiveRecord (ORM)

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: { minimum: 5 }
  
  scope :published, -> { where(published: true) }
  
  after_create :notify_subscribers

  private
  
  def notify_subscribers
    # logic here
  end
end

# Queries
Post.where(author: "Cahyo").order(created_at: :desc).limit(10)
Post.joins(:comments).where(comments: { approved: true })
```

### Step 4: Hotwire (Reactivity without JS)

```erb
<%# app/views/posts/index.html.erb %>
<%= turbo_frame_tag "posts_list" do %>
  <% @posts.each do |post| %>
    <%= render post %>
  <% end %>
<% end %>

<%# app/views/posts/_post.html.erb %>
<div id="<%= dom_id post %>">
  <h2><%= post.title %></h2>
  <%= link_to "Edit", edit_post_path(post), data: { turbo_frame: "_top" } %>
</div>
```

## Best Practices

### ✅ Do This

- ✅ Follow Rails naming conventions strictly
- ✅ Use `resources` in routes for RESTful APIs
- ✅ Keep controllers "skinny" and models "fat" (logic in models or services)
- ✅ Use database migrations for all schema changes
- ✅ Use partials to keep views DRY

### ❌ Avoid This

- ❌ Don't bypass ActiveRecord with raw SQL unless necessary for performance
- ❌ Don't put business logic in views
- ❌ Don't skip validations in models
- ❌ Don't ignore "The Rails Way" (Convention over Configuration)

## Related Skills

- `@senior-backend-developer` - Backend systems
- `@css-animation-specialist` - Frontend polish
- `@senior-database-engineer-sql` - Database optimization
