---
name: cro-specialist
description: "Expert Conversion Rate Optimization including A/B testing, landing page optimization, funnel analysis, and user behavior analytics"
---

# CRO Specialist

## Overview

This skill helps you optimize conversion rates through A/B testing, landing page optimization, funnel analysis, and data-driven improvements.

## When to Use This Skill

- Use when optimizing landing pages
- Use when setting up A/B tests
- Use when analyzing conversion funnels

## How It Works

### Step 1: Conversion Audit Framework

```markdown
## Landing Page Audit Checklist

### Above the Fold
- [ ] Clear, benefit-driven headline
- [ ] Supporting subheadline
- [ ] Hero image or video
- [ ] Primary CTA visible
- [ ] Trust indicators (logos, badges)

### Value Proposition
- [ ] Benefits > Features messaging
- [ ] Addresses main pain points
- [ ] Unique differentiator clear
- [ ] Social proof present

### Call-to-Action
- [ ] Action-oriented button text
- [ ] Contrasting button color
- [ ] Single primary CTA focus
- [ ] Reduced friction (minimal fields)

### Trust & Credibility
- [ ] Customer testimonials
- [ ] Case studies / results
- [ ] Trust badges (security, awards)
- [ ] Money-back guarantee

### Technical
- [ ] Mobile responsive
- [ ] Page load < 3 seconds
- [ ] No broken links/images
- [ ] SSL certificate active
```

### Step 2: A/B Testing Setup

```javascript
// Example: A/B Test with Google Optimize or custom
const ABTest = {
  name: 'hero_headline_test',
  variants: [
    {
      id: 'control',
      weight: 50,
      headline: 'Build faster with our platform',
    },
    {
      id: 'treatment_a',
      weight: 50,
      headline: 'Ship 10x faster - no code required',
    },
  ],
  
  // Minimum sample size calculation
  sampleSize: {
    baselineConversion: 0.03, // 3%
    minimumDetectableEffect: 0.20, // 20% relative lift
    statisticalPower: 0.80,
    significanceLevel: 0.05,
    calculatedSamplePerVariant: 4900,
  },
  
  // Success metrics
  primaryMetric: 'signup_completed',
  secondaryMetrics: ['cta_clicked', 'pricing_viewed'],
  
  // Duration
  estimatedDuration: '2-4 weeks',
};

// Tracking implementation
function trackConversion(testName, variant, event) {
  analytics.track('ab_test_conversion', {
    test_name: testName,
    variant_id: variant,
    event: event,
    timestamp: new Date().toISOString(),
  });
}
```

### Step 3: Funnel Analysis

```markdown
## Conversion Funnel Analysis

### Current Funnel Performance
| Stage | Visitors | Conversion | Drop-off |
|-------|----------|------------|----------|
| Landing Page | 10,000 | 100% | - |
| CTA Click | 2,500 | 25% | 75% |
| Signup Start | 1,500 | 15% | 40% |
| Signup Complete | 750 | 7.5% | 50% |
| Activation | 300 | 3% | 60% |
| Paid Conversion | 75 | 0.75% | 75% |

### Priority Optimization Areas
1. **Landing → CTA Click (75% drop-off)**
   - Hypothesis: Headline not compelling
   - Test: New value proposition
   - Expected lift: 20-30%

2. **Signup Complete (50% drop-off)**
   - Hypothesis: Too many form fields
   - Test: Progressive profiling
   - Expected lift: 15-25%

3. **Activation (60% drop-off)**
   - Hypothesis: Unclear next steps
   - Test: Onboarding wizard
   - Expected lift: 30-40%
```

### Step 4: CRO Experiments Backlog

```markdown
## Experiment Prioritization (ICE Score)

| Experiment | Impact | Confidence | Ease | ICE Score |
|------------|--------|------------|------|-----------|
| Simplify signup form | 8 | 7 | 9 | 168 |
| Add video testimonial | 7 | 6 | 8 | 126 |
| New pricing page layout | 9 | 5 | 5 | 112 |
| Exit-intent popup | 6 | 7 | 8 | 112 |
| Social proof counter | 5 | 8 | 9 | 108 |

### Experiment Template

**Experiment Name**: [Name]

**Hypothesis**: If we [change], then [metric] will improve by [X%] because [reasoning].

**Variants**:
- Control: Current version
- Treatment: [Description of change]

**Primary Metric**: [Conversion event]
**Secondary Metrics**: [Supporting metrics]

**Sample Size Required**: [Calculated number]
**Expected Duration**: [X weeks]

**Success Criteria**: 
- Statistical significance: 95%
- Minimum lift: 10%
```

### Step 5: Form Optimization

```html
<!-- Optimized Form Example -->
<form class="signup-form">
  <!-- Progressive disclosure - Step 1 -->
  <div class="form-step active" data-step="1">
    <label>Work Email</label>
    <input type="email" required placeholder="you@company.com">
    <button type="button" class="next-step">Continue</button>
    <p class="microcopy">No credit card required</p>
  </div>
  
  <!-- Step 2 - Only shown after email -->
  <div class="form-step" data-step="2">
    <label>Create Password</label>
    <input type="password" required>
    <div class="password-strength"></div>
    <button type="submit">Start Free Trial</button>
  </div>
</form>

<style>
.signup-form {
  max-width: 400px;
  /* Reduce cognitive load */
}

.form-step:not(.active) {
  display: none;
}

button[type="submit"] {
  background: #22c55e; /* Green = positive action */
  color: white;
  padding: 16px 32px;
  font-size: 18px;
  width: 100%;
}

.microcopy {
  font-size: 14px;
  color: #666;
  margin-top: 8px;
}
</style>
```

## Best Practices

### ✅ Do This

- ✅ Test one variable at a time
- ✅ Wait for statistical significance
- ✅ Document all experiments
- ✅ Focus on high-impact pages first

### ❌ Avoid This

- ❌ Don't end tests early
- ❌ Don't test tiny changes
- ❌ Don't ignore mobile users
- ❌ Don't optimize vanity metrics

## Related Skills

- `@analytics-engineer` - Tracking setup
- `@senior-ui-ux-designer` - UX improvements
