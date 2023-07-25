// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

const { expect } = require('chai');
const sinon = require('sinon');
const { handler } = require('./index');
const cfn = require('./lib/cfn');
const Metrics = require('./lib/metrics');

describe('#Lambda Handler::', () => {
  let event;
  let context;

  beforeEach(() => {
    event = {
      RequestType: 'Create',
      ResourceProperties: {
        Resource: 'UUID',
      },
    };

    context = {
      logStreamName: 'cloudwatch',
    };
  });

  afterEach(() => {
    sinon.restore();
  });

  it('should handle "Create" RequestType for "AnonymizedMetric" resource with SendAnonymizedMetric = "Yes"', async () => {
    const cfnSendStub = sinon.stub(cfn, 'send').resolves('SUCCESS');
    const metricsSendStub = sinon.stub(Metrics, 'send').resolves('MetricsSent');

    event.ResourceProperties.Resource = 'AnonymizedMetric';
    event.ResourceProperties.SendAnonymizedMetric = 'Yes';

    await handler(event, context);

    expect(cfnSendStub.calledOnce).to.be.true;
    expect(metricsSendStub.calledOnce).to.be.true;
    expect(cfnSendStub.firstCall.args[2]).to.equal('SUCCESS');
    expect(cfnSendStub.firstCall.args[3]).to.deep.equal({ status: 'MetricsSent' });
  });

  it('should handle "Create" RequestType for unknown resource', async () => {
    const cfnSendStub = sinon.stub(cfn, 'send').resolves('SUCCESS');

    event.ResourceProperties.Resource = 'UnknownResource';

    await handler(event, context);

    expect(cfnSendStub.calledOnce).to.be.true;
    expect(cfnSendStub.firstCall.args[2]).to.equal('SUCCESS');
    expect(cfnSendStub.firstCall.args[3]).to.deep.equal({});
  });

  it('should handle "Create" RequestType without any resource', async () => {
    const cfnSendStub = sinon.stub(cfn, 'send').resolves('SUCCESS');

    event.ResourceProperties = {};

    await handler(event, context);

    expect(cfnSendStub.calledOnce).to.be.true;
    expect(cfnSendStub.firstCall.args[2]).to.equal('SUCCESS');
    expect(cfnSendStub.firstCall.args[3]).to.deep.equal({});
  });

  it('should handle "Update" RequestType', async () => {
    const cfnSendStub = sinon.stub(cfn, 'send').resolves('SUCCESS');

    event.RequestType = 'Update';

    await handler(event, context);

    expect(cfnSendStub.calledOnce).to.be.true;
    expect(cfnSendStub.firstCall.args[2]).to.equal('SUCCESS');
    expect(cfnSendStub.firstCall.args[3]).to.deep.equal({});
  });

  it('should handle "Delete" RequestType', async () => {
    const cfnSendStub = sinon.stub(cfn, 'send').resolves('SUCCESS');

    event.RequestType = 'Delete';

    await handler(event, context);

    expect(cfnSendStub.calledOnce).to.be.true;
    expect(cfnSendStub.firstCall.args[2]).to.equal('SUCCESS');
    expect(cfnSendStub.firstCall.args[3]).to.deep.equal({});
  });
});
