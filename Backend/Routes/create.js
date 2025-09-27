import mongoose from 'mongoose';
import { scrape } from '../Scrapers/scraper.js';
import { GymData } from '../Schema/gymSchema.js';

const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const createZone = async () => {
    const bfitData = await scrape("https://recreation.ucla.edu/facilities/bfit", "BFIT");
    const jwcData = await scrape("https://recreation.ucla.edu/facilities/jwc", "JWC");
    const krecData = await scrape("https://recreation.ucla.edu/facilities/krec", "KREC");

    if (!bfitData.length) {
        console.error("No data returned from bfitScrape");
        return;
    }
    if (!jwcData.length) {
        console.error("No data returned from jwcScrape");
        return;
    }
    if(!krecData.length) {
        console.error("No data returned from krecScrape");
        return;
    }

    const transformData = (data) =>
        data.map(zone => ({
            place_name: zone.name,
            population: isNaN(parseInt(zone.lastCount, 10)) ? 0 : parseInt(zone.lastCount, 10),
            percentage: isNaN(parseInt(zone.percentage.replace('%', ''), 10)) ? 0 : parseInt(zone.percentage.replace('%', ''), 10),
        })
    );

    const zones_bfit = transformData(bfitData);
    const zones_jwc = transformData(jwcData);
    const zones_krec = transformData(krecData);

    // Sum total population
    const totalPopulation_bfit = zones_bfit.reduce((sum, zone) => sum + zone.population, 0);
    const totalPopulation_jwc = zones_jwc.reduce((sum, zone) => sum + zone.population, 0);
    const totalPopulation_krec = zones_krec.reduce((sum, zone) => sum + zone.population, 0);

    console.log(`Total population for BFit: ${totalPopulation_bfit}`);
    console.log(`Total population for JWC: ${totalPopulation_jwc}`);
    console.log(`Total population for KREC: ${totalPopulation_krec}`);

    // Sum total percentage
    const totalPercentage_bfit = Math.round(zones_bfit.reduce((sum, zone) => sum + zone.percentage, 0) / zones_bfit.length);
    const totalPercentage_jwc = Math.round(zones_jwc.reduce((sum, zone) => sum + zone.percentage, 0) / zones_jwc.length);
    const totalPercentage_krec = Math.round(zones_krec.reduce((sum, zone) => sum + zone.percentage, 0) / zones_krec.length);

    console.log(`Total percentage for BFit: ${totalPercentage_bfit}`);
    console.log(`Total percentage for JWC: ${totalPercentage_jwc}`);
    console.log(`Total percentage for KREC: ${totalPercentage_krec}`);

    // Create a function to store data in multiple collections
    // Includes feature to avoid adding duplicates to database(s)
    const saveToMultipleCollections = async (data, collectionNames) => {
        for (const collectionName of collectionNames) {
            const DynamicModel = mongoose.model(collectionName, GymData.schema, collectionName);
    
            // Find the most recent document
            const latestEntry = await DynamicModel.findOne().sort({ time_collected: -1 });

            // console.log(`Latest entry:`, latestEntry);
            // console.log(`Latest entry last_updated:`, latestEntry?.last_updated);
            // console.log(`New data last_updated:`, data.last_updated);

            if (latestEntry && latestEntry.last_updated === data.last_updated) {
                console.log('Skipped inserting duplicate data for collection: ', collectionName);
                continue; // Skip insertion
            }
    
            // Save new data if different
            const doc = new DynamicModel(data);
            await doc.save();
            console.log('Saved to collection: ', collectionName);
        }
    };

    // Setting time to ISODate to PST time as well as human-readable time
    // NOTE: for optimization, eliminate human-readable time
    const dateObjectPST = new Date(new Date().toLocaleString("en-US", { timeZone: "America/Los_Angeles" }));

    // Data object to store
    const gymDataBFIT = {
        facility: 1,  // 1 for BFit, 2 for Wooden
        total_population: totalPopulation_bfit,
        total_percentage: totalPercentage_bfit,
        time_collected: dateObjectPST, // ISODate in PST not UTC,
        last_updated: bfitData[0]?.updated || "-1",
        weekday: weekdays[dateObjectPST.getDay()],
        zones: zones_bfit,
    };

    // Save the same data in multiple collections
    // await saveToMultipleCollections(gymData, ['bfit_gym', 'backup_bfit_gym']);
    await saveToMultipleCollections(gymDataBFIT, ['clean_backup_bfit']);

    // Repeat for JWC
    const gymDataJwc = {
        facility: 2,  // 1 for BFit, 2 for Wooden
        total_population: totalPopulation_jwc,
        total_percentage: totalPercentage_jwc,
        time_collected: dateObjectPST, // ISODate in PST not UTC,
        last_updated: jwcData[0]?.updated || "-1",
        weekday: weekdays[dateObjectPST.getDay()],
        zones: zones_jwc,
    };

    // await saveToMultipleCollections(gymDataJwc, ['jwc_gym', 'backup_jwc_gym']);
    await saveToMultipleCollections(gymDataJwc, ['clean_backup_jwc']);

    const gymDataKrec = { 
        facility: 3,  // 1 for BFit, 2 for Wooden, 3 for KREC
        total_population: totalPopulation_krec,
        total_percentage: totalPercentage_krec,
        time_collected: dateObjectPST, // ISODate in PST not UTC,
        last_updated: krecData[0]?.updated || "-1",
        weekday: weekdays[dateObjectPST.getDay()],
        zones: zones_krec,
    }

    await saveToMultipleCollections(gymDataKrec, ['clean_backup_krec']);

    return { gymDataBFIT, gymDataJwc, gymDataKrec };
};

export { createZone };