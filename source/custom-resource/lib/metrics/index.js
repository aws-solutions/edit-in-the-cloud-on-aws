// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

const axios = require('axios');

const sanitizeData = (config) => {
    // Remove lambda arn from config to avoid sending AccountId
    delete config['ServiceToken'];
    delete config['Resource'];

    return config;
};

const send = async (config) => {
    const metrics = {
        Solution: config.SolutionId,
        UUID: config.UUID,
        TimeStamp: new Date().toISOString(),
        Data: sanitizeData(config)
    };

    console.log(`metrics: ${JSON.stringify(metrics, null, 2)}`);

    const params = {
        method: 'post',
        port: 443,
        url: 'https://metrics.awssolutionsbuilder.com/generic',
        headers: {
            'Content-Type': 'application/json'
        },
        data: metrics
    };

    const data = await axios(params);
    return data.status;
};

module.exports = {
    send,
    sanitizeData
};
