import { zoneData } from '../Schema/gymSchema.js'; // Ensure correct import

const updateZone = async (id, { place_name, last_count }) => {
    try {
        const updateFields = {};
        if (place_name) updateFields.place_name = place_name;
        if (last_count) updateFields.last_count = last_count;

        const result = await zoneData.findOneAndUpdate(
            { _id: id }, // Search condition
            updateFields, // Fields to update
            { new: true } // Return the updated document
        );

        if (!result) {
            throw new Error('Data not found');
        }

        console.log('Updated object:', result);
        return result;
    } catch (error) {
        console.error('Failed to update zone:', error.message);
        throw error;
    }
};

export { updateZone };