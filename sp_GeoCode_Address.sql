/****** Object:  StoredProcedure [dbo].[spGeocode]    Script Date: 2020/05/28 10:39:12 ******/

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE PROCEDURE [dbo].[spGeocode]

@GPSLatitude numeric(18, 6),

@GPSLongitude numeric(18, 6)

AS

IF OBJECT_ID('tempdb..#xml') IS NOT NULL DROP TABLE #xml

CREATE TABLE #xml ( yourXML XML )

DECLARE

@Country varchar(80),

@Province varchar(80),

@Region varchar(80),

@Address varchar(200),

@City varchar(40),

@PostalCode varchar(20),

@MapURL varchar(1024);

SET NOCOUNT ON

DECLARE @URL varchar(MAX)

SET @URL = 'https://maps.google.com/maps/api/geocode/xml?latlng=' + CAST(@GPSLatitude AS varchar(20))+','+CAST(@GPSLongitude AS varchar(20))+'&key=YOURAPIKEY'

SET @URL = REPLACE(@URL, ' ', '+')

DECLARE @Response VARCHAR(MAX)

DECLARE @XML xml

DECLARE @Obj int

DECLARE @Result int

DECLARE @HTTPStatus int

DECLARE @ErrorMsg varchar(MAX)

EXEC @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Obj OUT

BEGIN TRY

EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false

EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'

EXEC @Result = sp_OAMethod @Obj, send, NULL, ''

EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT

INSERT #xml ( yourXML )

EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'--, @Response OUT

END TRY

BEGIN CATCH

SET @ErrorMsg = ERROR_MESSAGE()

END CATCH

EXEC @Result = sp_OADestroy @Obj

IF (@ErrorMsg IS NOT NULL) OR (@HTTPStatus <> 200) BEGIN

SET @ErrorMsg = 'Error in spGeocode: ' + ISNULL(@ErrorMsg, 'HTTP result is: ' + CAST(@HTTPStatus AS varchar(10)))

RAISERROR(@ErrorMsg, 16, 1, @HTTPStatus)

RETURN

END

SET @XML = (Select * from #XML)

SET @City = @XML.value('(/GeocodeResponse/result/address_component[type="locality"]/long_name) [1]', 'varchar(40)')

SET @PostalCode = @XML.value('(/GeocodeResponse/result/address_component[type="postal_code"]/long_name) [1]', 'varchar(20)')

SET @Country = @XML.value('(/GeocodeResponse/result/address_component[type="country"]/long_name) [1]', 'varchar(40)')

SET @Province = @XML.value('(/GeocodeResponse/result/address_component[type="administrative_area_level_1"]/long_name) [1]', 'varchar(40)')

SET @Region = (CASE WHEN @XML.value('(/GeocodeResponse/result/address_component[type="sublocality_level_1"]/long_name) [1]', 'varchar(40)') IS NULL THEN @City END)

SET @Address = @XML.value('(/GeocodeResponse/result/formatted_address) [2]', 'varchar(200)')

SET @MapURL = @URL

SELECT

--@GPSLatitude AS GPSLatitude,

--@GPSLongitude AS GPSLongitude,

@Country AS Country,

@City AS City,

@Region As Region,

@Province AS Province,

@PostalCode AS PostalCode,

@Address AS [Address],

@MapURL AS MapURL,

@XML AS XMLResults

--spGeoCode '-34.049987', '24.922987'

GO