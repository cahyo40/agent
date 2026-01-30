---
name: email-sequence-specialist
description: "Expert email sequence and drip campaign design including automation flows, nurture sequences, and lifecycle emails"
---

# Email Sequence Specialist

## Overview

Design high-converting email sequences for onboarding, sales, and retention.

## When to Use This Skill

- Use when building email automation
- Use when designing drip campaigns

## How It Works

### Step 1: Sequence Types

```markdown
## Common Email Sequences

### Welcome Sequence (5-7 emails)
- Day 0: Welcome + quick win
- Day 1: Core value/benefit
- Day 3: Feature highlight
- Day 5: Social proof/testimonials
- Day 7: CTA or next steps

### Sales Sequence (5-10 emails)
- Email 1: Pain point identification
- Email 2: Solution introduction
- Email 3: Benefits deep-dive
- Email 4: Case study/results
- Email 5: Objection handling
- Email 6: Urgency/scarcity
- Email 7: Final CTA

### Re-engagement Sequence (3-5 emails)
- Email 1: "We miss you"
- Email 2: What's new
- Email 3: Special offer
- Email 4: Last chance
- Email 5: Breakup email
```

### Step 2: Email Structure

```markdown
## High-Converting Email Format

### Subject Line (< 50 chars)
- Create curiosity
- Use numbers
- Personalize with name

### Preheader (40-90 chars)
- Complements subject
- Adds context

### Opening Hook (1-2 lines)
- Personal connection
- Ask a question
- Bold statement

### Body (3-5 paragraphs)
- One idea per email
- Short paragraphs
- Use bullet points
- Include story/example

### CTA (Single, clear)
- Action-oriented button
- Above the fold + end
- Contrasting color

### PS Line
- Reinforce CTA
- Add urgency
- Second hook
```

### Step 3: Automation Flow

```javascript
// Email automation logic
const welcomeSequence = {
  trigger: 'user.signup',
  emails: [
    {
      delay: '0h',
      template: 'welcome',
      subject: 'Welcome to {{company}}! 🎉',
      condition: null
    },
    {
      delay: '24h',
      template: 'quick_win',
      subject: "Your first {{feature}} in 5 minutes",
      condition: 'user.hasNotCompleted("onboarding")'
    },
    {
      delay: '72h',
      template: 'feature_highlight',
      subject: "Most users don't know this trick",
      condition: null
    },
    {
      delay: '120h',
      template: 'case_study',
      subject: "How {{customer}} achieved {{result}}",
      condition: null
    },
    {
      delay: '168h',
      template: 'upgrade_cta',
      subject: "Ready to level up?",
      condition: 'user.plan === "free"'
    }
  ]
};

// Send email function
async function sendSequenceEmail(user, email) {
  if (email.condition && !evaluateCondition(user, email.condition)) {
    return { skipped: true };
  }
  
  await sendEmail({
    to: user.email,
    template: email.template,
    subject: interpolate(email.subject, user),
    data: { user, company: config.company }
  });
}
```

### Step 4: Subject Line Formulas

```markdown
## Proven Subject Lines

### Curiosity Gap
- "The one thing nobody tells you about {{topic}}"
- "This changed everything for me"
- "I made a mistake..."

### How-to
- "How to {{achieve result}} in {{timeframe}}"
- "The simple way to {{benefit}}"

### Numbers
- "5 ways to {{achieve goal}}"
- "3 mistakes killing your {{metric}}"

### Personal
- "{{name}}, quick question"
- "A gift for you, {{name}}"

### Urgency
- "Ends tonight"
- "Last chance: {{offer}}"
- "24 hours left"
```

### Step 5: Metrics to Track

```markdown
## Key Email Metrics

| Metric | Good | Great | Excellent |
|--------|------|-------|-----------|
| Open Rate | 20% | 30% | 40%+ |
| Click Rate | 2% | 4% | 6%+ |
| Unsubscribe | < 0.5% | < 0.3% | < 0.1% |
| Reply Rate | 1% | 3% | 5%+ |

## Improve Metrics

### Low Opens
- Test subject lines
- Clean email list
- Send time optimization

### Low Clicks
- Clearer CTA
- Better copy
- Fewer links (1-2)

### High Unsubscribes
- Segment audience
- Reduce frequency
- More value, less selling
```

## Best Practices

- ✅ One CTA per email
- ✅ Mobile-first design
- ✅ A/B test subject lines
- ❌ Don't email too frequently
- ❌ Don't use spam triggers

## Related Skills

- `@copywriting`
- `@email-developer`
