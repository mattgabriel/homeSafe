var mongoose = require('mongoose');

// Define our user schema
var SensorsSchema = new mongoose.Schema({
    UserId: { 
        type: String,
        required: true,
    },
    SensorId: {
        type: String
    },
    Value: {
        type: Number
    },
    Timestamp: {
        type: Date,
    },
}, { 
    safe: true,
    strict: true 
});


// Export the Mongoose model
module.exports = mongoose.model('Sensors', SensorsSchema);