-- <Migration ID="7eab172a-6a63-4c3b-bf6d-9410361e4661" />
GO

PRINT N'Altering [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD
[LastServicedAt] [datetime2] NULL
GO
UPDATE dbo.bikes SET LastServicedAt = InCirculationSince
GO