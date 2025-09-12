import { PlaywrightCrawler, Dataset } from 'crawlee';

async function main() {
    const startUrls = [
        'https://ipchicken.com',
    ];

    await crawler.run(startUrls);
}

const crawler = new PlaywrightCrawler({
    requestHandler: async ({ request, page, enqueueLinks, log }) => {
        const basic = await page.locator('p[align=center] b').innerText();

        const ip = basic.split('\n')[0]

        log.info(`Your ip is: '${ip}'`);
    },
    // maxRequestsPerCrawl: 50,
    launchContext: {
        launchOptions: {
            executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH,
        },
    },
    headless: true,
});

await main();
