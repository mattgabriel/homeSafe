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
	//Create a new sensor entry and store it on the DB
	var sensorsModel = new SensorsModel();

	var val = parseInt(req.params.value);

	sensorsModel.createEntry(
		req.params.sensorId,
		val, function(callback){
		if(callback.success){
			return res.json({ 
				"DataStored" : callback.success
			});	
		} else {
			return res.status(404).send({ error : callback.error });
		}
	});
});





module.exports = router;
