---
name: digital-product-creator
description: "Expert digital product creation including ebooks, templates, courses, and downloadable assets"
---

# Digital Product Creator

## Overview

Create and sell digital products including ebooks, templates, and online courses.

## When to Use This Skill

- Use when creating digital products
- Use when monetizing knowledge

## How It Works

### Step 1: Digital Product Types

```markdown
## Popular Digital Products

### Information Products
- Ebooks & Guides (PDF)
- Online Courses (Video)
- Workshops & Webinars
- Membership Sites

### Templates & Tools
- Notion Templates
- Spreadsheet Templates
- Design Templates (Figma, Canva)
- Code Boilerplates

### Creative Assets
- Stock Photos
- Icons & Illustrations
- Fonts
- Audio/Music

### Software
- Mobile Apps
- Browser Extensions
- WordPress Plugins
- SaaS Tools
```

### Step 2: Ebook Creation Workflow

```markdown
## Ebook Pipeline

### 1. Research & Outline
- Identify target audience
- Research pain points
- Create chapter outline
- Estimate page count

### 2. Content Writing
- Write in Markdown/Notion
- Include examples & visuals
- Add actionable tips
- Create worksheets

### 3. Design & Layout
- Design cover (Canva/Figma)
- Format with consistent styles
- Add headers, callouts
- Include page numbers

### 4. Export & Deliver
- Export to PDF
- Add watermark (optional)
- Set up delivery (Gumroad, etc.)
- Create landing page
```

### Step 3: Pricing Strategy

```markdown
## Pricing Tiers

### Low Ticket ($10-50)
- Ebooks
- Simple templates
- Single assets
- Entry products

### Mid Ticket ($50-200)
- Comprehensive courses
- Template bundles
- Community access
- Workshop recordings

### High Ticket ($200+)
- Coaching/Consulting
- Done-for-you services
- Premium communities
- Enterprise licenses

## Pricing Tips
- Start with low ticket to build audience
- Bundle products for higher value
- Offer payment plans for high ticket
- Use limited-time pricing
```

### Step 4: Platform Selection

```markdown
## Selling Platforms

### Self-Hosted
- Gumroad (easy, 10% fee)
- Lemonsqueezy (modern, EU VAT)
- Paddle (global payments)

### Course Platforms
- Teachable
- Thinkific
- Podia (all-in-one)

### Marketplaces
- Etsy (templates)
- Creative Market (design)
- Udemy (courses)
- Amazon KDP (ebooks)

### Your Own Site
- WordPress + WooCommerce
- Next.js + Stripe
- Full control, more work
```

### Step 5: Launch Strategy

```markdown
## Pre-Launch (2-4 weeks before)
- Build email list
- Tease on social media
- Create waitlist
- Get beta testers

## Launch Week
- Send launch emails
- Offer early-bird pricing
- Share testimonials
- Live Q&A / Webinar

## Post-Launch
- Collect reviews
- Create case studies
- Update based on feedback
- Plan next product
```

### Step 6: Delivery Automation

```javascript
// Gumroad webhook handler
app.post('/webhook/gumroad', async (req, res) => {
  const { email, product_id, full_name } = req.body;
  
  // 1. Add to email list
  await addToMailingList(email, full_name, product_id);
  
  // 2. Send welcome email
  await sendEmail({
    to: email,
    subject: 'Welcome! Here is your product',
    template: 'product_delivery',
    data: { name: full_name, downloadLink: getDownloadLink(product_id) }
  });
  
  // 3. Add to community (if applicable)
  await addToDiscord(email, product_id);
  
  res.status(200).send('OK');
});
```

## Best Practices

- ✅ Validate idea before creating
- ✅ Start with MVP version
- ✅ Collect testimonials early
- ❌ Don't over-engineer first version
- ❌ Don't skip email marketing

## Related Skills

- `@copywriting`
- `@marketing-strategist`
