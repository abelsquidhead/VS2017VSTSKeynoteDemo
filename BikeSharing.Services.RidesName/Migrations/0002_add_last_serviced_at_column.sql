-- <Migration ID="3b8750f5-8881-47ee-8b57-5a86696fdb7a" />
GO

PRINT N'Altering [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD
[LastServicedAt] [datetime2] NULL
GO
UPDATE dbo.bikes SET	LastServicedAt = InCirculationSince
GO