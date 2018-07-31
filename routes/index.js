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



router.post('/synthesize', function(req, res, next) {
    const { exec } = require('child_process');

    console.log('\nBody');
    console.log(req.body);


    let base64EncodedJsonRequest = Buffer.from(JSON.stringify(req.body)).toString('base64');

    var isRunning = true;
    var barlimanProcess = exec('./BarlimanCLI/BarlimanCLI ' + base64EncodedJsonRequest, (err, stdout, stderr) => {
        isRunning = false;
        if (err || stderr) {
            console.log("Error: " + err);
            console.log("Std err: " + stderr);
            res.status(400).send({
                message: 'Bad test. Err:' + err + '. Std err:' + stderr
            });
            return;
        }
        res.json({"payload": stdout})
    });

    setTimeout(function() {
            if (isRunning) {
                return res.status(400).send({
                    message: 'Couldnt calculate'
                });
                barlimanProcess.kill();
            }
        }, 15000);
});



module.exports = router;
