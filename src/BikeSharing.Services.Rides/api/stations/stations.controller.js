'use strict';

const Station = require(process.cwd() + '/models/station')();
const Bike = require(process.cwd() + '/models/bike')();
const Ride = require(process.cwd() + '/models/ride')();
const sequelize = require(process.cwd() + '/db/db.sequelize.js').sequelize();

let mapStation = function (station) {
    return {
        id: station.id,
        name: station.name,
        longitude: station.longitude,
        latitude: station.latitude,
        slots: station.slots,
        occupied: station.bikes.length
    };
};

let checkout = function (req, res, next) {

    //from url
    let stationId = req.params.id;

    //payload
    let endStationId = req.params.endStationId;
    let userId = req.params.userId;

    let eventId = req.params.event.id;
    let eventName = req.params.event.name;
    let eventType = req.params.event.type;
    
    let pr = Bike.findOne({
        where: { stationId: stationId }
    })

    pr.then(bike => {
        if (!bike) {
            res.send(404, null);
            next();
            return;
        }

        bike.updateAttributes({
            stationId: null
        })
            .then(function (updatedBike) {
                Ride.create({
                    duration: 0,
                    start: new Date(),
                    stop: new Date(),
                    bikeId: updatedBike.id,
                    userId: userId,
                    eventType: eventType,
                    eventId: eventId,
                    eventName: eventName,
                    startStationId: stationId,
                    endStationId: endStationId,
                    geoDistance: 0
                })
                    .then(function (newRide) {
                        res.send(newRide.id);
                        next();
                    })
                    .catch(function (createRideError) {
                        res.send(createRideError);
                        next();
                    });
            })
            .catch(function (updateBikeError) {
                res.send(e);
                next();
            });

    });
    pr.catch(e => {
        res.send(e);
        next();
    });
};

let info = function (req, res, next) {
    let id = req.params.id;

    let pr = Station.findById(id, {
        include: [{
            model: Bike,
            as: 'bikes'
        }]
    });
    pr.then(r => {
        res.send(mapStation(r));
        next();
    });
    pr.catch(e => {
        res.send(e);
        next();
    });
}

let byTenant = function (req, res, next) {
    let tenantId = req.params.id;
    let from = parseInt(req.query.from || 0);
    let size = parseInt(req.query.size || 20);

    Station.findAndCountAll({
        offset: from,
        limit: size,
        include: [{
            model: Bike,
            as: 'bikes'
        }]
    }).then(function (result) {
        var stations = result.rows.map(function (station) {
            return mapStation(station);
        });

        res.setHeader('total', result.count);
        res.send(stations);
        next();
    }).catch(e => {
        res.send(e);
        next();
    });
}

let nearestLocation = function (req, res, next) {
    let latitude = req.query.latitude || 0;
    let longitude = req.query.longitude || 0;
    let count = req.query.count || 10;

    sequelize.query(`exec [dbo].[pStationsNear] @latitude = ${latitude}, @longitude = ${longitude}, @size = ${count}`)
        .then(nears => {
            res.send(nears)
            next();
        })
        .catch(e => {
            res.send(e);
            next();
        });
}

let nearest = function (req, res, next) {
    let id = req.params.id;
    let pr = Station.findById(id);
    let count = req.query.count || 10;
    pr.then(r => {
        let lat = r.latitude;
        let lon = r.longitude;
        return sequelize.query(`exec [dbo].[pStationsNear] @latitude = ${lat}, @longitude = ${lon}, @size = ${count}`)
    })
        .then(nears => {
            res.send(nears[1]);         // sequelize promises wraps results in arrays
            next();
        });

    pr.catch(e => {
        res.send(e);
        next();
    });
}

let all = function (req, res, next) {
    let from = parseInt(req.query.from || 0);
    let size = parseInt(req.query.size || 20);

    Station.findAndCountAll({
        include: [{
            model: Bike,
            as: 'bikes'
        }],
        offset: from,
        limit: size,
    }).then(function (result) {
        var stations = result.rows.map(function (station) {
            return {
                id: station.id,
                name: station.name,
                longitude: station.longitude,
                latitude: station.latitude,
                slots: station.slots,
                occupied: station.bikes.length
            };
        });

        res.setHeader('total', result.count);
        res.send(stations);
        next();
    }).catch(e => {
        res.send(e);
        next();
    });
};

module.exports = {
    all,
    checkout,
    info,
    nearest,
    nearestLocation,
    byTenant
};

