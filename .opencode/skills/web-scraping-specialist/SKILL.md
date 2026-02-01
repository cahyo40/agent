---
name: web-scraping-specialist
description: "Expert web scraping including data extraction, crawling, parsing, rate limiting, and ethical scraping practices"
---

# Web Scraping Specialist

## Overview

Build robust web scrapers using Python with BeautifulSoup, Scrapy, and Selenium for data extraction with ethical practices.

## When to Use This Skill

- Use when extracting web data
- Use when building scrapers/crawlers
- Use when parsing HTML/JSON
- Use when automating data collection

## How It Works

### Step 1: BeautifulSoup Basics

```python
import requests
from bs4 import BeautifulSoup

def scrape_page(url: str) -> dict:
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    response = requests.get(url, headers=headers, timeout=10)
    response.raise_for_status()
    
    soup = BeautifulSoup(response.content, 'lxml')
    
    # Extract data
    title = soup.find('h1').text.strip()
    paragraphs = [p.text.strip() for p in soup.find_all('p')]
    links = [a['href'] for a in soup.find_all('a', href=True)]
    
    return {
        'title': title,
        'paragraphs': paragraphs,
        'links': links
    }
```

### Step 2: Scrapy Spider

```python
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
    }
    
    def parse(self, response):
        for product in response.css('.product-card'):
            yield {
                'name': product.css('h2::text').get(),
                'price': product.css('.price::text').get(),
                'url': product.css('a::attr(href)').get(),
            }
        
        # Follow pagination
        next_page = response.css('a.next::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)
```

### Step 3: Async Scraping

```python
import asyncio
import aiohttp
from bs4 import BeautifulSoup

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def scrape_all(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for url in urls]
        pages = await asyncio.gather(*tasks)
        
        results = []
        for html in pages:
            soup = BeautifulSoup(html, 'lxml')
            results.append({'title': soup.title.string})
        
        return results
```

### Step 4: Selenium for Dynamic Content

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def scrape_dynamic(url: str):
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    
    driver = webdriver.Chrome(options=options)
    driver.get(url)
    
    # Wait for dynamic content
    wait = WebDriverWait(driver, 10)
    element = wait.until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '.dynamic-content'))
    )
    
    data = element.text
    driver.quit()
    return data
```

## Best Practices

### ✅ Do This

- ✅ Respect robots.txt
- ✅ Add delays between requests
- ✅ Rotate User-Agents
- ✅ Handle errors gracefully
- ✅ Cache responses when possible

### ❌ Avoid This

- ❌ Don't overwhelm servers
- ❌ Don't ignore rate limits
- ❌ Don't scrape personal data
- ❌ Don't violate ToS

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@browser-automation-expert` - Browser automation
