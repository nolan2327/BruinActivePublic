import chromium from '@sparticuz/chromium';
import puppeteer from 'puppeteer-core';

export async function jwcScrape() {
    console.log("Scraping JWC data...");

    const executablePath = await chromium.executablePath();

    const browser = await puppeteer.launch({
        args: chromium.args,
        defaultViewport: chromium.defaultViewport,
        executablePath: executablePath,
        headless: chromium.headless,
    })

    console.log("Puppeteer successfully launched...");

    const page = await browser.newPage();

    // Navigate to the page
    await page.goto('https://recreation.ucla.edu/facilities/jwc', { waitUntil: 'domcontentloaded' });

    console.log("At page...");

    // Wait for the iframe to load and select it
    await page.waitForSelector('iframe', { visible: true });
    const iframeElement = await page.$('iframe');
    const iframe = await iframeElement.contentFrame();

    // Wait for .barChart elements inside the iframe
    await iframe.waitForSelector('.barChart', { timeout: 60000 });

    // Scrape data from each .barChart
    const occupancyData = await iframe.evaluate(() => {
        const zones = Array.from(document.querySelectorAll('.barChart'));
        return zones.map(zone => {
            const name = zone.childNodes[0].textContent.trim(); // Extract zone name
            const lastCount = zone.innerHTML.match(/Last Count:\s*(\d+)/)?.[1] || 'N/A'; // Extract last count
            const updated = zone.innerHTML.match(/Updated:\s*([\d/:\sAPM]+)/)?.[1] || 'N/A'; // Extract updated time
            const percentage = zone.querySelector('.barChart__value')?.textContent.trim() || 'N/A'; // Extract percentage

            return { name, lastCount, updated, percentage };
        });
    });

    await browser.close();

    console.log("Scraped JWC data...");

    return occupancyData;
}