import mongoose from 'mongoose';

const zoneSchema = new mongoose.Schema({
    place_name: { type: String, },
    population: { type: Number, min: 0, },
    percentage: { type: Number, min: 0, max: 100 }
});

const gymSchema = new mongoose.Schema({
    facility:         { type: Number }, // 1 for BFit, 2 for Wooden
    total_population: { type: Number, min: 0 }, // Sum of population zones
    // time_collected:   { type: String },
    total_percentage:       { type: Number, min: -1, max: 100},
    time_collected:   { type: Date },
    last_updated:     { type: String },
    weekday:          { type: String, },
    zones:            { type: [zoneSchema] }
    /*
      A note on time vs last_updated: time_collected is the time when the data is being posted to the database. 
      The last_updated variable is the time that the gyms gave us from the scraper. 
    */
}, { collection: 'longterm_collection' }); // This will be overridden when saving

const GymData = mongoose.model("GymData", gymSchema);

export { GymData };