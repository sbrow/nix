# TopMarket Scraper

A web scraper built with Crawlee for JavaScript.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the scraper:
   ```bash
   npm start
   ```

## Configuration

Edit `src/main.js` to:
- Change the `startUrls` array to target your desired websites
- Modify the `requestHandler` to extract the data you need
- Adjust `maxRequestsPerCrawl` to control crawling limits

## Output

Scraped data is saved to the `storage/datasets/default` directory in JSON format.