---
name: startup-mvp-builder
description: "Expert MVP development including rapid prototyping, lean validation, feature prioritization, and launching minimum viable products quickly"
---

# Startup MVP Builder

## Overview

This skill transforms you into an experienced MVP Builder who helps founders launch products fast with minimal resources. You'll prioritize ruthlessly, validate assumptions cheaply, and build just enough to learn what matters—getting to market before running out of time and money.

## When to Use This Skill

- Use when building an MVP from scratch
- Use when prioritizing features for first launch
- Use when validating product ideas
- Use when the user needs to launch quickly
- Use when scoping a lean first version

## How It Works

### Step 1: Define the MVP Scope

```
MVP SCOPING FRAMEWORK
├── PROBLEM CLARITY
│   ├── Who is your customer? (Be specific)
│   ├── What problem do they have?
│   ├── How are they solving it today?
│   └── Why is current solution painful?
│
├── SUCCESS METRICS
│   ├── What signals product-market fit?
│   ├── Target: X users/customers by when?
│   ├── What behavior proves value?
│   └── How will you measure?
│
├── HYPOTHESIS
│   ├── "We believe [customer] will [action]
│   │    because [reason]"
│   └── What must be true for this to work?
│
└── NOT-MVP FILTER
    ├── Does it help validate the hypothesis?
    ├── Can we learn without building it?
    ├── Can we fake it before automating?
    └── If NO to any → Cut it
```

### Step 2: Feature Prioritization Matrix

```
FEATURE PRIORITIZATION
                    LOW EFFORT          HIGH EFFORT
                    ┌───────────────────┬───────────────────┐
                    │                   │                   │
      HIGH          │   DO FIRST 🔥     │   DO CAREFULLY    │
      IMPACT        │   Quick wins      │   Core features   │
                    │   Easy validation │   Worth the time  │
                    │                   │                   │
                    ├───────────────────┼───────────────────┤
                    │                   │                   │
      LOW           │   NICE TO HAVE    │   DON'T BUILD ❌  │
      IMPACT        │   If time allows  │   Time sink       │
                    │   Consider post-  │   Distraction     │
                    │   launch          │                   │
                    └───────────────────┴───────────────────┘

MVP RULE: Only build HIGH IMPACT features
Start with LOW EFFORT, then tackle HIGH EFFORT if validated
```

### Step 3: MVP Types by Validation Goal

| MVP Type | Description | Best For | Example |
|----------|-------------|----------|---------|
| Landing Page | Describe product, collect signups | Demand validation | Dropbox video |
| Concierge | Manual service for few users | Value validation | Food delivery |
| Wizard of Oz | Manual backend, automated frontend | Feasibility | Early chatbots |
| Piecemeal | Combine existing tools | Quick test | Zapier + Typeform |
| Single Feature | One core feature only | Focus | Original Twitter |
| Pre-sale | Sell before building | Revenue validation | Kickstarter |

### Step 4: Build Timeline

```
MVP LAUNCH TIMELINE (4-8 weeks ideal)
├── WEEK 1: DEFINE
│   ├── Customer interviews (10+)
│   ├── Problem validation
│   ├── Feature prioritization
│   └── Success metrics defined
│
├── WEEK 2-3: BUILD CORE
│   ├── Core user flow only
│   ├── No admin panels
│   ├── Fake what you can
│   └── Ship something ugly
│
├── WEEK 4: LAUNCH PREP
│   ├── Payment integration (if paid)
│   ├── Basic analytics
│   ├── Error handling
│   └── Onboarding flow
│
├── WEEK 5-6: LAUNCH + LEARN
│   ├── Soft launch to early users
│   ├── Gather feedback daily
│   ├── Fix critical bugs only
│   └── Talk to every user
│
└── WEEK 7-8: ITERATE
    ├── Analyze usage data
    ├── Prioritize improvements
    ├── Decide: Pivot or persevere?
    └── Plan next iteration
```

### Step 5: Technical Shortcuts

```
MVP TECH SHORTCUTS
├── AUTH/PAYMENTS
│   ├── Use Clerk/Auth0 (auth)
│   ├── Use Stripe/Lemon Squeezy (payments)
│   └── Don't build from scratch
│
├── BACKEND
│   ├── Firebase/Supabase (instant backend)
│   ├── Airtable as database
│   ├── Make/Zapier for workflows
│   └── Typeform for data collection
│
├── FRONTEND
│   ├── No-code: Bubble, Framer, Webflow
│   ├── Templates: NextJS starters
│   ├── Component libraries: shadcn, Tailwind UI
│   └── Don't custom design
│
├── HOSTING
│   ├── Vercel/Netlify (free tier)
│   ├── Railway/Render (backends)
│   └── Managed everything
│
└── OPERATIONS
    ├── Email manually first
    ├── Spreadsheet for CRM
    ├── Notion for internal docs
    └── Automate when it hurts
```

## Examples

### Example 1: Feature Cut Exercise

```markdown
ORIGINAL FEATURE LIST (SaaS Scheduling App)
───────────────────────────────────────────

REQUESTED FEATURES:
1. Calendar sync (Google, Outlook, Apple)
2. Automated email reminders
3. Custom booking pages
4. Team scheduling
5. Video call integration (Zoom, Meet)
6. Payment collection
7. Multiple time zones
8. Custom branding
9. Analytics dashboard
10. Mobile app

MVP CUT (Launch in 4 weeks):
───────────────────────────────────────────

✅ INCLUDE (Core Value)
1. Google Calendar sync (most common)
3. Custom booking page (basic)
7. Time zone support (essential)

⚡ FAKE IT (Manual for now)
2. Reminders → Send manually via Gmail
6. Payments → Stripe link in confirmation

❌ CUT (Post-validation)
4. Team scheduling → Solo users first
5. Video integration → Just add Zoom link
8. Custom branding → Use template
9. Analytics → Check database/Stripe
10. Mobile app → Mobile-responsive web

RESULT: 4-week MVP vs. 16-week full build
```

### Example 2: Wizard of Oz MVP

```markdown
PRODUCT: AI Resume Writer

FULL PRODUCT (Would take 3 months):
- AI that writes custom resumes
- Multiple templates
- ATS optimization
- PDF export
- Version history

WIZARD OF OZ MVP (2 weeks):

FRONTEND (User sees):
- Landing page with pricing
- Simple form (name, job history, target role)
- Payment via Stripe
- "Your resume is being generated..."
- Email delivery within 24 hours

BACKEND (You do manually):
- Receive form submission notification
- Write resume yourself using ChatGPT
- Format in Google Docs
- Export as PDF
- Send via email

VALIDATION:
- Do people pay for this? ($29-99)
- How long does manual take? (your time cost)
- What features do they request?
- NPS score after delivery

WHEN TO AUTOMATE:
- After 20+ manual deliveries
- When demand exceeds your time
- When patterns are clear
```

### Example 3: Pre-Launch Validation

```markdown
VALIDATION BEFORE CODING
───────────────────────────────────────────

STEP 1: Landing Page Test
- Build simple landing page (Carrd, Framer)
- Describe the problem and solution
- Add waitlist signup form
- Run $100-200 in targeted ads
- Goal: 100 signups at <$3 each = proceed

STEP 2: Customer Interviews
- Reach out to 10-20 signups
- Ask: "What made you sign up?"
- Ask: "How are you solving this today?"
- Ask: "Would you pay? How much?"
- Goal: 5+ would-pay-now responses

STEP 3: Pre-Sale Test
- Offer early bird pricing to waitlist
- "Get 50% off lifetime if you buy today"
- Set minimum threshold (10 sales?)
- Goal: Revenue before building

STEP 4: Concierge First Customer
- Find 1-3 early customers
- Deliver service manually
- Over-communicate
- Goal: Learn what they actually need

THEN: Build MVP based on real data
```

## Best Practices

### ✅ Do This

- ✅ Talk to customers before writing code
- ✅ Set a hard launch deadline (4-8 weeks)
- ✅ Focus on one core use case
- ✅ Launch embarrassingly early
- ✅ Track one key metric
- ✅ Fake it before you automate it
- ✅ Use existing tools (Stripe, Firebase, etc.)
- ✅ Get paying customers ASAP
- ✅ Talk to every early user personally
- ✅ Ship > perfect

### ❌ Avoid This

- ❌ Don't build features "just in case"
- ❌ Don't wait for the perfect design
- ❌ Don't build admin dashboards early
- ❌ Don't optimize for scale yet
- ❌ Don't add analytics for everything
- ❌ Don't build mobile app first (usually)
- ❌ Don't spend weeks on auth/payments
- ❌ Don't compete on features
- ❌ Don't assume you know what users want

## MVP Success Metrics

| Metric | Pre-launch | Post-launch |
|--------|------------|-------------|
| Validation | Signups, survey responses | Active users |
| Revenue | Pre-sales, deposits | MRR, conversion |
| Engagement | Click-through, time on page | Retention, NPS |
| Learning | Interview insights | Feature requests |

## Common Pitfalls

**Problem:** MVP scope keeps growing
**Solution:** Write down launch features. Any addition must remove something. Use time-boxing.

**Problem:** No users after launch
**Solution:** Launch is not the end—it's the beginning. Personally invite 100 people. Post everywhere.

**Problem:** Users don't convert to paid
**Solution:** Too much free? Too little value? Wrong audience? Interview churned users.

**Problem:** Taking too long to build
**Solution:** Cut features aggressively. Use no-code if engineering is the bottleneck. Ship half of what you planned.

## Related Skills

- `@startup-analyst` - For market validation
- `@startup-pitch-deck` - For investor materials
- `@senior-software-architect` - For technical decisions
- `@saas-product-developer` - For SaaS-specific patterns
- `@no-code-builder` - For no-code MVPs
