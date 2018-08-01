var express = require('express');
var router = express.Router();


/* GET home page. */
router.get('/', function(req, res, next) {
    res.redirect('http://example.com');
 res.redirect('https://github.com/benjenkinsv95/barliman-api')
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
                barlimanProcess.kill();
                return res.status(400).send({
                    message: 'Couldnt calculate'
                });
            }
        }, 15000);
});



module.exports = router;
