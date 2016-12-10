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


/**
 * @api {get} /:fromDate/:toDate Get data from date to date
 * @apiName GetSensorData
 * @apiGroup Sensor
 * @apiPermission admin, user
 *
 * @apiParam {Int} fromDate From date (UTC timestamp)
 * @apiParam {Int} toDate To date (UTC timestamp)
 * 
 * @apiSampleRequest http://localhost:3000/api/sensor/:fromDate/:toDate
 * @apiExample Example usage:
 * curl -X GET http://localhost:3000/api/sensor/123123123/12312312312
 *
 * @apiErrorExample Response (example):
 {
    "DateCreated": Date
}
 */
router.get('/:fromDate/:toDate', function(req, res) {
	var sensorsModel = new SensorsModel();
	//get user details
	var fromDate = timeConverter(parseInt(req.params.fromDate));
	var toDate = timeConverter(parseInt(req.params.toDate));

	var date = new Date(fromDate*1000);

	sensorsModel.getDataWithinRange(parseInt(req.params.fromDate), parseInt(req.params.toDate), function(callback){
		return res.json({ "From": fromDate, "To": toDate, "Data" : callback });
	});

});


function timeConverter(UNIX_timestamp){
  var a = new Date(UNIX_timestamp * 1000);
  var months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  var year = a.getFullYear();
  var month = months[a.getMonth()];
  var date = a.getDate();
  var hour = a.getHours();
  var min = a.getMinutes();
  var sec = a.getSeconds();
  var am = "AM";
  if(hour > 12){
  	hour = hour - 12;
  	am = "PM";
  }
  if(min < 10){
  	min = "0" + min;
  }
  //var time = date + ' ' + month + ' ' + year + ' ' + hour + ':' + min + ':' + sec ;
  var time = month + ' ' + date + ', ' + year + ' ' + hour + ':' + min + ' ' + am;
  return time;
}

module.exports = router;
