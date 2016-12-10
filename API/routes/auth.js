// Load required packages
var express = require('express');
var router = express.Router();

//helpers
var idGenerator = require('../helpers/idGenerator.js');

//models
var UsersSchema = require('../models/UsersSchema.js');
var UsersModel = require('../models/UsersModel.js').UsersModel;

//auth
var jwt = require('jsonwebtoken');


/**
 * @api {post} /auth/login Login
 * @apiName Login
 * @apiGroup Auth
 *
 * @apiParam {String} email An user's email address
 * @apiParam {String} password The user's password
 * 
 * @apiSuccess {String} Token A token that should be stored by the client and used to make authenticated requests
 * 
 * @apiExample Example usage:
 * curl -X POST "http://localhost:3000/api/auth/login" -d "email=test@test.com" -d "password=myPass12"
 *
 * @apiErrorExample Response (example):
 { 
 	Token: "String"
 }
 */
router.post('/login', function(req, res) {
	if(req.body.email !== undefined &&
		req.body.password !== undefined && req.body.password.length >= 8){
		//check db for users matching email and password
		var usersModel = new UsersModel();
		usersModel.login(req.body.email, req.body.password, req.connection.remoteAddress, function(callback){
			if(callback.success){
				return res.json({ 
					"Token" : callback.Token,
				});	
			} else {
				return res.status(404).send({ error : callback.error });
			}
		});
	
	} else {
		return res.status(404).send({ error: 'Missing email or password parameters.' });
	}
});


/**
 * @api {put} /auth/logout Logout
 * @apiName Logout
 * @apiGroup Auth
 *
 * @apiUse AuthHeader
 * 
 * @apiSuccess {Bool} Success
 * 
 * @apiExample Example usage:
 * curl -X POST "http://localhost:3000/api/auth/logout" -H "TOKEN: someToken"
 *
 */
router.put('/logout', function(req, res) {
	var usersModel = new UsersModel();
	usersModel.auth(req, res, function(callback){

		//logout (deletes token from DB)
		usersModel.logout(req.headers.token, function(callback){
			if(callback.success){
				return res.json({ success: true });	
			} else {
				return res.status(404).send({ error : callback.error });
			}
		});
		
	});
});




module.exports = router;
