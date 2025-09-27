import { gymData } from '../Schema/gymSchema.js';  // Named import

const deleteZone = async (id) => {
    try {
        const result = await Data.findOneAndDelete({ _id: id });

        if (!result) {
            throw new Error('Data not found');
        }

        console.log(
            `Deleted object: id: ${result._id}, place_name: ${result.place_name}, last_count: ${result.last_count}`
        );

        return result;
    } catch (error) {
        console.error('Failed to delete zone:', error.message);
        throw error;
    }
};

export { deleteZone };