USE EventBookingDB;
GO

-- Exempel: ta bort en specifik order (ORD-20001) och allt som blockerar den.
DECLARE @OrderId INT = (SELECT OrderId FROM dbo.Orders WHERE OrderNumber='ORD-20001');

-- 1) Delete payments först
DELETE FROM dbo.Payments WHERE OrderId = @OrderId;

-- 2) Delete orderitems
DELETE FROM dbo.OrderItems WHERE OrderId = @OrderId;

-- 3) Delete order
DELETE FROM dbo.Orders WHERE OrderId = @OrderId;

-- Exempel: ta bort attendee (kopplingstabell) - säkert
DELETE FROM dbo.EventAttendees
WHERE EventId = 1 AND CustomerId = (SELECT CustomerId FROM dbo.Customers WHERE Email='klara@example.com');

-- Vi tar inte bort kund här, för kunden kan ha fler orders/attendees.
-- Vill man ta bort kund måste man först ta bort deras orders + attendees, annars FK stoppar.
GO