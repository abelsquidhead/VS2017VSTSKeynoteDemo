-- <Migration ID="1798932e-8ad6-4ea5-8172-daaf69dd485c" />
GO

PRINT N'Altering [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD
[LastServicedAt] [datetime2] NULL
GO
UPDATE dbo.bikes SET LastServicedAt = InCirculationSince
GO