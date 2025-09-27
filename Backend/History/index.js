// Note: uri is the MongoDB connection string, which should be set in your environment variables.

import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI;

async function connectToDatabase() {
    try {
        const client = await MongoClient.connect(uri);
        return client.db('test');
    } catch (error) {
        console.error('Failed to connect to database', error);
        throw error;
    }
}

async function storeFacilityTrends(db, allFacilityTrends) {
    const trendsCollection = db.collection('facility_history');
    
    // Create a document with the current timestamp
    const storageDocument = {
        timestamp: new Date(),
        facilities: allFacilityTrends
    };

    try {
        // Insert the entire set of trends as a single document
        await trendsCollection.insertOne(storageDocument);
        console.log('Trends stored successfully');
    } catch (error) {
        console.error('Error storing trends:', error);
        throw error;
    }
}

async function aggregateDailyTrends(db, collectionName) {
    const twoWeeksAgo = new Date();
    twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
    twoWeeksAgo.setHours(0, 0, 0, 0);
    const today = new Date();
    today.setHours(23, 59, 59, 999);

    try {
        const trends = await db.collection(collectionName).aggregate([
            {
                $match: {
                    time_collected: {
                        $gte: twoWeeksAgo,
                        $lte: today
                    }
                }
            },
            {
                $group: {
                    _id: {
                        $dateToString: {
                            format: "%Y-%m-%d",
                            date: "$time_collected"
                        }
                    },
                    avgPopulation: { $avg: { $toDouble: "$total_population" } },
                    avgOccupancy: { $avg: { $toDouble: { $ifNull: ["$total_percentage", 0] } } },
                    zones: { $first: "$zones" }
                }
            },
            {
                $set: {
                    avgPopulation: { $round: ["$avgPopulation", 0] },
                    avgOccupancy: { $round: ["$avgOccupancy", 0] }
                }
            },
            { $sort: { "_id": 1 } }
        ]).toArray();

        // Find busiest and quietest days
        const busiestDay = trends.reduce((max, day) =>
            (day.avgPopulation > max.avgPopulation) ? day : max
        );
        const quietestDay = trends.reduce((min, day) =>
            (day.avgPopulation < min.avgPopulation) ? day : min
        );

        // Find busiest zone
        const zoneAverages = {};
        trends.forEach(day => {
            if (day.zones) {
                day.zones.forEach(zone => {
                    if (!zoneAverages[zone.place_name]) {
                        zoneAverages[zone.place_name] = { total: 0, count: 0 };
                    }
                    zoneAverages[zone.place_name].total += zone.population;
                    zoneAverages[zone.place_name].count++;
                });
            }
        });

        const busiestZone = Object.entries(zoneAverages)
            .map(([zoneName, data]) => ({
                zoneName,
                avgPopulation: Math.round(data.total / data.count)
            }))
            .reduce((max, zone) => (zone.avgPopulation > max.avgPopulation ? zone : max), { avgPopulation: 0 });

        return {
            trends,
            busiestDay,
            quietestDay,
            busiestZone
        };
    } catch (error) {
        console.error(`Error aggregating trends for ${collectionName}:`, error);
        return [];
    }
}

export const handler = async (event) => {
    try {
        const db = await connectToDatabase();
        
        const facilities = [
            { id: 1, name: 'BFit', collection: 'clean_backup_bfit' },
            { id: 2, name: 'John Wooden Center', collection: 'clean_backup_jwc' },
            { id: 3, name: 'Kinross', collection: 'clean_backup_krec' }
        ];

        const allFacilityTrends = await Promise.all(
            facilities.map(async (facility) => {
                const dailyTrends = await aggregateDailyTrends(db, facility.collection);
                return {
                    facilityName: facility.name,
                    dailyTrends
                };
            })
        );

        // Store the trends in a new collection
        await storeFacilityTrends(db, allFacilityTrends);

        return {
            statusCode: 200,
            body: JSON.stringify(allFacilityTrends)
        };
    } catch (error) {
        console.error('Lambda function error', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to process trends', details: error.toString() })
        };
    }
};