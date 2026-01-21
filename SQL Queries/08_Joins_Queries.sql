USE EventBookingDB;
GO

-- ===== 5 JOIN queries =====

-- 1) Events + Venue
SELECT e.Title, e.StartsAt, e.EndsAt, v.Name AS VenueName, v.City
FROM dbo.Events e
JOIN dbo.Venues v ON v.VenueId = e.VenueId
ORDER BY e.StartsAt;

-- 2) TicketTypes per event
SELECT e.Title, tt.Name AS TicketType, tt.Price, tt.QuantityTotal
FROM dbo.Events e
JOIN dbo.TicketTypes tt ON tt.EventId = e.EventId
ORDER BY e.Title, tt.Price;

-- 3) Orders + Customer
SELECT o.OrderNumber, o.Status, o.TotalAmount, c.Email
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
ORDER BY o.OrderedAt DESC;

-- 4) Order detail (JOIN 3+ tabeller: Orders + OrderItems + TicketTypes + Events)
SELECT
  o.OrderNumber,
  c.Email,
  e.Title AS EventTitle,
  tt.Name AS TicketType,
  oi.Quantity,
  oi.UnitPrice,
  (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
JOIN dbo.OrderItems oi ON oi.OrderId = o.OrderId
JOIN dbo.TicketTypes tt ON tt.TicketTypeId = oi.TicketTypeId
JOIN dbo.Events e ON e.EventId = tt.EventId
ORDER BY o.OrderNumber;

-- 5) Attendees list per event
SELECT e.Title, c.FirstName, c.LastName, c.Email, ea.CheckedInAt
FROM dbo.EventAttendees ea
JOIN dbo.Events e ON e.EventId = ea.EventId
JOIN dbo.Customers c ON c.CustomerId = ea.CustomerId
ORDER BY e.Title, c.LastName;

-- ===== 2 aggregation queries =====

-- A) Antal deltagare per event
SELECT e.Title, COUNT(*) AS AttendeeCount
FROM dbo.EventAttendees ea
JOIN dbo.Events e ON e.EventId = ea.EventId
GROUP BY e.Title
ORDER BY AttendeeCount DESC;

-- B) Kunder som spenderat mest (HAVING)
SELECT c.Email, SUM(o.TotalAmount) AS TotalSpent
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
WHERE o.Status = 'Paid'
GROUP BY c.Email
HAVING SUM(o.TotalAmount) >= 500
ORDER BY TotalSpent DESC;

-- ===== 1 CTE (eller subquery) =====
-- CTE: räkna beläggning (attendees vs venue capacity)
WITH AttendeeCounts AS (
  SELECT e.EventId, COUNT(ea.EventAttendeeId) AS AttendeeCount
  FROM dbo.Events e
  LEFT JOIN dbo.EventAttendees ea ON ea.EventId = e.EventId
  GROUP BY e.EventId
)
SELECT
  e.Title,
  v.Name AS VenueName,
  v.Capacity,
  ac.AttendeeCount,
  CAST((ac.AttendeeCount * 100.0) / NULLIF(v.Capacity,0) AS DECIMAL(5,2)) AS OccupancyPercent
FROM dbo.Events e
JOIN dbo.Venues v ON v.VenueId = e.VenueId
JOIN AttendeeCounts ac ON ac.EventId = e.EventId
ORDER BY OccupancyPercent ASC;

-- ===== 1 affärsfråga =====
-- "Event med låg beläggning" (under 10% av venue capacity)
WITH AttendeeCounts AS (
  SELECT e.EventId, COUNT(ea.EventAttendeeId) AS AttendeeCount
  FROM dbo.Events e
  LEFT JOIN dbo.EventAttendees ea ON ea.EventId = e.EventId
  GROUP BY e.EventId
)
SELECT TOP 5
  e.Title,
  v.Name AS VenueName,
  v.Capacity,
  ac.AttendeeCount
FROM dbo.Events e
JOIN dbo.Venues v ON v.VenueId = e.VenueId
JOIN AttendeeCounts ac ON ac.EventId = e.EventId
WHERE (ac.AttendeeCount * 1.0) / NULLIF(v.Capacity,0) < 0.10
ORDER BY ac.AttendeeCount ASC;

-- ===== VG B: Transaktionsexempel (Order + OrderItems) =====
-- Visa rollback scenario i kommentarer:
-- Om TicketTypeId inte finns eller Quantity bryter CHECK -> ROLLBACK.

BEGIN TRY
  BEGIN TRAN;

  DECLARE @CustId INT = (SELECT CustomerId FROM dbo.Customers WHERE Email='melissa@example.com');

  INSERT INTO dbo.Orders(CustomerId, OrderNumber, Status, TotalAmount)
  VALUES (@CustId, 'ORD-TXN-30001', 'Pending', 0);

  DECLARE @NewOrderId INT = SCOPE_IDENTITY();

  DECLARE @TT INT = (SELECT TOP 1 TicketTypeId FROM dbo.TicketTypes WHERE EventId=2 AND Name='Balcony');
  DECLARE @P DECIMAL(10,2) = (SELECT Price FROM dbo.TicketTypes WHERE TicketTypeId=@TT);

  INSERT INTO dbo.OrderItems(OrderId, TicketTypeId, Quantity, UnitPrice)
  VALUES (@NewOrderId, @TT, 2, @P);

  UPDATE dbo.Orders
  SET TotalAmount = (SELECT SUM(Quantity*UnitPrice) FROM dbo.OrderItems WHERE OrderId=@NewOrderId)
  WHERE OrderId=@NewOrderId;

  COMMIT;
END TRY
BEGIN CATCH
  ROLLBACK;
  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO