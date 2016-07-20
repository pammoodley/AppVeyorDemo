
--- CREATE Class -----------------------------------------------------------------------

EXEC tSQLt.NewTestClass 'UnitTests_OrderByScore'
GO
----------------------------------------------------------------------------------------
-- Check if Proc Exists
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_ProcExists')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_ProcExists];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_ProcExists]
AS
BEGIN
	-- Arrange
	-- Act
	-- Assert
	EXEC tSQLt.AssertObjectExists '[dbo].[pr_OrderByScore]'
END
GO
----------------------------------------------------------------------------------------
-- Check the proc parameters
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckProcParameters')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckProcParameters];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckProcParameters]
AS
BEGIN
	-- Arrange
	IF OBJECT_ID(N'tempdb..#Expected') IS NOT NULL DROP TABLE [#Expected];
	IF OBJECT_ID(N'tempdb..#Actual') IS NOT NULL DROP TABLE [#Actual];

	-- Act
	SELECT Name
	     , system_type_id
		 , max_length
		 , is_output
		 , default_value
		 , is_nullable
	  INTO #Expected
      from sys.all_parameters
     WHERE 1 = 0

	INSERT INTO #Expected (Name, system_type_id, max_length, is_output, default_value, is_nullable) 
	VALUES ('@FilePath', 231, 500, 0, NULL, 1)

	select Name
	     , system_type_id
		 , max_length
		 , is_output
		 , default_value
		 , is_nullable
	  INTO #Actual
      from sys.all_parameters
	where object_id = OBJECT_ID('pr_OrderByScore')

	-- Assert
	EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual'
	

END
GO

----------------------------------------------------------------------------------------
-- Check if file does not exist BULK INSERT fails
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_FileDoesNotExist')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_FileDoesNotExist];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_FileDoesNotExist]
AS
BEGIN
	-- Arrange
	DECLARE @Expected INT = 1;
	DECLARE @Actual INT;

	-- Act
	EXEC @Actual = dbo.pr_OrderByScore 'qwerty.tst'

	-- Assert
	EXEC tSQLt.AssertEquals @Expected, @Actual
	

END
GO

----------------------------------------------------------------------------------------
-- Check the file created is named correctly
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckResultFileName')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckResultFileName];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckResultFileName]
AS
BEGIN
	-- Arrange
	DECLARE @Expected INT = 1;
	DECLARE @Actual INT;
	DECLARE @Result int
	DECLARE @FSO_Token int

	-- remove the file if it exists
	EXEC @Result = sp_OACreate 'Scripting.FileSystemObject', @FSO_Token OUTPUT
	EXEC @Result = sp_OAMethod @FSO_Token, 'DeleteFile', NULL, 'TestFileName-graded.txt'
	EXEC @Result = sp_OADestroy @FSO_Token

	-- Act
	EXEC @Actual = dbo.pr_OrderByScore 'TestFileName.txt'

	-- check if the file exists
     EXEC master.dbo.xp_fileexist 'TestFileName-graded.txt', @Actual OUTPUT
     select  cast(@Actual as bit)

	-- Assert
	EXEC tSQLt.AssertEquals @Expected, @Actual

END
GO

----------------------------------------------------------------------------------------
-- Check the results are ordered by score, lastname, firstname
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckGoodDataResults')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckGoodDataResults];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckGoodDataResults]
AS
BEGIN
	-- Arrange
	CREATE TABLE #Expected (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score INT);
	CREATE TABLE #Actual (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score INT);
	DECLARE @ExecSQL NVARCHAR(250)

	-- Act
	INSERT INTO #Expected
	VALUES('KING' , ' MADISON', 88)
	     ,('BUNDY', ' TERESSA', 88)
         ,('SMITH', ' FRANCIS', 85)
		 ,('SMITH', ' ALLAN'  , 70)
         

	EXEC dbo.pr_OrderByScore '\TestFiles\GoodData.txt'

	SET @ExecSQL = 'BULK INSERT #Actual 
                    FROM ''\TestFiles\GoodData-graded.txt''
                    WITH 
                    (
                      FIELDTERMINATOR = '','' 
                    ) ;
                   ';

    EXECUTE sp_executesql @ExecSQL;
  
	-- Assert
	EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual'

END
GO
----------------------------------------------------------------------------------------
-- Check the ordering of data with decimal data
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckDecimalDataResults')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckDecimalDataResults];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckDecimalDataResults]
AS
BEGIN
	-- Arrange
	CREATE TABLE #Expected (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	CREATE TABLE #Actual (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	DECLARE @ExecSQL NVARCHAR(250)
	
	-- Act
	INSERT INTO #Expected
	VALUES('BUND' , ' MADISON', 88.5)
	     ,('BUND', ' TERESSA', 88.5)
         ,('SMITH', ' FRANCIS', 85)
		 ,('BUND', ' ALLAN'  , 70.1)
         

	EXEC dbo.pr_OrderByScore 'C:\Assessment\TestFiles\DecimalData.txt'

	SET @ExecSQL = 'BULK INSERT #Actual 
                    FROM ''C:\Assessment\TestFiles\DecimalData-graded.txt''
                    WITH 
                    (
                      FIELDTERMINATOR = '','' 
                    ) ;
                   ';

    EXECUTE sp_executesql @ExecSQL;
  
	-- Assert
	EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual'

END
GO

----------------------------------------------------------------------------------------
-- Check the ordering of data with decimal data
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckMissingDataResults')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckMissingDataResults];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckMissingDataResults]
AS
BEGIN
	-- Arrange
	CREATE TABLE #Expected (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	CREATE TABLE #Actual (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	DECLARE @ExecSQL NVARCHAR(250) 

	-- Act
	INSERT INTO #Expected
	VALUES('BUND' , ' MADISON', 88)
	     ,('BUND', '', 88)
		 ,(NULL, ' TERESSA'  , 88)
         ,('SMITH', ' FRANCIS', NULL)

         

	EXEC dbo.pr_OrderByScore 'C:\Assessment\TestFiles\MissingNameData.txt'

	SET @ExecSQL = 'BULK INSERT #Actual 
                    FROM ''C:\Assessment\TestFiles\MissingNameData-graded.txt''
                    WITH 
                    (
                      FIELDTERMINATOR = '','' 
                    ) ;
                   ';

    EXECUTE sp_executesql @ExecSQL;
  
	-- Assert
	EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual'

END
GO

----------------------------------------------------------------------------------------
-- Check the ordering of data with decimal data
IF EXISTS ( SELECT 1 
              FROM INFORMATION_SCHEMA.ROUTINES 
			 WHERE ROUTINE_SCHEMA='UnitTests_OrderByScore' 
			   AND ROUTINE_NAME='test_pr_OrderByScore_CheckLongNameDataResults')

	DROP PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckLongNameDataResults];	
GO

CREATE PROCEDURE [UnitTests_OrderByScore].[test_pr_OrderByScore_CheckLongNameDataResults]
AS
BEGIN
	-- Arrange
	CREATE TABLE #Expected (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	CREATE TABLE #Actual (LastName VARCHAR(MAX), FirstName VARCHAR(MAX), Score DECIMAL(6,2));
	DECLARE @ExecSQL NVARCHAR(250) 

	-- Act
	INSERT INTO #Expected
	VALUES('BUNDAIHINSHYDJjsilgkaskjsdkfjho''sdfasd' , ' TERESSA MELiSSA THE GREAT', 88)
	     ,('BUND', ' JONOTHAN MEL joskjdfhkasdkfjasldkfj', 88)
		 ,('BUND', ' MADISONkjsdfh kjdhkfjasdf'  , 88)
         ,('SMITHdfgh', ' FRANCI''S', 71)
         ,('SMITHuu', ' FRANCI''S', 61)
         ,('SMITH	wr', ' FRANCI''S', 61)
         ,('SMITHert', ' FRANCI''S', 31)
         ,('SMITHert', ' FRANCI''S', 21)
         ,('SMITH', ' FRANCI''S', 11)
         ,('SMITHS', ' FRANCI''S', 11)
         ,('SMITHSS', ' FRANCI''S', 11)
         ,('SMITH123', ' FRANCI''S', 11)
         ,('SMITHadsf', ' FRANCI''S', 11)
         ,('SMITHasdf', ' FRANCI''S', 11)
         ,('SMITHrt', ' FRANCI''S', 11)
         ,('SMITHghjk', ' FRANCI''S', 11)
         ,('SMITHsd', ' FRANCI''S', 11)
         ,('SMITHdd', ' FRANCI''S', 11)
         ,('SMITHhg', ' FRANCI''S', 11)
         ,('SMITHee', ' FRANCI''S', 11)
         ,('SMITHoo', ' FRANCI''S', 11)
         ,('SMITHpp', ' FRANCI''S', 11)   
         ,('SMITHuu', ' FRANCI''S', 11)

	EXEC dbo.pr_OrderByScore 'C:\Assessment\TestFiles\LongNameData.txt'

	SET @ExecSQL = 'BULK INSERT #Actual 
                    FROM ''C:\Assessment\TestFiles\LongNameData-graded.txt''
                    WITH 
                    (
                      FIELDTERMINATOR = '','' 
                    ) ;
                   ';

    EXECUTE sp_executesql @ExecSQL;
  
	-- Assert
	EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual'

END
GO
EXEC tSQLt.Run '[UnitTests_OrderByScore]'--.[test_pr_OrderByScore_ProcExists]'
GO

--EXEC tSQLt.Run '[UnitTests_OrderByScore].[test_pr_OrderByScore_CheckProcParameters]'
--GO

