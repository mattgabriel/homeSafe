var mongoose = require('mongoose');

// Define our user schema
var StatesSchema = new mongoose.Schema({
    State: { 
        type: String,
        required: true,
    },
    Timestamp: {
        type: Date,
    },
    Active: {
        type: Number,
    },
}, {
    safe: true,
    strict: true 
});


// Export the Mongoose model
module.exports = mongoose.model('States', StatesSchema);