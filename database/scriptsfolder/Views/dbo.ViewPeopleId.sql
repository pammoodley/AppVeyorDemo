SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[ViewPeopleId]
AS
SELECT        dbo.People.id
FROM            dbo.People

GO
