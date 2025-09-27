import chromium from '@sparticuz/chromium';
import puppeteer from 'puppeteer-core';

export async function krecScrape() {
    console.log("Scraping KREC data...");

    const executablePath = await chromium.executablePath();

    const browser = await puppeteer.launch({
        args: chromium.args,
        defaultViewport: chromium.defaultViewport,
        executablePath: executablePath,
        headless: chromium.headless,
    });

    console.log("Puppeteer successfully launched...");

    const page = await browser.newPage();
    await page.goto('https://recreation.ucla.edu/facilities/krec', { waitUntil: 'domcontentloaded' });

    console.log("At page...");

    await page.waitForSelector('iframe', { visible: true });
    const iframeElement = await page.$('iframe');
    const iframe = await iframeElement.contentFrame();

    await iframe.waitForSelector('.barChart', { timeout: 60000 });

    const occupancyData = await iframe.evaluate(() => {
        const zones = Array.from(document.querySelectorAll('.barChart'));
        return zones.map(zone => ({
            name: zone.childNodes[0].textContent.trim(),
            lastCount: zone.querySelector('br:nth-of-type(2)').nextSibling.textContent.trim().replace('Last Count: ', ''),
            updated: zone.querySelector('br:nth-of-type(3)').nextSibling.textContent.trim().replace('Updated: ', ''),
            percentage: zone.querySelector('.barChart__value').textContent.trim(),
        }));
    });

    await browser.close();
    
    console.log("Scraped KREC data...");

    return occupancyData;
}