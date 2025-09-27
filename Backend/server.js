import mongoose from 'mongoose';
import { createZone } from './Routes/create.js';
import { deleteZone } from './Routes/delete.js';
import { updateZone } from './Routes/update.js';
import { connectDatabase } from './Routes/connectToDatabase.js';

// Lambda handler function
// exports.handler = async (event) => {
export async function handler(event) {
    try {
        const { collectionName, path, httpMethod, queryStringParameters, body } = event;

        // const { collectionName } = event; 
        if (!collectionName) {
            throw new Error('Collection name is required in the event');
        }

        // Connect to MongoDB
        await connectDatabase();

        if (path === '/create' && httpMethod === 'POST') {
            console.log('\nCreating zone....');

            const zone = await createZone();
            // const zoneAlt = await createZoneAlt(collectionName);

            return {
                statusCode: 200,
                body: JSON.stringify({ message: 'Data uploaded successfully', zone }),
            };
        }
        else if(path === '/delete' && httpMethod === 'POST') {
            const { id } = queryStringParameters || {};

            if (!id) {
                return {
                    statusCode: 400,
                    body: JSON.stringify({ message: 'ID is required for deletion' }),
                };
            }

            const result = await deleteZone(id);

            return {
                statusCode: 200,
                body: JSON.stringify({ message: 'Zone deleted successfully', deletedZone: result }),
            };
        }
        else if (path === '/update' && httpMethod === 'POST') {
            const { id } = queryStringParameters || {};

            if (!id) {
                return {
                    statusCode: 400,
                    body: JSON.stringify({ message: 'ID is required for updating the zone' }),
                };
            }

            const updateFields = JSON.parse(body); // Parse the request body for update fields
            const updatedZone = await updateZone(id, updateFields);

            return {
                statusCode: 200,
                body: JSON.stringify({ message: 'Zone updated successfully', updatedZone }),
            };
        }
        

        return {
            statusCode: 404,
            body: JSON.stringify({ message: 'Route not found' }),
        };
    } catch (error) {
        console.error('Error uploading data:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Failed to upload data', error: error.message }),
        };
    }
};