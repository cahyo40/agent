# HTMX Basic Patterns

## Progressive Enhancement with hx-boost

```html
<!-- All links and forms in this container use AJAX -->
<body hx-boost="true">
  <nav>
    <a href="/home">Home</a>
    <a href="/about">About</a>
    <a href="/contact">Contact</a>
  </nav>
  
  <main id="content">
    <!-- Page content swapped here -->
  </main>
</body>
```

## Click to Edit Pattern

```html
<!-- View mode -->
<div id="user-1">
  <span>John Doe</span>
  <button hx-get="/users/1/edit" hx-target="#user-1" hx-swap="outerHTML">
    Edit
  </button>
</div>

<!-- Edit mode (returned from server) -->
<form id="user-1" hx-put="/users/1" hx-target="this" hx-swap="outerHTML">
  <input name="name" value="John Doe" />
  <button type="submit">Save</button>
  <button hx-get="/users/1" hx-target="#user-1" hx-swap="outerHTML">Cancel</button>
</form>
```

## Infinite Scroll

```html
<div id="posts-container">
  <!-- Posts here -->
  <div class="post">Post 1</div>
  <div class="post">Post 2</div>
  
  <!-- Load more trigger -->
  <div 
    hx-get="/posts?page=2" 
    hx-trigger="revealed"
    hx-swap="outerHTML"
    hx-indicator="#loading"
  >
    <div id="loading" class="htmx-indicator">Loading more...</div>
  </div>
</div>
```

## Out-of-Band Updates (Multiple Regions)

```html
<!-- Primary target -->
<div id="main-content">
  <button hx-post="/api/action" hx-target="#main-content">
    Do Action
  </button>
</div>

<!-- These will also be updated via hx-swap-oob -->
<div id="notification-count">0</div>
<div id="status-bar">Ready</div>
```

Server response:

```html
<!-- Primary content -->
<div>Action completed!</div>

<!-- Out-of-band updates -->
<div id="notification-count" hx-swap-oob="true">5</div>
<div id="status-bar" hx-swap-oob="true">Action performed at 10:30</div>
```

## Confirmation Dialog

```html
<button 
  hx-delete="/users/1" 
  hx-confirm="Are you sure you want to delete this user?"
  hx-target="closest tr"
  hx-swap="outerHTML swap:1s"
>
  Delete
</button>
```

## Loading States with CSS

```css
/* Show indicator while request is in-flight */
.htmx-indicator {
  display: none;
}
.htmx-request .htmx-indicator {
  display: inline;
}

/* Disable button during request */
.htmx-request {
  pointer-events: none;
  opacity: 0.5;
}
```

```html
<button hx-post="/api/submit" class="htmx-request-enabled">
  <span>Submit</span>
  <span class="htmx-indicator">
    <svg class="spinner">...</svg>
  </span>
</button>
```

## Event Handling

```html
<!-- Listen to htmx events -->
<div 
  hx-get="/api/data"
  hx-on::before-request="console.log('Starting request')"
  hx-on::after-request="console.log('Request complete')"
  hx-on::error="alert('Error occurred')"
>
  Load Data
</div>

<!-- Custom events from server -->
<script>
document.body.addEventListener('showMessage', function(evt) {
  alert(evt.detail.message);
});
</script>
```

Server can trigger with header:

```
HX-Trigger: {"showMessage": {"message": "Success!"}}
```

## Request Headers

```html
<!-- Include CSRF token -->
<meta name="csrf-token" content="abc123">
<body hx-headers='{"X-CSRF-Token": "abc123"}'>
  ...
</body>

<!-- Or per-request -->
<button 
  hx-post="/api/action"
  hx-headers='{"Authorization": "Bearer token123"}'
>
  Secure Action
</button>
```

## Include Additional Values

```html
<!-- Include values from other elements -->
<input type="hidden" id="user-id" name="userId" value="123">

<button 
  hx-post="/api/action"
  hx-include="#user-id"
>
  Submit with User ID
</button>

<!-- Or include entire form -->
<button 
  hx-post="/api/action"
  hx-include="closest form"
>
  Submit Form
</button>
```
