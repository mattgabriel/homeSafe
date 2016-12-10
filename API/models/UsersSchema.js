var mongoose = require('mongoose');
var bcrypt = require('bcrypt-nodejs');

// Define our user schema
var UsersSchema = new mongoose.Schema({
    UserId: {
        type: String,
        unique: true,
        required: true,
        index: true
    },
    Email: {
        type: String,
        unique: true,
        required: true,
        lowercase: true
    },
    Password: {
        type: String,
        required: true
    },
    Username: {
        type: String,
        required: false,
    },
    Names: {
        type: String,
        required: true
    },
    Role: {
        type: Number,
        required: false
    },
    Image: {
        type: String,
        required: false
    },
    DateCreated: {
        type: Date,
        default: Date.now
    },
    DateLastLogin: {
        type: Date,
        default: Date.now
    },
    Language: {
        type: String,
        default: "en",
        lowercase: true
    },
    DeviceToken: { //ios only, required to send push notifications
        type: String,
        required: false,
    },
    AuthTokens: [{
        DateCreated: {
            type: Date,
            default: Date.now
        },
        Token: {
            type: String,
            required: false,
        },
        IP: {
            type: String,
            required: false,
        },
        Valid: {
            type: Boolean,
            default: true,
        },
    }],
}, { 
    safe: true,
    strict: true 
});

// Execute before each user.save() call
UsersSchema.pre('save', function(callback) {
    var user = this;

    // Break out if the password hasn't changed
    if (!user.isModified('Password')) return callback();

    // Password changed so we need to hash it
    bcrypt.genSalt(5, function(err, salt) {
        if (err) return callback(err);

        bcrypt.hash(user.Password, salt, null, function(err, hash) {
            if (err) return callback(err);
            user.Password = hash;
            callback();
        });
    });
});

UsersSchema.pre('find', function(callback) {
    var user = this;

    // Break out if the password hasn't changed
    //if (!user.isModified('Password')) return callback();

    // Password changed so we need to hash it
    bcrypt.genSalt(5, function(err, salt) {
        if (err) return callback(err);

        bcrypt.hash(user.Password, salt, null, function(err, hash) {
            if (err) return callback(err);
            user.Password = hash;
            callback();
        });
    });
});

UsersSchema.methods.comparePassword = function(candidatePassword, callback) {
    bcrypt.compare(candidatePassword, this.Password, function(err, isMatch) {
        //if (err) return cb(err);
        callback(null, true);
    });
};


// Export the Mongoose model
module.exports = mongoose.model('Users', UsersSchema);