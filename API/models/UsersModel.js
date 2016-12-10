var mongoose = require('mongoose');
var UsersSchema = require('../models/UsersSchema.js');
var idGenerator = require('../helpers/idGenerator.js');
var config = require('../helpers/config.js');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcrypt-nodejs');

function UsersModel() {

    /**
     * Schema
     * @type {Object}
     */
    var UserDetails = {
        UserId : ""
        , Email : ""
        , Password : ""
        , Username : ""
        , Names : ""
        , Role : 100
        , Image : ""
        , DateCreated : new Date()
        , DateLastLogin : new Date()
        , Language : "en"
        , DeviceToken : ""
        , AuthToken : {
            DateCreated : new Date()
            , TokenId : ""
            , IP : "TODO:"
            , Valid : true
        }
    }

    /************************
     * PUBLIC METHODS
     ***********************/

     this.auth = function(req, res, callback){
        if(req.headers.token !== undefined){

            this.validateToken(req.headers.token, function(callback1){
                if(callback1.success){
                    return callback({ success: true, userId: callback1.userId });
                } else {
                    return res.status(403).send({ error: callback1.error });
                }
            });

        } else {
            return res.status(404).send({ error: 'Token not found' });
        }
     }
     
    this.createUser = function(Names, Email, Password, Ip, callback){
        var UserId = idGenerator.generateId(20);
        var Token = signToken(UserId);

        UserDetails.UserId = UserId;
        UserDetails.AuthTokens = { Token: Token, IP: Ip };
        UserDetails.Names = Names;
        UserDetails.Email = Email.toLowerCase();
        UserDetails.Password = Password;

        //check if email address is valid
        if(!validateEmail(UserDetails.Email)){
            return callback({success: false, error: "invalidEmailAddress"});
        }
        //check if email already exists in the DB
        doesEmailAlreadyExists(UserDetails.Email, function(emailCallback){
            if(emailCallback) return callback({success: false, error: "emailAlreadyExists"});
            
            var user = new UsersSchema( UserDetails );
            user.save(function(err1) {
                if (err1) return callback({ success: false, error: "databaseError" });
                return callback({ success: true, Token: Token });
            });
        });
    }

    this.login = function(Email, Password, Ip, callback){
        UsersSchema.findOne({ Email: Email }, function(err, data){
            if(err) return callback({success: false, error: "invalidRequest"});
            if(data !== null){

                bcrypt.compare(Password, data.Password, function(err, isMatch) {
                    if (err) return callback({success: false, error: "Error_1000"});

                    if(isMatch){

                        var Token = signToken(data.UserId);
                        
                        //store the new token on the DB
                        UsersSchema.update(
                            { _id: data._id },
                            { $push: { AuthTokens : { Token : Token, IP : Ip } }}, function(err, data) { 
                        });

                        return callback({success : true, Token : Token});
                    } 
                    return callback({success : false, error : "InvalidPassword"});

                });

            } else {
                return callback({success : false, error : "invalidDetails"});
            }
        });
    }

    this.logout = function(token, callback){
        try {
            var decoded = jwt.verify(token, config.config.auth_private_key);
        } catch(err) {
            return callback({success: false, error: "malformedToken"});
        }
        if(decoded.UserId != null){
            UsersSchema.findOne({ UserId: decoded.UserId }, function(err, data){
                if(err) return callback({success: false, error: "invalidRequest"});
                if(data !== null){

                    //delete the token from AuthTokens
                    UsersSchema.update(
                        { UserId: decoded.UserId }, 
                        { $pull: { "AuthTokens" : { Token: token } } },
                        null, //options
                        function(err1, numAffected){
                            if(err1 !== null) return callback({success: false, error: "tokenError" });   
                            
                            if(numAffected.nModified == 0){
                                return callback({success: false, error: "tokenNotFound" });   
                            } else {
                                return callback({success: true });   
                            }
                    });

                } else {
                    return callback({success: false, error: "invalidDetails"});
                }
            });
        } else {
            return callback({success : false, error : "userNotFound"});
        }
    }

    this.validateToken = function(token, callback){
        try {
            var decoded = jwt.verify(token, config.config.auth_private_key);
        } catch(err) {
            return callback({success: false, error: "malformedToken"});
        }
        if(decoded.UserId != null){
            UsersSchema.findOne({ UserId: decoded.UserId }, function(err, data){
                if(err) return callback({success: false, error: "invalidRequest"});
                if(data !== null){

                    //check if the token is still valid
                    for (var i=0; i<data.AuthTokens.length; i++) {
                        if(data.AuthTokens[i].Token == token){
                            if(data.AuthTokens[i].Valid){
                                return callback({success: true, userId: decoded.UserId });
                            } else {
                                return callback({success: false, error: "invalidToken"});
                            }
                        }
                    }
                    return callback({success: false, error: "tokenNotFound"});
                } else {
                    return callback({success: false, error: "invalidDetails"});
                }
            });
        } else {
            return callback({success : false, error : "userNotFound"});
        }
    }

    this.updateUser = function(UserId, data, callback){
        var query = { UserId: UserId };
        var options = { multi: false }; //only updates 1 row
        var fieldsToUpdate = {};

        for(field in data){
            switch (field) {
                case "Names":
                    fieldsToUpdate[field] = data[field];
                    break;
                case "Email":
                    //check if email address is valid
                    if(validateEmail(data[field])){
                        fieldsToUpdate[field] = data[field];
                    }
                default:
                    break;
            }
        }

        if(typeof(fieldsToUpdate.Email) !== 'undefined'){
            //check if email already exists in the DB
            doesEmailAlreadyExists(fieldsToUpdate.Email, function(emailCallback){
                if(emailCallback){
                    delete fieldsToUpdate.Email;
                } 
                UsersSchema.update(query, fieldsToUpdate, options, function(err, numAffected){
                    return callback(true);
                });
            });
        } else {
            UsersSchema.update(query, fieldsToUpdate, options, function(err, numAffected){
                return callback(true);
            });
        }
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