var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});


router.get('/hello', function(req, res, next) {
    const { exec } = require('child_process');

    exec('echo \'hello world\'', (err, stdout, stderr) => {
        if (err) {
            return;
        }
        res.json({"payload": stdout})
  });

});

router.get('/barliman', function(req, res, next) {
    const { exec } = require('child_process');


    exec('./BarlimanCLI/BarlimanCLI', (err, stdout, stderr) => {
        if (err) {
            return;
        }
        res.json({"payload": stdout})
    });
});

module.exports = router;
