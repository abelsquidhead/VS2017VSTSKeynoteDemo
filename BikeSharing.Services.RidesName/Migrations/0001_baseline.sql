-- <Migration ID="b962aa74-d6ae-4716-89ee-fb25244c4e6f" />
GO

PRINT N'Creating [dbo].[rides]'
GO
CREATE TABLE [dbo].[rides]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Duration] [int] NULL,
[Start] [datetime2] NULL,
[Stop] [datetime2] NULL,
[StartStationId] [int] NOT NULL,
[EndStationId] [int] NULL,
[BikeId] [int] NOT NULL,
[UserId] [int] NOT NULL,
[EventType] [int] NULL,
[EventId] [int] NULL,
[GeoDistance] [int] NULL,
[EventName] [varchar] (512) NULL,
[a] [nchar] (10) NULL
)
GO
PRINT N'Creating primary key [PK__rides__3214EC071C862CEC] on [dbo].[rides]'
GO
ALTER TABLE [dbo].[rides] ADD CONSTRAINT [PK__rides__3214EC071C862CEC] PRIMARY KEY CLUSTERED  ([Id])
GO
PRINT N'Creating [dbo].[tempRides]'
GO
CREATE view [dbo].[tempRides] AS
SELECT [Id]
      ,[Duration]
      ,[Start]
      ,[Stop]
      ,[StartStationId]
      ,[EndStationId]
      ,[BikeId]
      ,[UserId]
      ,[EventType]
      ,case when Id % 400 = 0 then (SELECT ABS(CHECKSUM(NewId())) % 351 + 1) ELSE NULL END as EventId
      ,[GeoDistance]
  FROM [dbo].[rides]
GO
PRINT N'Creating [dbo].[bikes]'
GO
CREATE TABLE [dbo].[bikes]
(
[Id] [int] NOT NULL,
[SerialNumber] [varchar] (16) NULL,
[InCirculationSince] [datetime2] NOT NULL,
[StationId] [int] NULL
)
GO
PRINT N'Creating primary key [PK__bikes__3214EC07CE563C95] on [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD CONSTRAINT [PK__bikes__3214EC07CE563C95] PRIMARY KEY CLUSTERED  ([Id])
GO
PRINT N'Creating [dbo].[vwDistancePerBike]'
GO
CREATE VIEW [dbo].[vwDistancePerBike]
AS
SELECT        r.BikeId, SUM(COALESCE (r.GeoDistance, 0)) AS Expr1
FROM            dbo.rides AS r INNER JOIN
                         dbo.Bikes AS b ON r.BikeId = b.Id
GROUP BY r.BikeId
GO
PRINT N'Creating [dbo].[holidayDates]'
GO
CREATE TABLE [dbo].[holidayDates]
(
[Date] [date] NOT NULL,
[City] [nchar] (3) NOT NULL,
[Name] [nchar] (25) NULL
)
GO
PRINT N'Creating [dbo].[vwRides]'
GO

CREATE VIEW [dbo].[vwRides] AS
SELECT rid.Id
	, rid.Duration
	, rid.Start
	, rid.StartStationId
	, rid.EndStationId
	, rid.BikeId
	, rid.UserId
	, rid.EventType
	, rid.EventId
	, rid.GeoDistance
	, DATEPART(hh, rid.Start) AS HourOfDay
	, DATENAME(w, rid.Start) AS DayName
	, DATENAME(m, rid.Start) AS MonthName
	, CASE WHEN DATEPART(w, rid.Start) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
	, CASE WHEN DATEPART(w, rid.Start) = 1 OR hol.Date IS NOT NULL THEN 1 ELSE 0 END AS IsHoliday
	, COALESCE(hol.Name, '') AS HolidayName
FROM dbo.rides rid
	LEFT JOIN dbo.holidayDates hol ON CAST(rid.Start AS Date) = hol.Date
GO
PRINT N'Creating [dbo].[stations]'
GO
CREATE TABLE [dbo].[stations]
(
[Id] [int] NOT NULL,
[Name] [varchar] (64) NOT NULL,
[Latitude] [numeric] (18, 10) NOT NULL,
[Longitude] [numeric] (18, 10) NOT NULL,
[Slots] [numeric] (4, 0) NOT NULL CONSTRAINT [DF__stations__Slots__3D5E1FD2] DEFAULT ((30))
)
GO
PRINT N'Creating primary key [PK__stations__3214EC07599D3D6A] on [dbo].[stations]'
GO
ALTER TABLE [dbo].[stations] ADD CONSTRAINT [PK__stations__3214EC07599D3D6A] PRIMARY KEY CLUSTERED  ([Id])
GO
PRINT N'Creating [dbo].[vwRoutesUsed]'
GO

CREATE VIEW [dbo].[vwRoutesUsed] AS
SELECT TOP 100 *
	, geography::STPointFromText('POINT(' + CAST(StartStationLongitude AS VARCHAR(20)) + ' ' + CAST(StartStationLatitude AS VARCHAR(20)) + ')', 4326) AS GeoPositionStart
	, geography::STPointFromText('POINT(' + CAST(EndStationLongitude AS VARCHAR(20)) + ' ' + CAST(EndStationLatitude AS VARCHAR(20)) + ')', 4326) AS GeoPositionEnd
FROM
	(
	SELECT rid.StartStationId
		, rid.EndStationId
		, ori.Name AS StartStationName
		, ori.Latitude AS StartStationLatitude
		, ori.Longitude AS StartStationLongitude
		, des.Name AS EndStationName
		, des.Latitude AS EndStationLatitude
		, des.Longitude AS EndStationLongitude
		, COUNT(1) AS RouteUsed
	FROM dbo.rides rid
		JOIN stations ori ON rid.StartStationId = ori.Id
		JOIN stations des ON rid.StartStationId = des.Id
	GROUP BY rid.StartStationId
	, rid.EndStationId
	, ori.Name
	, ori.Latitude
	, ori.Longitude
	, des.Name
	, des.Latitude
	, des.Longitude
	) info
WHERE StartStationId <> EndStationId
ORDER BY RouteUsed desc
GO
PRINT N'Creating [dbo].[vwStationArrivals]'
GO

CREATE VIEW [dbo].[vwStationArrivals] AS
SELECT TOP 100 *
	, geography::STPointFromText('POINT(' + CAST(Longitude AS VARCHAR(20)) + ' ' + CAST(Latitude AS VARCHAR(20)) + ')', 4326) AS GeoPosition
FROM
	(
	SELECT rid.EndStationId
		, des.Name
		, des.Latitude
		, des.Longitude
		, COUNT(1) AS Arrivals
	FROM dbo.rides rid
		JOIN stations des ON rid.EndStationId = des.Id
	GROUP BY rid.EndStationId
	, des.Name
	, des.Latitude
	, des.Longitude
	) info
ORDER BY Arrivals desc
GO
PRINT N'Creating [dbo].[vwStationDepartures]'
GO

CREATE VIEW [dbo].[vwStationDepartures] AS
SELECT TOP 100 *
	, geography::STPointFromText('POINT(' + CAST(Longitude AS VARCHAR(20)) + ' ' + CAST(Latitude AS VARCHAR(20)) + ')', 4326) AS GeoPosition
FROM
	(
	SELECT rid.StartStationId
		, des.Name
		, des.Latitude
		, des.Longitude
		, COUNT(1) AS Departures
	FROM dbo.rides rid
		JOIN stations des ON rid.StartStationId = des.Id
	GROUP BY rid.StartStationId
	, des.Name
	, des.Latitude
	, des.Longitude
	) info
ORDER BY Departures desc
GO
PRINT N'Creating [dbo].[GetDistanceFromLocation]'
GO
CREATE FUNCTION [dbo].[GetDistanceFromLocation]
(   
    @CurrentLatitude float,
    @CurrentLongitude float,
    @latitude float,
    @longitude float
)
RETURNS int
AS
BEGIN
    DECLARE @geo1 geography = geography::Point(@CurrentLatitude, @CurrentLongitude, 4268), 
            @geo2 geography = geography::Point(@latitude, @longitude, 4268)

    DECLARE @distance int
    SELECT @distance = @geo1.STDistance(@geo2) 

    RETURN @distance

END
GO
PRINT N'Creating [dbo].[pStationsNear]'
GO
CREATE PROCEDURE [dbo].[pStationsNear]
	@latitude float,
	@longitude float,
	@size int = 5000
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT TOP( @size) station.*, j.Occupied, dbo.[GetDistanceFromLocation](station.Latitude, station.Longitude, @latitude, @longitude) as Distance 
	FROM stations AS station
	LEFT OUTER JOIN (SELECT s.id, COUNT(b.id) AS Occupied FROM stations s LEFT OUTER JOIN bikes as b ON b.stationId = s.id GROUP BY s.id) AS j ON j.id = station.id
	ORDER BY dbo.[GetDistanceFromLocation](station.Latitude, station.Longitude, @latitude, @longitude)
END
GO
PRINT N'Creating [dbo].[Events]'
GO
CREATE TABLE [dbo].[Events]
(
[Id] [int] NOT NULL,
[EndTime] [datetime2] NULL,
[ExternalId] [nvarchar] (450) NOT NULL,
[GenreId] [int] NOT NULL,
[ImagePath] [nvarchar] (max) NULL,
[Name] [nvarchar] (max) NULL,
[SegmentId] [int] NOT NULL,
[StartTime] [datetime2] NULL,
[SubGenreId] [int] NOT NULL,
[VenueId] [int] NOT NULL
)
GO
PRINT N'Creating [dbo].[tempEventRating]'
GO
CREATE VIEW [dbo].[tempEventRating] AS
SELECT DISTINCT UserId 
	, eve.Name AS EventName
	, 5.0 AS Rating 
FROM dbo.temprides rid
	JOIN dbo.events eve on rid.EventId = eve.Id
GO
PRINT N'Creating [dbo].[Classifications]'
GO
CREATE TABLE [dbo].[Classifications]
(
[Id] [int] NOT NULL,
[ExternalId] [nvarchar] (450) NOT NULL,
[Name] [nvarchar] (max) NULL,
[Type] [int] NOT NULL
)
GO
PRINT N'Creating [dbo].[vwEventsClassification]'
GO
CREATE VIEW [dbo].[vwEventsClassification] AS
SELECT DISTINCT eve.Name AS EventName
	, seg.Name + '|' + gen.Name + '|' + sub.Name AS Classification
FROM dbo.events eve
	join dbo.Classifications gen on eve.GenreId = gen.Id
	join dbo.Classifications sub on eve.SubGenreId = sub.Id
	join dbo.Classifications seg on eve.SegmentId = seg.Id
GO
PRINT N'Creating [dbo].[Venues]'
GO
CREATE TABLE [dbo].[Venues]
(
[Id] [int] NOT NULL,
[ExternalId] [nvarchar] (450) NOT NULL,
[Latitude] [numeric] (18, 10) NOT NULL,
[Longitude] [numeric] (18, 10) NULL,
[Name] [nvarchar] (max) NULL
)
GO
PRINT N'Creating [dbo].[vwVenueStations]'
GO
CREATE VIEW [dbo].[vwVenueStations]
AS
SELECT VenueId
	, StationId
	, ROW_NUMBER () OVER (PARTITION BY VenueId ORDER BY GeoDistance) AS StationRanking
	FROM
	(
	SELECT ven.Id AS VenueId
		, sta.Id AS StationId
		, geography::STPointFromText('POINT(' + CAST(ven.Longitude AS VARCHAR(20)) + ' ' + CAST(ven.Latitude AS VARCHAR(20)) + ')', 4326).STDistance
			(
			geography::STPointFromText('POINT(' + CAST(sta.Longitude AS VARCHAR(20)) + ' ' + CAST(sta.Latitude AS VARCHAR(20)) + ')', 4326)
			) AS GeoDistance
	  FROM [dbo].[Venues] ven
	  JOIN [dbo].[stations] sta
		ON geography::STPointFromText('POINT(' + CAST(ven.Longitude AS VARCHAR(20)) + ' ' + CAST(ven.Latitude AS VARCHAR(20)) + ')', 4326).STDistance
			(
			geography::STPointFromText('POINT(' + CAST(sta.Longitude AS VARCHAR(20)) + ' ' + CAST(sta.Latitude AS VARCHAR(20)) + ')', 4326)
			)
			< 300
	) dis
GO
PRINT N'Creating [dbo].[pGetBikeLogisticsSet]'
GO

CREATE PROCEDURE [dbo].[pGetBikeLogisticsSet]
	@PDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @PDate = COALESCE(@PDate, DATEADD(dd, 1, GETDATE()));

	WITH DateTimes AS	
		(
		SELECT dat.Date
			, dat.HourOfDay
			, DATENAME(w, dat.Date) AS DayName
			, DATENAME(m, dat.Date) AS MonthName
			, CASE WHEN DATEPART(w, dat.Date) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
			, CASE WHEN DATEPART(w, dat.Date) = 1 OR hol.Date IS NOT NULL THEN 1 ELSE 0 END AS IsHoliday
			, COALESCE(hol.Name, '') AS HolidayName
		FROM 
			(
			SELECT @PDate AS Date
				, hour.HourOfDay AS HourOfDay
			FROM (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12), 
				(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23)) as hour(HourOfDay)
			) dat
		LEFT JOIN dbo.holidayDates hol ON dat.Date = hol.Date
		)
	, Events AS
		(
		SELECT sta.Id as StationId
		, dat.Date
		, dat.DayName
		, dat.MonthName
		, dat.HourOfDay
		, dat.IsWeekend
		, dat.IsHoliday
		, dat.HolidayName
		, 0 AS Arrivals
		, 0 AS Departures
		, CASE WHEN eve.Name IS NULL THEN 0 ELSE 1 END AS EventCount
		FROM  dbo.stations sta 
		CROSS APPLY Datetimes dat
		LEFT JOIN dbo.vwVenueStations ven ON sta.Id = ven.StationId
		LEFT JOIN dbo.Events eve ON ven.VenueId = eve.VenueId 
			AND CAST(eve.StartTime AS DATE) = dat.Date 
			AND dat.HourOfDay = DATEPART(hh, DATEADD(hh, -1, eve.StartTime))
		)
	SELECT StationId
		, Date
		, DayName
		, MonthName
		, HourOfDay
		, IsWeekend
		, IsHoliday
		, HolidayName
		, SUM(Arrivals) AS Arrivals
		, SUM(Departures) AS Departures
		, SUM(EventCount) AS EventCount
	FROM Events eve
	GROUP BY StationId
		, Date
		, DayName
		, MonthName
		, HourOfDay
		, IsWeekend
		, IsHoliday
		, HolidayName
END
GO
PRINT N'Creating [dbo].[vwBikeLogistics]'
GO

CREATE VIEW [dbo].[vwBikeLogistics] AS
WITH DateTimes AS
	(
	SELECT dat.Date
		, dat.HourOfDay
		, DATENAME(w, dat.Date) AS DayName
		, DATENAME(m, dat.Date) AS MonthName
		, CASE WHEN DATEPART(w, dat.Date) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
		, CASE WHEN DATEPART(w, dat.Date) = 1 OR hol.Date IS NOT NULL THEN 1 ELSE 0 END AS IsHoliday
		, COALESCE(hol.Name, '') AS HolidayName
	FROM 
		(
		SELECT DISTINCT CAST(Start AS DATE) AS Date
			, hour.HourOfDay AS HourOfDay
		FROM dbo.rides rid
		CROSS JOIN (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12), 
			(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23)) as hour(HourOfDay)
		) dat
	LEFT JOIN dbo.holidayDates hol ON dat.Date = hol.Date
	)
, Arrivals AS
	(
	SELECT EndStationId
		, CAST(Start AS DATE) AS Date
		, HourOfDay
		, COUNT(*) AS Arrivals
	FROM dbo.vwRides
	GROUP BY EndStationId
		, CAST(Start AS DATE)
		, HourOfDay
	)
, Departures AS
	(
	SELECT StartStationId
		, CAST(Start AS DATE) AS Date
		, HourOfDay
		, COUNT(*) AS Departures
	FROM dbo.vwRides
	GROUP BY StartStationId
		, CAST(Start AS DATE)
		, HourOfDay
	)
, Origin AS	
	(
	SELECT sta.Id AS StationId
		, dat.Date
		, dat.DayName
		, dat.MonthName
		, dat.HourOfDay
		, dat.IsWeekend
		, dat.IsHoliday
		, dat.HolidayName
		, SUM(COALESCE(Arrivals, 0)) AS Arrivals
		, SUM(COALESCE(Departures, 0)) AS Departures
	FROM dbo.stations sta
		CROSS JOIN Datetimes dat	
		LEFT JOIN Arrivals arr ON sta.Id = arr.EndStationId AND dat.Date = arr.Date AND dat.HourOfDay = arr.HourOfDay
		LEFT JOIN Departures dep ON sta.Id = dep.StartStationId AND dat.Date = dep.Date AND dat.HourOfDay = dep.HourOfDay
	GROUP BY sta.Id
		, dat.Date
		, dat.DayName
		, dat.MonthName
		, dat.HourOfDay
		, dat.IsWeekend
		, dat.IsHoliday
		, dat.HolidayName
	)
, Events AS
	(
	SELECT ven.StationId
		, CAST(eve.StartTime AS DATE) AS EventDate
		, DATEPART(hh, DATEADD(hh, -1, eve.StartTime)) AS HourOfDay
		, COUNT(*) AS EventCount
	FROM dbo.vwVenueStations ven
		JOIN [dbo].[Events] eve ON ven.VenueId = eve.VenueId
	GROUP BY StationId
		, CAST(eve.StartTime AS DATE)
		, DATEPART(hh, DATEADD(hh, -1, eve.StartTime))
	)

SELECT ori.StationId
	, ori.Date
	, ori.DayName
	, ori.MonthName
	, ori.HourOfDay
	, ori.IsWeekend
	, ori.IsHoliday
	, ori.HolidayName
	, ori.Arrivals
	, ori.Departures
	, COALESCE(eve.EventCount, 0) AS EventCount
FROM
	Origin AS ori
LEFT JOIN Events eve ON ori.StationId = eve.StationId 
	AND ori.Date = eve.EventDate 
	AND ori.HourOfDay = eve.HourOfDay
GO
PRINT N'Creating [dbo].[ridePositions]'
GO
CREATE TABLE [dbo].[ridePositions]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[RideId] [int] NOT NULL,
[Latitude] [numeric] (18, 10) NOT NULL,
[Longitude] [numeric] (18, 10) NOT NULL,
[TS] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_ridePositions] on [dbo].[ridePositions]'
GO
ALTER TABLE [dbo].[ridePositions] ADD CONSTRAINT [PK_ridePositions] PRIMARY KEY CLUSTERED  ([Id])
GO
PRINT N'Creating index [ix_RidePositions_RideId] on [dbo].[ridePositions]'
GO
CREATE NONCLUSTERED INDEX [ix_RidePositions_RideId] ON [dbo].[ridePositions] ([RideId])
GO
PRINT N'Adding foreign keys to [dbo].[rides]'
GO
ALTER TABLE [dbo].[rides] ADD CONSTRAINT [FK_rides_ToBike] FOREIGN KEY ([BikeId]) REFERENCES [dbo].[bikes] ([Id])
GO
ALTER TABLE [dbo].[rides] ADD CONSTRAINT [FK_rides_ToStartStation] FOREIGN KEY ([StartStationId]) REFERENCES [dbo].[stations] ([Id])
GO
ALTER TABLE [dbo].[rides] ADD CONSTRAINT [FK_rides_ToEndStation] FOREIGN KEY ([EndStationId]) REFERENCES [dbo].[stations] ([Id])
GO
PRINT N'Adding foreign keys to [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD CONSTRAINT [FK_bikes_ToStation] FOREIGN KEY ([StationId]) REFERENCES [dbo].[stations] ([Id])
GO
PRINT N'Adding foreign keys to [dbo].[ridePositions]'
GO
ALTER TABLE [dbo].[ridePositions] ADD CONSTRAINT [FK_ridePositions_rides] FOREIGN KEY ([RideId]) REFERENCES [dbo].[rides] ([Id])
GO
