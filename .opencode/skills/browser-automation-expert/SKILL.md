---
name: browser-automation-expert
description: "Expert browser automation including Puppeteer, Playwright, headless browsers, and JavaScript-rendered content scraping"
---

# Browser Automation Expert

## Overview

This skill helps you automate browser interactions for scraping dynamic websites, testing, and automating web tasks.

## When to Use This Skill

- Use when scraping JavaScript-rendered sites
- Use when automating browser tasks
- Use when handling dynamic content
- Use when dealing with SPAs

## How It Works

### Step 1: When to Use Browser Automation

```
USE BROWSER AUTOMATION WHEN:
├── Content is rendered by JavaScript
├── Need to interact with page (click, scroll, type)
├── Need to handle authentication flows
├── Content loads dynamically (infinite scroll)
├── Need screenshots or PDFs
└── Need to bypass basic bot detection

USE SIMPLE HTTP REQUESTS WHEN:
├── Content is in static HTML
├── No JavaScript needed
├── Speed is critical
└── Less resource usage needed
```

### Step 2: Playwright (Recommended)

```typescript
import { chromium, Browser, Page } from 'playwright';

class PlaywrightScraper {
  private browser: Browser | null = null;

  async init(): Promise<void> {
    this.browser = await chromium.launch({
      headless: true,
      // Use headed mode for debugging
      // headless: false,
      // slowMo: 100,
    });
  }

  async close(): Promise<void> {
    await this.browser?.close();
  }

  async scrapeProducts(url: string): Promise<Product[]> {
    const page = await this.browser!.newPage();
    
    try {
      // Navigate and wait for content
      await page.goto(url, { waitUntil: 'networkidle' });
      
      // Wait for specific element
      await page.waitForSelector('.product-grid');
      
      // Extract data
      const products = await page.evaluate(() => {
        const items = document.querySelectorAll('.product-card');
        return Array.from(items).map(item => ({
          title: item.querySelector('.title')?.textContent?.trim() || '',
          price: item.querySelector('.price')?.textContent?.trim() || '',
          image: item.querySelector('img')?.src || '',
        }));
      });
      
      return products;
    } finally {
      await page.close();
    }
  }

  async handleInfiniteScroll(url: string): Promise<any[]> {
    const page = await this.browser!.newPage();
    
    await page.goto(url);
    
    let previousHeight = 0;
    let items: any[] = [];
    
    while (true) {
      // Scroll to bottom
      await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
      
      // Wait for new content
      await page.waitForTimeout(2000);
      
      // Check if we've reached the bottom
      const currentHeight = await page.evaluate(() => document.body.scrollHeight);
      if (currentHeight === previousHeight) break;
      previousHeight = currentHeight;
      
      // Extract items
      const newItems = await page.evaluate(() => {
        return Array.from(document.querySelectorAll('.item')).map(el => ({
          text: el.textContent,
        }));
      });
      items = newItems;
    }
    
    await page.close();
    return items;
  }

  async fillFormAndSubmit(url: string, data: FormData): Promise<void> {
    const page = await this.browser!.newPage();
    
    await page.goto(url);
    
    // Fill form fields
    await page.fill('#email', data.email);
    await page.fill('#password', data.password);
    
    // Click submit and wait for navigation
    await Promise.all([
      page.waitForNavigation(),
      page.click('button[type="submit"]'),
    ]);
    
    // Verify success
    const successMessage = await page.textContent('.success-message');
    console.log('Result:', successMessage);
    
    await page.close();
  }

  async takeScreenshot(url: string, path: string): Promise<void> {
    const page = await this.browser!.newPage();
    await page.goto(url);
    await page.screenshot({ path, fullPage: true });
    await page.close();
  }

  async generatePDF(url: string, path: string): Promise<void> {
    const page = await this.browser!.newPage();
    await page.goto(url);
    await page.pdf({ path, format: 'A4' });
    await page.close();
  }
}

// Usage
const scraper = new PlaywrightScraper();
await scraper.init();

const products = await scraper.scrapeProducts('https://example.com/products');
console.log(products);

await scraper.close();
```

### Step 3: Puppeteer (Node.js)

```typescript
import puppeteer, { Browser, Page } from 'puppeteer';

class PuppeteerScraper {
  private browser: Browser | null = null;

  async init(): Promise<void> {
    this.browser = await puppeteer.launch({
      headless: 'new',
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
      ],
    });
  }

  async scrapeWithRetry(url: string, maxRetries = 3): Promise<any> {
    let lastError: Error | null = null;
    
    for (let i = 0; i < maxRetries; i++) {
      try {
        const page = await this.browser!.newPage();
        
        // Set viewport
        await page.setViewport({ width: 1920, height: 1080 });
        
        // Set extra headers
        await page.setExtraHTTPHeaders({
          'Accept-Language': 'en-US,en;q=0.9',
        });
        
        // Block unnecessary resources for speed
        await page.setRequestInterception(true);
        page.on('request', (req) => {
          if (['image', 'stylesheet', 'font'].includes(req.resourceType())) {
            req.abort();
          } else {
            req.continue();
          }
        });
        
        await page.goto(url, { waitUntil: 'domcontentloaded' });
        
        const data = await page.evaluate(() => {
          // Extract data here
          return { /* ... */ };
        });
        
        await page.close();
        return data;
        
      } catch (error) {
        lastError = error as Error;
        await new Promise(r => setTimeout(r, 2000 * (i + 1)));
      }
    }
    
    throw lastError;
  }

  async handlePopups(url: string): Promise<void> {
    const page = await this.browser!.newPage();
    
    // Handle dialog boxes
    page.on('dialog', async dialog => {
      console.log('Dialog:', dialog.message());
      await dialog.accept();
    });
    
    await page.goto(url);
    
    // Close cookie banner if exists
    try {
      await page.click('.cookie-accept', { timeout: 3000 });
    } catch {
      // No cookie banner
    }
    
    // Close popup if exists
    try {
      await page.click('.popup-close', { timeout: 3000 });
    } catch {
      // No popup
    }
    
    await page.close();
  }
}
```

### Step 4: Handling Authentication

```typescript
async function loginAndScrape(credentials: Credentials): Promise<any> {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  // Login
  await page.goto('https://example.com/login');
  await page.fill('#email', credentials.email);
  await page.fill('#password', credentials.password);
  await page.click('button[type="submit"]');
  
  // Wait for login to complete
  await page.waitForURL('**/dashboard');
  
  // Save authentication state for reuse
  await context.storageState({ path: 'auth.json' });
  
  // Now scrape authenticated content
  await page.goto('https://example.com/protected-data');
  const data = await page.evaluate(() => {
    return document.querySelector('.data')?.textContent;
  });
  
  await browser.close();
  return data;
}

// Reuse authentication
async function scrapeWithSavedAuth(): Promise<any> {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    storageState: 'auth.json', // Reuse saved session
  });
  
  const page = await context.newPage();
  await page.goto('https://example.com/protected-data');
  
  // Already logged in!
  const data = await page.evaluate(() => { /* ... */ });
  
  await browser.close();
  return data;
}
```

### Step 5: Parallel Scraping

```typescript
import { chromium, Browser } from 'playwright';
import pLimit from 'p-limit';

async function scrapeInParallel(urls: string[], concurrency = 5): Promise<any[]> {
  const browser = await chromium.launch();
  const limit = pLimit(concurrency);
  
  const scrapeOne = async (url: string) => {
    const page = await browser.newPage();
    try {
      await page.goto(url, { timeout: 30000 });
      const data = await page.evaluate(() => {
        return {
          title: document.title,
          content: document.body.textContent?.slice(0, 1000),
        };
      });
      return { url, ...data };
    } catch (error) {
      return { url, error: (error as Error).message };
    } finally {
      await page.close();
    }
  };
  
  const results = await Promise.all(
    urls.map(url => limit(() => scrapeOne(url)))
  );
  
  await browser.close();
  return results;
}

// Usage
const urls = [
  'https://example.com/page1',
  'https://example.com/page2',
  'https://example.com/page3',
  // ... many more
];

const results = await scrapeInParallel(urls, 5);
```

## Best Practices

### ✅ Do This

- ✅ Use headless mode for production
- ✅ Set realistic viewport sizes
- ✅ Handle timeouts gracefully
- ✅ Block unnecessary resources
- ✅ Use context isolation
- ✅ Close pages and browsers

### ❌ Avoid This

- ❌ Don't run too many concurrent browsers
- ❌ Don't forget to handle popups
- ❌ Don't ignore memory leaks
- ❌ Don't skip error handling

## Related Skills

- `@web-scraping-specialist` - Data extraction
- `@playwright-specialist` - E2E testing
