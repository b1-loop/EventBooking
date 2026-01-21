USE EventBookingDB;
GO

-- Uppdatera kundens telefon 
UPDATE dbo.Customers
SET Phone = '0709999999'
WHERE Email = 'anna@example.com';

-- Uppdatera orderstatus när betalning lyckas
UPDATE dbo.Orders
SET Status = 'Paid'
WHERE OrderNumber = 'ORD-10003';

-- Check-in en attendee 
UPDATE dbo.EventAttendees
SET CheckedInAt = SYSUTCDATETIME()
WHERE EventId = 2 AND CustomerId = 10;

SELECT 'Updates done' AS Info;
GO