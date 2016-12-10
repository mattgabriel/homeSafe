var mongoose = require('mongoose');
var StatesSchema = require('../models/StatesSchema.js');
var idGenerator = require('../helpers/idGenerator.js');
var config = require('../helpers/config.js');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcrypt-nodejs');

function StatesModel() {

    /**
     * Schema
     * @type {Object}
     */
    var StatesDetails = {
        State : ""
        , Active: 1
        , Timestamp : new Date()
    }

    /************************
     * PUBLIC METHODS
     ***********************/
 
    this.createState = function(State, callback){
        StatesDetails.State = State;

        var state = new StatesSchema( StatesDetails );
        state.save(function(err1) {
            if (err1) return callback({ success: false, error: err1 });
            return callback({ success: true });
        });
    }

    this.getState = function(callback){
        var fields = { "State":1, "Timestamp":1, "Active": 1 };
        StatesSchema.findOne({"Active": 1}, fields, {sort: {"Timestamp": -1}}, function(err1, data1){  
            return callback(data1);    
        });
    }

    this.invalidateStates = function(callback){
        var query = { Active: 1 };
        var options = { multi: true }; // updates all rows
        StatesSchema.update(
            query, 
            {
                'Active': 0
            }, 
            options, function(err, numAffected){
            if (err) return callback({ "Success": false, error: err });
            return callback( { "Success": true });
        });

    }
    /************************
     * PRIVATE METHODS
     ***********************/

    

}

exports.StatesModel = StatesModel;

