USE EventBookingDB;
GO

-- Enkel: alla kunder
SELECT CustomerId, FirstName, LastName, Email, CreatedAt
FROM dbo.Customers
ORDER BY CreatedAt DESC;

-- Filtrerad: orders för en viss kund
SELECT o.OrderId, o.OrderNumber, o.Status, o.TotalAmount, o.OrderedAt
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
WHERE c.Email = 'bozhidar@example.com'
ORDER BY o.OrderedAt DESC;

-- Visa order med items (nyttig vy i query-form)
SELECT
  o.OrderNumber,
  c.Email,
  tt.Name AS TicketType,
  e.Title AS EventTitle,
  oi.Quantity,
  oi.UnitPrice,
  (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
JOIN dbo.OrderItems oi ON oi.OrderId = o.OrderId
JOIN dbo.TicketTypes tt ON tt.TicketTypeId = oi.TicketTypeId
JOIN dbo.Events e ON e.EventId = tt.EventId
ORDER BY o.OrderNumber;
GO