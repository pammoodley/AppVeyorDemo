
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [UnitTests].[test ViewPeopleId]
AS
BEGIN
	
	EXEC tSQLt.FakeTable 'dbo', 'People';
	INSERT INTO dbo.People (id, name) VALUES (1, 'Jon');
	DECLARE @actual INT;

	SELECT @actual = id FROM dbo.ViewPeopleId;

	EXEC tSQLt.AssertEquals 1, @actual;


END;



GO
