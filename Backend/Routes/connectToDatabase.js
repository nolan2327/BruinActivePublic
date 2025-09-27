import mongoose from 'mongoose';

// Ensure that the correct environment variable is being used
const MONGODB_URI = process.env.MONGODB_URI;

console.log('\nMongoDB URI:', process.env.MONGODB_URI);

let cachedConnection = null;

// MongoDB connection logic
const connectDatabase = async () => {
    try {
        if (!cachedConnection) {
            cachedConnection = mongoose.connect(MONGODB_URI);
            await cachedConnection;
            console.log('Connected to MongoDB');
        }
        return cachedConnection;
    } catch (error) {
        console.error('MongoDB connection error:', error.message);
        throw new Error('Failed to connect to MongoDB');
    }
};

export { connectDatabase };