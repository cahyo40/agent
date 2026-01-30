---
name: web-scraping-specialist
description: "Expert web scraping including data extraction, crawling, parsing, rate limiting, and ethical scraping practices"
---

# Web Scraping Specialist

## Overview

This skill helps you extract data from websites efficiently and ethically using various scraping tools and techniques.

## When to Use This Skill

- Use when extracting data from websites
- Use when building web crawlers
- Use when parsing HTML/XML
- Use when automating data collection

## How It Works

### Step 1: Scraping Strategy

```
WEB SCRAPING DECISION TREE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  Is there a public API?                                        │
│  ├── YES → Use API (preferred)                                 │
│  └── NO → Continue                                             │
│                                                                 │
│  Is content static HTML?                                        │
│  ├── YES → Use requests + BeautifulSoup/Cheerio                │
│  └── NO (JavaScript rendered) → Use Playwright/Puppeteer       │
│                                                                 │
│  Need to scrape many pages?                                     │
│  ├── YES → Use Scrapy (Python) or custom crawler               │
│  └── NO → Simple script is fine                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Python with BeautifulSoup

```python
import requests
from bs4 import BeautifulSoup
from time import sleep
import csv

class ProductScraper:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml',
            'Accept-Language': 'en-US,en;q=0.9',
        })
    
    def fetch_page(self, url: str) -> BeautifulSoup:
        """Fetch and parse a page with rate limiting."""
        response = self.session.get(url, timeout=10)
        response.raise_for_status()
        sleep(1)  # Be respectful - 1 second delay
        return BeautifulSoup(response.text, 'lxml')
    
    def parse_product(self, soup: BeautifulSoup) -> dict:
        """Extract product data from page."""
        return {
            'title': soup.select_one('h1.product-title').get_text(strip=True),
            'price': soup.select_one('.price').get_text(strip=True),
            'description': soup.select_one('.description').get_text(strip=True),
            'image': soup.select_one('.product-image img')['src'],
            'rating': soup.select_one('.rating')['data-value'],
        }
    
    def scrape_listing(self, url: str) -> list[str]:
        """Get all product URLs from listing page."""
        soup = self.fetch_page(url)
        links = soup.select('a.product-link')
        return [self.base_url + link['href'] for link in links]
    
    def scrape_all(self, listing_url: str) -> list[dict]:
        """Scrape all products from listing."""
        product_urls = self.scrape_listing(listing_url)
        products = []
        
        for url in product_urls:
            try:
                soup = self.fetch_page(url)
                product = self.parse_product(soup)
                product['url'] = url
                products.append(product)
                print(f"Scraped: {product['title']}")
            except Exception as e:
                print(f"Error scraping {url}: {e}")
        
        return products
    
    def save_to_csv(self, products: list[dict], filename: str):
        """Save products to CSV file."""
        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=products[0].keys())
            writer.writeheader()
            writer.writerows(products)

# Usage
scraper = ProductScraper('https://example.com')
products = scraper.scrape_all('/products')
scraper.save_to_csv(products, 'products.csv')
```

### Step 3: Scrapy for Large Scale

```python
# products/spiders/product_spider.py
import scrapy
from scrapy.crawler import CrawlerProcess

class ProductSpider(scrapy.Spider):
    name = 'products'
    allowed_domains = ['example.com']
    start_urls = ['https://example.com/products']
    
    custom_settings = {
        'CONCURRENT_REQUESTS': 2,
        'DOWNLOAD_DELAY': 1,
        'ROBOTSTXT_OBEY': True,
        'USER_AGENT': 'MyBot/1.0 (+https://mysite.com/bot)',
    }
    
    def parse(self, response):
        """Parse listing page."""
        for product_link in response.css('a.product-link::attr(href)'):
            yield response.follow(product_link, self.parse_product)
        
        # Follow pagination
        next_page = response.css('a.next-page::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)
    
    def parse_product(self, response):
        """Parse product page."""
        yield {
            'title': response.css('h1.title::text').get(),
            'price': response.css('.price::text').get(),
            'description': response.css('.description::text').get(),
            'url': response.url,
        }

# Run spider
if __name__ == '__main__':
    process = CrawlerProcess({
        'FEED_FORMAT': 'json',
        'FEED_URI': 'products.json',
    })
    process.crawl(ProductSpider)
    process.start()
```

### Step 4: Node.js with Cheerio

```typescript
import axios from 'axios';
import * as cheerio from 'cheerio';
import { writeFileSync } from 'fs';

interface Product {
  title: string;
  price: string;
  url: string;
}

class Scraper {
  private baseUrl: string;
  
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async fetchPage(url: string): Promise<cheerio.CheerioAPI> {
    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      },
    });
    
    // Rate limiting
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return cheerio.load(response.data);
  }

  async scrapeProducts(listingUrl: string): Promise<Product[]> {
    const $ = await this.fetchPage(listingUrl);
    const products: Product[] = [];

    $('.product-card').each((_, element) => {
      products.push({
        title: $(element).find('.title').text().trim(),
        price: $(element).find('.price').text().trim(),
        url: this.baseUrl + $(element).find('a').attr('href'),
      });
    });

    return products;
  }
}

// Usage
const scraper = new Scraper('https://example.com');
const products = await scraper.scrapeProducts('/products');
writeFileSync('products.json', JSON.stringify(products, null, 2));
```

### Step 5: Handling Anti-Scraping

```python
import random
from fake_useragent import UserAgent
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

class RobustScraper:
    def __init__(self):
        self.session = requests.Session()
        
        # Retry strategy
        retry = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry)
        self.session.mount('http://', adapter)
        self.session.mount('https://', adapter)
        
        # Rotating user agents
        self.ua = UserAgent()
    
    def get_headers(self) -> dict:
        return {
            'User-Agent': self.ua.random,
            'Accept': 'text/html,application/xhtml+xml',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
        }
    
    def fetch(self, url: str, proxy: str = None) -> str:
        """Fetch with rotating headers and optional proxy."""
        proxies = {'http': proxy, 'https': proxy} if proxy else None
        
        response = self.session.get(
            url,
            headers=self.get_headers(),
            proxies=proxies,
            timeout=15,
        )
        
        # Random delay (1-3 seconds)
        sleep(random.uniform(1, 3))
        
        return response.text
```

## Best Practices

### ✅ Do This

- ✅ Check robots.txt first
- ✅ Add delays between requests
- ✅ Use rotating user agents
- ✅ Handle errors gracefully
- ✅ Cache responses when possible
- ✅ Identify yourself in User-Agent

### ❌ Avoid This

- ❌ Don't ignore rate limits
- ❌ Don't scrape login-required content without permission
- ❌ Don't overload servers
- ❌ Don't violate ToS

## Related Skills

- `@senior-python-developer` - Python scripting
- `@senior-data-engineer` - Data pipelines
