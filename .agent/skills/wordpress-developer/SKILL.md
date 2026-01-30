---
name: wordpress-developer
description: "Expert WordPress development including theme development, plugin creation, REST API, and performance optimization"
---

# WordPress Developer

## Overview

This skill helps you build custom WordPress themes, plugins, and full-featured websites with best practices.

## When to Use This Skill

- Use when building WordPress sites
- Use when creating custom themes
- Use when developing plugins
- Use when integrating with REST API

## How It Works

### Step 1: Theme Structure

```text
my-theme/
├── style.css              # Theme metadata + styles
├── functions.php          # Theme setup & hooks
├── index.php              # Fallback template
├── header.php
├── footer.php
├── sidebar.php
├── page.php               # Page template
├── single.php             # Single post
├── archive.php            # Archives
├── 404.php
├── template-parts/
│   ├── content.php
│   └── content-none.php
├── inc/
│   ├── customizer.php
│   └── template-functions.php
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
└── templates/
    └── page-custom.php
```

### Step 2: Theme Setup

```php
<?php
// functions.php

// Theme Setup
function mytheme_setup() {
    // Add theme support
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', ['search-form', 'gallery', 'caption']);
    add_theme_support('custom-logo');
    add_theme_support('woocommerce');
    
    // Register menus
    register_nav_menus([
        'primary' => __('Primary Menu', 'mytheme'),
        'footer'  => __('Footer Menu', 'mytheme'),
    ]);
}
add_action('after_setup_theme', 'mytheme_setup');

// Enqueue Scripts & Styles
function mytheme_scripts() {
    // Styles
    wp_enqueue_style(
        'mytheme-style',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
    
    // Scripts
    wp_enqueue_script(
        'mytheme-main',
        get_template_directory_uri() . '/assets/js/main.js',
        ['jquery'],
        '1.0.0',
        true
    );
    
    // Localize script for AJAX
    wp_localize_script('mytheme-main', 'mythemeAjax', [
        'ajaxurl' => admin_url('admin-ajax.php'),
        'nonce'   => wp_create_nonce('mytheme_nonce'),
    ]);
}
add_action('wp_enqueue_scripts', 'mytheme_scripts');

// Register Sidebars
function mytheme_widgets() {
    register_sidebar([
        'name'          => __('Sidebar', 'mytheme'),
        'id'            => 'sidebar-1',
        'before_widget' => '<div class="widget %2$s">',
        'after_widget'  => '</div>',
        'before_title'  => '<h3 class="widget-title">',
        'after_title'   => '</h3>',
    ]);
}
add_action('widgets_init', 'mytheme_widgets');
```

### Step 3: Custom Plugin

```php
<?php
/**
 * Plugin Name: My Custom Plugin
 * Description: A custom plugin example
 * Version: 1.0.0
 * Author: Your Name
 */

defined('ABSPATH') || exit;

class MyCustomPlugin {
    private static $instance = null;
    
    public static function instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function __construct() {
        $this->define_constants();
        $this->init_hooks();
    }
    
    private function define_constants() {
        define('MCP_VERSION', '1.0.0');
        define('MCP_PATH', plugin_dir_path(__FILE__));
        define('MCP_URL', plugin_dir_url(__FILE__));
    }
    
    private function init_hooks() {
        add_action('init', [$this, 'register_post_type']);
        add_action('rest_api_init', [$this, 'register_routes']);
        add_shortcode('my_shortcode', [$this, 'shortcode_handler']);
    }
    
    public function register_post_type() {
        register_post_type('portfolio', [
            'labels' => [
                'name' => __('Portfolio', 'mcp'),
                'singular_name' => __('Portfolio Item', 'mcp'),
            ],
            'public' => true,
            'has_archive' => true,
            'supports' => ['title', 'editor', 'thumbnail'],
            'show_in_rest' => true,
            'rewrite' => ['slug' => 'portfolio'],
        ]);
    }
    
    public function register_routes() {
        register_rest_route('mcp/v1', '/items', [
            'methods' => 'GET',
            'callback' => [$this, 'get_items'],
            'permission_callback' => '__return_true',
        ]);
    }
    
    public function get_items($request) {
        $posts = get_posts([
            'post_type' => 'portfolio',
            'numberposts' => 10,
        ]);
        
        return rest_ensure_response($posts);
    }
    
    public function shortcode_handler($atts) {
        $atts = shortcode_atts([
            'count' => 5,
        ], $atts);
        
        ob_start();
        include MCP_PATH . 'templates/shortcode.php';
        return ob_get_clean();
    }
}

MyCustomPlugin::instance();
```

### Step 4: Custom Fields (ACF)

```php
<?php
// Register ACF fields programmatically
if (function_exists('acf_add_local_field_group')) {
    acf_add_local_field_group([
        'key' => 'group_hero',
        'title' => 'Hero Section',
        'fields' => [
            [
                'key' => 'field_hero_title',
                'label' => 'Hero Title',
                'name' => 'hero_title',
                'type' => 'text',
            ],
            [
                'key' => 'field_hero_image',
                'label' => 'Hero Image',
                'name' => 'hero_image',
                'type' => 'image',
                'return_format' => 'array',
            ],
        ],
        'location' => [
            [
                ['param' => 'page_template', 'operator' => '==', 'value' => 'page-home.php'],
            ],
        ],
    ]);
}

// Usage in template
$hero_title = get_field('hero_title');
$hero_image = get_field('hero_image');
?>

<section class="hero">
    <h1><?php echo esc_html($hero_title); ?></h1>
    <?php if ($hero_image): ?>
        <img src="<?php echo esc_url($hero_image['url']); ?>" alt="<?php echo esc_attr($hero_image['alt']); ?>">
    <?php endif; ?>
</section>
```

### Step 5: WP Query & Performance

```php
<?php
// Optimized WP_Query
$args = [
    'post_type' => 'post',
    'posts_per_page' => 10,
    'no_found_rows' => true,  // Skip pagination count (faster)
    'update_post_meta_cache' => false,  // If not using meta
    'update_post_term_cache' => false,  // If not using terms
    'fields' => 'ids',  // Only get IDs if that's all you need
];

$query = new WP_Query($args);

// Transient caching
function get_featured_posts() {
    $cache_key = 'featured_posts';
    $posts = get_transient($cache_key);
    
    if (false === $posts) {
        $posts = get_posts([
            'post_type' => 'post',
            'meta_key' => 'featured',
            'meta_value' => '1',
            'numberposts' => 5,
        ]);
        set_transient($cache_key, $posts, HOUR_IN_SECONDS);
    }
    
    return $posts;
}
```

## Best Practices

### ✅ Do This

- ✅ Sanitize all inputs
- ✅ Escape all outputs
- ✅ Use nonces for forms
- ✅ Cache expensive queries
- ✅ Use child themes for customization

### ❌ Avoid This

- ❌ Don't edit core files
- ❌ Don't use query_posts()
- ❌ Don't skip security checks
- ❌ Don't hardcode URLs

## Related Skills

- `@senior-php-developer` - PHP patterns
- `@senior-seo-auditor` - SEO optimization
