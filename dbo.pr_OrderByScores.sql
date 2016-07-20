-- check if the object exists and drop it
IF OBJECT_ID('pr_OrderByScore') IS NOT NULL
  DROP PROCEDURE dbo.pr_OrderByScore;
GO

-- create the stored procedure
CREATE PROCEDURE dbo.pr_OrderByScore @FilePath NVARCHAR(250)
AS
BEGIN  

  BEGIN TRY
  -- declare variables     
  DECLARE @Id INT
  DECLARE @FirstName NVARCHAR(500)
  DECLARE @LastName  NVARCHAR(500)
  DECLARE @Processed BIT
  DECLARE @StringScore NVARCHAR(256)
  --DECLARE @Score     INT -- can it be float?
  DECLARE @WriteFile NVARCHAR(MAX)             
  DECLARE @WriteToFile NVARCHAR(256)
  DECLARE @ExecSQL NVARCHAR(MAX)
  DECLARE @LenOfFilePath INT = LEN(@FilePath)                
  DECLARE @ErrorMessage NVARCHAR(256)
  DECLARE @ErrorCode    INT
  --variables needed when deleting result file
  DECLARE @Result INT
  DECLARE @FSO_Token INT

  -- need to validate the data, i.e. they have firstname, lastname etc

  -- drop temp table if exists
  IF OBJECT_ID('tempdb.#ScoreData') IS NOT NULL 
    DROP TABLE #ScoreData

  CREATE TABLE #ScoreData (   
    Lastname NVARCHAR(MAX)
   ,Firstname NVARCHAR(MAX)
   ,Score NVARCHAR(100)  
  --, ID        INT IDENTITY     /*uniquely identify a record, incase of duplicate names or scores*/
  )

  -- CREATE the file name for the results '-graded'
  SET @WriteToFile = SUBSTRING(@FilePath,0,CHARINDEX('.', @FilePath, 0))+'-graded'+SUBSTRING(@FilePath,CHARINDEX('.', @FilePath, 0),@LenOfFilePath-CHARINDEX('.', @FilePath, 0)+1)

  -- delete the 'graded' file if it exists
  EXEC @Result = sp_OACreate 'Scripting.FileSystemObject', @FSO_Token OUTPUT
  EXEC @Result = sp_OAMethod @FSO_Token, 'DeleteFile', NULL, @WriteToFile
  EXEC @Result = sp_OADestroy @FSO_Token

  -- insert the file data into temp table
  SET @ExecSQL = 'BULK INSERT #ScoreData 
                  FROM '''+@FilePath+'''
                  WITH 
                  (
                    CODEPAGE = ''1252'',
                    FIELDTERMINATOR = '','',
                    CHECK_CONSTRAINTS
                  ) ;
                 ';

  EXECUTE sp_executesql @ExecSQL;

  -- add an identity column to uniquely identify a row
  ALTER TABLE #ScoreData
  ADD ID INT IDENTITY

  -- add a column to indicate which row has been processed
  ALTER TABLE #ScoreData
  ADD Processed BIT

  SELECT TOP 1 @FirstName = LTRIM(Firstname)
              ,@LastName  = LTRIM(LastName)
	          ,@StringScore = LTRIM(Score)
			  ,@Id        = Id
    FROM #ScoreData
   WHERE ISNULL(Processed,0) = 0
   ORDER BY Score DESC
           ,LastName DESC
           ,FirstName DESC;

  WHILE @@ROWCOUNT = 1
  BEGIN

-- write to file
--select ISNULL(@LastName,'') + ', ' + ISNULL(@FirstName,'') + ', ' + @StringScore
SELECT @WriteFile = ISNULL(@LastName,'') + ', ' + ISNULL(@FirstName,'') + ', ' + @StringScore
EXEC  WriteToFile  @WriteToFile, @WriteFile 

UPDATE #ScoreData
   SET Processed =1
 WHERE ID = @Id

SELECT TOP 1 @FirstName = LTRIM(Firstname)
            ,@LastName  = LTRIM(LastName)
			,@StringScore = LTRIM(Score)
			,@Id        = Id
  FROM #ScoreData
 WHERE ISNULL(Processed,0) = 0
 ORDER BY Score DESC
        ,LastName DESC
		,FirstName DESC;
END

END TRY 
BEGIN CATCH
  SET @ErrorMessage = ERROR_MESSAGE();
  SET @ErrorCode = ERROR_NUMBER();

  IF @ErrorCode = 4860
    RETURN 1

  
  RAISERROR('pr_OrderByScores: Error (%s) Code(%d)',16,-1,@ErrorMessage, @ErrorCode);
  RETURN

END CATCH
END


GO