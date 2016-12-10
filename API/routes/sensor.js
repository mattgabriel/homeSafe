// Load required packages
var express = require('express');
var router = express.Router();

//helpers
var idGenerator = require('../helpers/idGenerator.js');

//models
var SensorsSchema = require('../models/SensorsSchema.js');
var SensorsModel = require('../models/SensorsModel.js').SensorsModel;

//auth
// var jwt = require('jsonwebtoken');


/**
 * @api {post} /sensor/:sensorId/:value Create sensor entry
 * @apiName Create sensor entry
 * @apiGroup Sensor
 *
 * @apiParam {String} sensorId The ID (descriptive name) of a sensor
 * @apiParam {Double} value The value of the sensor
 * 
 * 
 * @apiExample Example usage:
 * curl -X POST "http://localhost:3000/api/sensor/temperature_1/12.3"
 *
 * @apiErrorExample Response (example):
 { 
 	Success: Bool
 }
 */
router.post('/:sensorId/:value', function(req, res) {
	if(req.body.data !== undefined && req.body.data.length >= 10){
		
		
		//Create a new sensor entry and store it on the DB
		var sensorsModel = new SensorsModel();
		sensorsModel.createEntry(
			req.body.data, function(callback){
			// if(callback.success){
				return res.json({ 
					"DataStored" : req.body.sensorId
				});	
			// } else {
				// return res.status(404).send({ error : callback.error });
			// }
		});

	} else {
		return res.status(404).send({ error: 'Missing parameters.' });
	}
});





module.exports = router;
