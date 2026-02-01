---
name: email-developer
description: "Expert HTML email development including responsive templates, email client compatibility, and deliverability best practices"
---

# Email Developer

## Overview

Build responsive HTML emails that work across all email clients.

## When to Use This Skill

- Use when creating email templates
- Use when building email campaigns

## How It Works

### Step 1: Email HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Email Title</title>
  <!--[if mso]>
  <style type="text/css">
    table { border-collapse: collapse; }
    .fallback-font { font-family: Arial, sans-serif; }
  </style>
  <![endif]-->
</head>
<body style="margin: 0; padding: 0; background-color: #f4f4f4;">
  <!-- Wrapper table -->
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding: 40px 0;">
        <!-- Content table -->
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" 
               style="background-color: #ffffff; border-radius: 8px;">
          <!-- Header -->
          <tr>
            <td style="padding: 40px 30px; text-align: center;">
              <img src="https://example.com/logo.png" alt="Logo" width="150">
            </td>
          </tr>
          
          <!-- Body -->
          <tr>
            <td style="padding: 20px 30px;">
              <h1 style="margin: 0 0 20px; font-size: 24px; color: #333333;">
                Welcome!
              </h1>
              <p style="margin: 0 0 20px; font-size: 16px; line-height: 1.5; color: #666666;">
                Thank you for signing up. We're excited to have you on board.
              </p>
            </td>
          </tr>
          
          <!-- CTA Button -->
          <tr>
            <td style="padding: 20px 30px;" align="center">
              <table role="presentation" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="background-color: #3b82f6; border-radius: 6px;">
                    <a href="https://example.com" 
                       style="display: inline-block; padding: 14px 30px; 
                              color: #ffffff; text-decoration: none; 
                              font-weight: bold;">
                      Get Started
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          
          <!-- Footer -->
          <tr>
            <td style="padding: 30px; background-color: #f9fafb; text-align: center;">
              <p style="margin: 0; font-size: 12px; color: #9ca3af;">
                © 2024 Company Name. All rights reserved.<br>
                <a href="#" style="color: #6b7280;">Unsubscribe</a>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

### Step 2: Responsive Email

```html
<style>
  @media screen and (max-width: 600px) {
    .wrapper { width: 100% !important; }
    .column { display: block !important; width: 100% !important; }
    .mobile-padding { padding: 20px !important; }
    .mobile-center { text-align: center !important; }
    .mobile-hide { display: none !important; }
    .mobile-full-width { width: 100% !important; height: auto !important; }
  }
</style>

<!-- Two column layout -->
<table role="presentation" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="column" width="50%" valign="top" style="padding: 10px;">
      <img src="product1.jpg" width="250" style="max-width: 100%;">
    </td>
    <td class="column" width="50%" valign="top" style="padding: 10px;">
      <img src="product2.jpg" width="250" style="max-width: 100%;">
    </td>
  </tr>
</table>
```

### Step 3: Dark Mode Support

```html
<style>
  :root {
    color-scheme: light dark;
  }
  
  @media (prefers-color-scheme: dark) {
    .darkmode-bg { background-color: #1a1a1a !important; }
    .darkmode-text { color: #ffffff !important; }
    .darkmode-secondary { color: #cccccc !important; }
  }
  
  /* Gmail dark mode */
  [data-ogsc] .darkmode-bg { background-color: #1a1a1a !important; }
  [data-ogsc] .darkmode-text { color: #ffffff !important; }
</style>

<td class="darkmode-bg" style="background-color: #ffffff;">
  <p class="darkmode-text" style="color: #333333;">Content</p>
</td>
```

### Step 4: Email Client Compatibility

```markdown
## Client Quirks

### Outlook (Windows)
- Uses Word rendering engine
- No CSS3 support
- Use tables for layout
- MSO conditional comments

### Gmail
- Strips <style> in <head>
- Inline styles required
- No @import
- Limited CSS support

### Apple Mail
- Best CSS support
- Supports animations
- Dark mode support

### Yahoo Mail
- Aggressive CSS stripping
- Use !important
- Inline styles recommended
```

### Step 5: Testing Checklist

```markdown
## Pre-send Checklist

### Content
- [ ] Subject line (< 50 chars)
- [ ] Preheader text
- [ ] Alt text for images
- [ ] Unsubscribe link
- [ ] Physical address

### Technical
- [ ] Inline CSS
- [ ] Images hosted externally
- [ ] Links working
- [ ] Responsive on mobile
- [ ] Dark mode tested

### Testing
- [ ] Litmus/Email on Acid
- [ ] Spam score check
- [ ] Send test to self
- [ ] Check all email clients
```

## Best Practices

- ✅ Use tables for layout
- ✅ Inline all CSS
- ✅ Include alt text
- ❌ Don't use JavaScript
- ❌ Don't use CSS position

## Related Skills

- `@copywriting`
- `@marketing-strategist`
