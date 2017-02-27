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
	select top( @size) s.*, dbo.[GetDistanceFromLocation](s.Latitude, s.Longitude, @latitude, @longitude) as distance from stations s
	order by dbo.[GetDistanceFromLocation](s.Latitude, s.Longitude, @latitude, @longitude)
END
GO