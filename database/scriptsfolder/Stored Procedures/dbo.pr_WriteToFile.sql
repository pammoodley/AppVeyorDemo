-- check if the object exists and drop it
IF OBJECT_ID('dbo.pr_WriteToFile') IS NOT NULL
  DROP PROCEDURE dbo.pr_WriteToFile;
GO

CREATE  PROCEDURE dbo.pr_WriteToFile
@File         VARCHAR(2000),  
@Text         VARCHAR(2000)
 
AS   
   
BEGIN   
 
  DECLARE @OLE            INT   
  DECLARE @FileID         INT   
   
  EXEC sp_OACreate  'Scripting.FileSystemObject', @OLE OUT   
  EXEC sp_OAMethod  @OLE, 'OpenTextFile', @FileID OUT, @File, 8, 1    
  EXEC sp_OAMethod  @FileID, 'WriteLine', Null, @Text    
  EXEC sp_OADestroy @FileID   
  EXEC sp_OADestroy @OLE   
   
END 
GO