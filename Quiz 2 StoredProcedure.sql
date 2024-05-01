CREATE OR ALTER PROCEDURE spInsertSaleItem
    @SaleID INT,
    @ItemID INT,
    @ItemType VARCHAR(50),
    @Quantity INT,
    @UnitPrice DECIMAL(10, 2)
AS
BEGIN
    
    INSERT INTO SaleItem (SaleID, ItemID, ItemType, Quantity, UnitPrice)
    VALUES (@SaleID, @ItemID, @ItemType, @Quantity, @UnitPrice);

END;
GO
