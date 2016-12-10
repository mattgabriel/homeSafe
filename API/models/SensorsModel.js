var mongoose = require('mongoose');
var SensorsSchema = require('../models/SensorsSchema.js');
var idGenerator = require('../helpers/idGenerator.js');
var config = require('../helpers/config.js');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcrypt-nodejs');

function SensorsModel() {

    /**
     * Schema
     * @type {Object}
     */
    var SensorsDetails = {
        UserId : ""
        , SensorId : ""
        , Value : ""
        , Timestamp : ""
    }

    /************************
     * PUBLIC METHODS
     ***********************/
 
    this.createEntry = function(SensorId, Value, Timestamp, callback){

        SensorsDetails.UserId = "Default";
        SensorsDetails.SensorId = SensorId;
        SensorsDetails.Value = Value;
        SensorsDetails.Timestamp = Timestamp;

        var sensor = new SensorsSchema( SensorsDetails );
        sensor.save(function(err1) {
            if (err1) return callback({ success: false, error: "databaseError" });
            return callback({ success: true });
        });

    }

    this.deleteUser = function(UserId, callback){
        UsersSchema.remove({ "UserId" : UserId }, function (err, data) {
            if (err) return next(err);
            return callback(true);
        });
    }

    this.getDetailsForUser = function(UserId, callback){
        var fields = { "_id":0, "UserId":1,"Email":1,"Username":1,"Names":1,"Role":1,"Image":1,"Language":1,"DateLastLogin":1,"DateCreated":1 };
        UsersSchema.findOne({ "UserId" : UserId }, fields, function(err, data){
            if(err) return callback(false);
            return callback(data);            
        });
    }

    /************************
     * PRIVATE METHODS
     ***********************/

    var signToken = function(UserId){
        var token = jwt.sign({ 
            UserId: UserId
        }, config.config.auth_private_key);
        return token
    }

    var doesEmailAlreadyExists = function(Email, callback){
        UsersSchema.find({Email: Email }, function(err, data){
            if(data.length > 0){ return callback(true); } else { return callback(false); }
        });
    }

    var validateEmail = function(email) {  
        var filter=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
        if (filter.test(email)){
            return true;
        }
        return false;
    }  

}

exports.UsersModel = UsersModel;