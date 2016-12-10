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
 * @api {post} /user/signup Create user
 * @apiName Create user
 * @apiGroup User
 *
 * @apiParam {String} email A valid email address (not already in the system)
 * @apiParam {String} password A new password (8+ characters long)
 * @apiParam {String} names The user's name(s)
 * 
 * @apiSuccess {String} Token A token that should be stored by the client and used to make authenticated requests
 * 
 * @apiExample Example usage:
 * curl -X POST http://localhost:3000/api/user/signup -d "email=test@test.com" -d "password=myPass12" -d "names=John Appleseed"
 *
 * @apiErrorExample Response (example):
 { 
 	Token: "String"
 }
 */
router.post('/signup', function(req, res) {
	if(req.body.email !== undefined &&
		req.body.password !== undefined && req.body.password.length >= 8 &&
		req.body.names !== undefined && req.body.password.length >= 2){
		
		//Create a new user and store it on the DB
		var usersModel = new UsersModel();
		usersModel.createUser(
			req.body.names, 
			req.body.email, 
			req.body.password,
			req.connection.remoteAddress, function(callback){
			if(callback.success){
				return res.json({ 
					"Token" : callback.Token
				});	
			} else {
				return res.status(404).send({ error : callback.error });
			}
		});

	} else {
		return res.status(404).send({ error: 'Missing parameters.' });
	}
});


/**
 * @api {put} /user/update Update user details
 * @apiName UpdateUser
 * @apiGroup User
 * @apiPermission admin, user
 *
 * @apiParam {String} [Names]
 * @apiParam {String} [Email]
 * 
 * @apiUse AuthHeader
 * 
 * @apiSampleRequest http://localhost:3000/api/user/update
 * @apiExample Example usage:
 * curl -X PUT http://localhost:3000/api/user/update -H "TOKEN: someToken"
 *
 * @apiErrorExample Response (example):
 { 
 	"success" : true, 
 }
 */
router.put('/update', function(req, res) {
	var usersModel = new UsersModel();
	usersModel.auth(req, res, function(callback){

		//update user details
		var userId = callback.userId;
		usersModel.updateUser(userId, req.body, function(callback){
			if(callback){					
				return res.json({ success: true });
			}
			return res.status(403).send({ error: "Nothing updated" });
		});
		
	});	
});



/**
 * @api {get} /user/details Get user details
 * @apiName GetUserDetails
 * @apiGroup User
 * @apiPermission admin, user
 *
 * @apiUse AuthHeader
 * 
 * @apiSampleRequest http://localhost:3000/api/user/details
 * @apiExample Example usage:
 * curl -X GET http://localhost:3000/api/user/details -H "TOKEN: someToken"
 *
 * @apiErrorExample Response (example):
 {
    "UserId": String,
    "Email": String,
    "Username": String,
    "Names": String,
    "Role": Int,
    "Image": String,
    "Language": String,
    "DateLastLogin": Date,
    "DateCreated": Date
}
 */
router.get('/details', function(req, res) {
	var usersModel = new UsersModel();
	usersModel.auth(req, res, function(callback){

		//get user details
		var userId = callback.userId;
		usersModel.getDetailsForUser(userId, function(callback){
			return res.json(callback);
		});

	});	
});




/**
 * @api {delete} /user/delete Delete user
 * @apiName Delete user
 * @apiGroup User
 * @apiPermission admin, user
 *
 * @apiUse AuthHeader
 * 
 * @apiSampleRequest http://localhost:3000/api/user/delete
 * @apiExample Example usage:
 * curl -X DELETE http://localhost:3000/api/user/delete -H "TOKEN: someToken"
 *
 * @apiErrorExample Response (example):
 {
    "Success": Bool
}
 */
router.delete('/delete', function(req, res) {
	var usersModel = new UsersModel();
	usersModel.auth(req, res, function(callback){

		//delete user
		var userId = callback.userId;
		usersModel.deleteUser(userId, function(callback){
			return res.json({ success: callback });
		});

	});	
});




module.exports = router;
