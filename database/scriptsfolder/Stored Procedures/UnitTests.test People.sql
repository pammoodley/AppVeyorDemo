SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [UnitTests].[test People]
AS
BEGIN
	IF OBJECT_ID('actual') IS NOT NULL DROP TABLE actual;
	IF OBJECT_ID('expected') IS NOT NULL DROP TABLE expected;

	EXEC tSQLt.FakeTable 'dbo', 'People';
	INSERT INTO dbo.People (id, name) VALUES (1, 'Jon');

  
	SELECT * INTO expected FROM dbo.People;
	SELECT * INTO actual FROM dbo.ViewPeople;

	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';


END;


GO
