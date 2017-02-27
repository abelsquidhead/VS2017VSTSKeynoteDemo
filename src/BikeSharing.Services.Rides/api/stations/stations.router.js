'use strict';

const config = require(process.cwd() + '/config').server;

const controller = require('./stations.controller');

const routes = {
    all: config.path + '/stations',
    info: config.path + '/stations/:id',
    nearest: config.path + '/stations/:id/nearest',
    checkout: config.path + '/stations/:id/checkout',
    nearestLocation: config.path + '/stations/nearto',
    byTenant: config.path + '/stations/tenant/:id'
};

module.exports = app => {
    app.get(routes.all, controller.all);
    app.get(routes.nearestLocation, controller.nearestLocation);
    app.put(routes.checkout, controller.checkout);
    app.get(routes.info, controller.info);
    app.get(routes.nearest, controller.nearest);
    app.get(routes.byTenant, controller.byTenant);
};

