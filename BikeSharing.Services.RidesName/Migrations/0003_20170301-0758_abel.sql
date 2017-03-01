-- <Migration ID="b7f1a23e-9208-4c1c-ab34-06fe2fbb66bc" />
GO

PRINT N'Altering [dbo].[bikes]'
GO
ALTER TABLE [dbo].[bikes] ADD
[LastServicedAt2] [datetime2] NULL
GO
