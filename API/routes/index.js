var express = require('express');
var config = require('../helpers/config.js');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: config.config.app_title });
});

module.exports = router;
