// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

const cfn = require('./lib/cfn');
const Metrics = require('./lib/metrics');
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event, context) => {
    console.log(`REQUEST:: ${JSON.stringify(event, null, 2)}`);
    let config = event.ResourceProperties;
    let responseData = {};

    // Each resource returns a promise with a json object to return cloudformation.
    try {
        console.log(`RESOURCE:: ${config.Resource}`);
        if (event.RequestType === 'Create') {
            switch (config.Resource) {
                case 'UUID':
                    responseData = { UUID: uuidv4() };
                    break;
                case 'AnonymizedMetric':
                    if (config.SendAnonymizedMetric === "Yes") {
                        responseData.status = await Metrics.send(config);
                    }
                    break;
                default:
                    console.log(config.Resource, ': not defined as a custom resource, sending success response');
            }
        }
        const response = await cfn.send(event, context, 'SUCCESS', responseData);
        console.log(`RESPONSE:: ${JSON.stringify(responseData, null, 2)}`);
        console.log(`CFN STATUS:: ${response}`);
    } catch (err) {
        console.error(JSON.stringify(err, null, 2));
        await cfn.send(event, context, 'FAILED');
    }
};
