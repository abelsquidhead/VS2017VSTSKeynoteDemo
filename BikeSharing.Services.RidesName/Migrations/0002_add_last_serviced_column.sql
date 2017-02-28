-- <Migration ID="14e614e9-0ceb-4c84-9473-c38ee7d8d992" />
GO

PRINT N'Altering [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD
[LastServicedAt] [datetime2] NULL
GO
UPDATE dbo.bikes SET LastServicedAt = InCirculationSince
GO