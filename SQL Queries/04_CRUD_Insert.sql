USE EventBookingDB;
GO

-- ===== INSERT Customer =====
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone)
VALUES ('Klara','Nyberg','klara@example.com','0700000020');

-- ===== INSERT Order for that customer =====
DECLARE @CustomerId INT = (SELECT CustomerId FROM dbo.Customers WHERE Email='klara@example.com');

INSERT INTO dbo.Orders (CustomerId, OrderNumber, Status, TotalAmount)
VALUES (@CustomerId, 'ORD-20001', 'Pending', 0);

DECLARE @OrderId INT = SCOPE_IDENTITY();

-- ===== INSERT OrderItems (relaterade rader) =====
-- Välj en tickettype (t.ex. EventId=1 Standard)
DECLARE @TicketTypeId INT = (SELECT TOP 1 TicketTypeId FROM dbo.TicketTypes WHERE EventId=1 AND Name='Standard');
DECLARE @Price DECIMAL(10,2) = (SELECT Price FROM dbo.TicketTypes WHERE TicketTypeId=@TicketTypeId);

INSERT INTO dbo.OrderItems (OrderId, TicketTypeId, Quantity, UnitPrice)
VALUES (@OrderId, @TicketTypeId, 2, @Price);

-- Uppdatera TotalAmount (realistiskt)
UPDATE dbo.Orders
SET TotalAmount = (
    SELECT SUM(Quantity * UnitPrice) FROM dbo.OrderItems WHERE OrderId = @OrderId
)
WHERE OrderId = @OrderId;

-- ===== INSERT EventAttendee (kopplingstabell) =====
DECLARE @EventId INT = 1;
INSERT INTO dbo.EventAttendees (EventId, CustomerId, TicketTypeId)
VALUES (@EventId, @CustomerId, @TicketTypeId);

SELECT 'Inserted CustomerId' AS Info, @CustomerId AS Value
UNION ALL SELECT 'Inserted OrderId', @OrderId;
GO