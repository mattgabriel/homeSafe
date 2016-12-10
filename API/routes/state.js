// Load required packages
var express = require('express');
var router = express.Router();

//helpers
var idGenerator = require('../helpers/idGenerator.js');

//models

var StatesSchema = require('../models/StatesSchema.js');
var StatesModel = require('../models/StatesModel.js').StatesModel;

/**
 * @api {get} / Gets the current house state
 * @apiName GetState
 * @apiGroup States
 * @apiPermission admin, user
 * 
 * @apiSampleRequest http://localhost:3000/api/state
 * @apiExample Example usage:
 * curl -X GET http://localhost:3000/api/state
 *
 * @apiErrorExample Response (example):
 {
    "Timestamp": "December 5, 2016 11:43 PM",
    "State": String,
}
 */
router.get('/', function(req, res) {
	var statesModel = new StatesModel();	
	statesModel.getState(function(callback){
		return res.json(callback);
	});

});


/**
 * @api {post} /:value Sets the state of the person
 * @apiName CreateState
 * @apiGroup States
 *
 * @apiParam {String} value State value (LOW,MID,HIGH)
 *
 * @apiSampleRequest http://localhost:3000/api/state/:value
 * @apiExample Example usage:
 * curl -X POST "http://localhost:3000/api/state/LOW"
 *
 * @apiErrorExample Response (example):
 { 
 	Success: Bool
 }
 */
router.post('/:value', function(req, res) {		
	//Create a new sensor entry and store it on the DB
	var statesModel = new StatesModel();

	statesModel.createState(
		req.params.value, function(callback){
		if(callback.success){
			return res.json({ 
				"Success" : callback.success
			});	
		} else {
			return res.status(404).send({ error : callback.error });
		}
	});
});


/**
 * @api {put} /invalidate Invalidates all states
 * @apiName InvalidateStates
 * @apiGroup States
 *
 *
 * @apiSampleRequest http://localhost:3000/api/state/invalidate
 * @apiExample Example usage:
 * curl -X PUT "http://localhost:3000/api/states/invalidate"
 *
 * @apiErrorExample Response (example):
 { 
 	Success: Bool
 }
 */
router.put('/invalidate', function(req, res) {		
	//Create a new sensor entry and store it on the DB
	var statesModel = new StatesModel();

	statesModel.invalidateStates(function(callback){
		return res.json(callback);			
	});
});



module.exports = router;
