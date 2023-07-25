// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

const axios = require('axios');
const expect = require('chai').expect;
const MockAdapter = require('axios-mock-adapter');

const lambda = require('./index.js');

const _config = {
    SolutionId: 'SO0153',
    UUID: '999-999',
    ServiceToken: 'lambda-arn',
    Resource: 'AnonymizedMetric'
};

describe('#SEND METRICS', () => {
    it('should return "200" on a send metrics sucess', async () => {
        const mock = new MockAdapter(axios);
        mock.onPost().reply(200, {});

        lambda.send(_config, (_err, res) => {
            expect(res).to.equal(200);
        });
    });

    it('should return "Network Error" on connection timedout', async () => {
        const mock = new MockAdapter(axios);
        mock.onPut().networkError();

        await lambda.send(_config).catch(err => {
            expect(err.toString()).to.equal('Error: Request failed with status code 404');
        });
    });

    it('should remove ServiceToken and Resource from metrics data', () => {
        const sanitizedData = lambda.sanitizeData(_config);
        expect(sanitizedData.ServiceToken).to.be.undefined;
        expect(sanitizedData.Resource).to.be.undefined;
    });
});
