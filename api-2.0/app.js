'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const bodyParser = require('body-parser');
const http = require('http')
const util = require('util');
const express = require('express')
const app = express();
const expressJWT = require('express-jwt');
// const { expressJWT: jwt } = require("express-jwt");
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const cors = require('cors');
const constants = require('./config/constants.json')
// const sha256 = require('sha256');
const axios = require('axios')

const host = "localhost";
const port = 5000;
const date = new Date();


const helper = require('./app/helper')
// const invoke = require('./app/invoke')

app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));
// set secret variable
app.set('secret', 'thisismysecret');
app.use(expressJWT({
    secret: 'thisismysecret'
}).unless({
    path: ['/device/login', '/device/register']
}));
app.use(bearerToken());

logger.level = 'debug';


app.use((req, res, next) => {
    logger.debug('New req for %s', req.originalUrl);
    if (req.originalUrl.indexOf('/device') >= 0 || req.originalUrl.indexOf('/device/login') >= 0 || req.originalUrl.indexOf('/device/register') >= 0) {
        return next();
    }
    var token = req.token;
    jwt.verify(token, app.get('secret'), (err, decoded) => {
        if (err) {
            console.log(`Error ================:${err}`)
            res.send({
                success: false,
                message: 'Failed to authenticate token. Make sure to include the ' +
                    'token returned from /users call in the authorization header ' +
                    ' as a Bearer token'
            });
            return;
        } else {
            req.username = decoded.username;
            req.orgname = decoded.orgName;
            logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
            return next();
        }
    });
});

var server = http.createServer(app).listen(port, function () { console.log(`Server started on ${port}`) });
logger.info('****************** SERVER STARTED ************************');
logger.info('******************  http://%s:%s  ************************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
    var response = {
        success: false,
        message: field + 'field is missing or Invalid in the request'
    };
    return response;
}

//need to test
async function deviceIsAuthenticated(deviceUniqueId, ri) {
    
    var apiurl = "http://localhost:4000/device/getUniqueId?deviceId=" + deviceUniqueId
    var res;
    console.log(apiurl);

    try {
        res = await axios.get(
            apiurl,
            {headers : {'Content-Type':'application/json'}})
    } catch (error) {
        res.json(getErrorMessage(error))
        return;
    }
    
    
    var RetRi = res.data.result;

    console.log("retreived Ri = %s",RetRi);
    console.log("Ri = %s",ri);
    
    if (RetRi == ri) return true
    else return false
}

// Register and enroll user
app.post('/device/register', async function (req, res) {

    var hrTime = process.hrtime()

    var req_start_time = hrTime[0] * 1000000 + hrTime[1] / 1000
    var deviceId = req.body.puf;
    var deviceSecretKey = req.body.secretKey;

    var i = 0
    var ri = ""
    var transactionHash = req.body.transactionHash;

    while(i<deviceId.length) {
        if (deviceSecretKey[i] == deviceId[i]) {
            ri = ri + "0"
        } else {
            ri = ri + "1"
        }
        i++
    }
    console.log(ri);
    // var orgName = req.body.orgName
    // var username = sha256(rollnum + "*" + password);    

    if (!deviceId) {
        res.json(getErrorMessage('\'puf\''));
        return;
    }
    if (!deviceSecretKey) {
        res.json(getErrorMessage('\'device Secret Key\''));
        return;
    }
    if (!transactionHash) {
        res.json(getErrorMessage('\'Transaction Hash\''))
        return
    }


    let isUserRegistered = await helper.isUserRegistered(deviceSecretKey, "Org1")

    if (isUserRegistered) {
        hrTime = process.hrtime()
        var req_end_time = hrTime[0] * 1000000 + hrTime[1] / 1000

        console.log("Time taken : %s",req_end_time - req_start_time);
        res.json(getErrorMessage('\'Device already registered\''))
        return;
    }

    let isUserAuthenticated = await deviceIsAuthenticated(transactionHash, ri);
    console.log(isUserAuthenticated); 
    
    if (isUserAuthenticated) {

        let response = await helper.getRegisteredUser(deviceSecretKey, "Org1");
    
        logger.debug('-- returned from registering the puf key = %s for organization', deviceId);

        hrTime = process.hrtime()        
        var req_end_time = hrTime[0] * 1000000 + hrTime[1] / 1000
        console.log("Time taken : %s",req_end_time - req_start_time);

        if (response && typeof response !== 'string') {
            logger.debug('Successfully registered the device with Secret key = %s', deviceSecretKey);
            // response.token = token;
            res.json({success: true, message: response});
        } else {
            logger.debug('Failed to register the username %s with::%s', deviceId, response);
            res.json({ success: false, message: response });
        }

    } else {

        hrTime = process.hrtime()
        var req_end_time = hrTime[0] * 1000000 + hrTime[1] / 1000
        
        console.log("Time taken : %s",req_end_time - req_start_time);
        res.json(getErrorMessage('\'Device is not authentic\''))
        return;
    }

});

// Login and get jwt
app.post('/device/login', async function (req, res) {
    var deviceId = req.body.ri;
    var orgName = "Org1"//req.body.orgName;

    // logger.debug('End point : /users');
    // logger.debug('User name : ' + puf);
    // logger.debug('Org name  : ' + orgName);
    
    if (!deviceId) {
        res.json(getErrorMessage('\'device id\''));
        return;
    }
    
    if (!orgName) {
        res.json(getErrorMessage('\'orgName\''));
        return;
    }

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        deviceId: deviceId,
        orgName: orgName
    }, app.get('secret'));


    let isUserRegistered = await helper.isUserRegistered(deviceId, orgName);

    if (isUserRegistered) {
        res.json({ success: true, message: { token: token } });

    } else {
        res.json({ success: false, message: `User with username ${deviceId} is not registered with ${orgName}, Please register first.` });
    }

});