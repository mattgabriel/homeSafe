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
        , Timestamp : new Date()
    }

    /************************
     * PUBLIC METHODS
     ***********************/
 
    this.createEntry = function(SensorId, Value, callback){
        var UserId = idGenerator.generateId(50);
        SensorsDetails.UserId = UserId;
        SensorsDetails.SensorId = SensorId;
        SensorsDetails.Value = Value;

        var sensor = new SensorsSchema( SensorsDetails );
        sensor.save(function(err1) {
            if (err1) return callback({ success: false, error: err1 });
            return callback({ success: true });
        });

    }

    this.deleteUser = function(UserId, callback){
        // UsersSchema.remove({ "UserId" : UserId }, function (err, data) {
        //     if (err) return next(err);
        //     return callback(true);
        // });
    }

    this.getDataWithinRange = function(fromDate, toDate, limit, callback){
        var f = new Date(fromDate * 1000);
        var t = new Date(fromDate * 1000);

        var fields = { "SensorId":1,"Value":1, "Timestamp":1 };
        SensorsSchema.find({"Timestamp": {"$gte": new Date(f.getFullYear(),f.getMonth(),f.getDate())}}, fields, {sort: {"Timestamp": -1}}, function(err1, data1){  
            var result = [];
            if(data1.length < limit){
                return callback(data1);    
            }
            for (var i=0; i<limit; i++){
                result.push(data1[i]);
            }
            return callback(result);    
            
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

    

}

exports.SensorsModel = SensorsModel;

