USE EventBookingDB;
GO

-- Venues (5)
INSERT INTO dbo.Venues (Name, AddressLine1, City, CountryCode, Capacity)
VALUES
('Gothenburg Arena', 'Avenyn 1', 'Gothenburg', 'SE', 12000),
('Stockholm Concert Hall', 'Kungsgatan 10', 'Stockholm', 'SE', 1800),
('Malmo Expo Center', 'Expo Street 3', 'Malmo', 'SE', 6000),
('Uppsala Theatre', 'Stage Road 2', 'Uppsala', 'SE', 900),
('Sofia Event Dome', 'Vitosha Blvd 50', 'Sofia', 'BG', 8000);

-- Events (6)
INSERT INTO dbo.Events (VenueId, Title, Description, StartsAt, EndsAt, Status)
VALUES
(1, 'Tech Conference 2026', 'Full-day tech talks & networking', '2026-03-12 08:30:00', '2026-03-12 17:00:00', 'Scheduled'),
(2, 'Symphony Night', 'Classical concert', '2026-02-05 19:00:00', '2026-02-05 21:30:00', 'Scheduled'),
(3, 'Startup Expo', 'Meet founders and investors', '2026-04-18 10:00:00', '2026-04-18 16:00:00', 'Scheduled'),
(1, 'eSports Finals', 'Grand finale', '2026-05-22 18:00:00', '2026-05-22 22:00:00', 'Scheduled'),
(4, 'Comedy Evening', 'Stand-up show', '2026-01-28 20:00:00', '2026-01-28 22:00:00', 'Scheduled'),
(5, 'Balkan Music Fest', 'Live festival show', '2026-06-10 18:30:00', '2026-06-10 23:00:00', 'Scheduled');

-- TicketTypes (12)
INSERT INTO dbo.TicketTypes (EventId, Name, Price, QuantityTotal, SalesStartAt, SalesEndAt)
VALUES
(1,'Standard', 499.00, 800, '2026-01-01 00:00:00', '2026-03-12 07:00:00'),
(1,'VIP',      1299.00, 150, '2026-01-01 00:00:00', '2026-03-12 07:00:00'),

(2,'Balcony',  399.00, 600, '2026-01-10 00:00:00', '2026-02-05 18:00:00'),
(2,'Front',    699.00, 300, '2026-01-10 00:00:00', '2026-02-05 18:00:00'),

(3,'Expo Pass', 199.00, 2000,'2026-02-01 00:00:00', '2026-04-18 09:00:00'),
(3,'Pro Pass',  599.00, 300, '2026-02-01 00:00:00', '2026-04-18 09:00:00'),

(4,'Standard',  349.00, 5000,'2026-03-01 00:00:00', '2026-05-22 17:00:00'),
(4,'Premium',   799.00, 800, '2026-03-01 00:00:00', '2026-05-22 17:00:00'),

(5,'Seat',      299.00, 700, '2026-01-01 00:00:00', '2026-01-28 19:00:00'),
(5,'Meet&Greet',899.00, 80,  '2026-01-01 00:00:00', '2026-01-28 19:00:00'),

(6,'General',   449.00, 6000,'2026-03-20 00:00:00', '2026-06-10 17:30:00'),
(6,'VIP',       999.00, 600, '2026-03-20 00:00:00', '2026-06-10 17:30:00');

-- Customers (10)
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone)
VALUES
('Bozhidar','Ivanov','bozhidar@example.com','0700000001'),
('Melissa','Svensson','melissa@example.com','0700000002'),
('Erik','Larsson','erik@example.com','0700000003'),
('Anna','Nilsson','anna@example.com','0700000004'),
('Johan','Karlsson','johan@example.com','0700000005'),
('Sara','Andersson','sara@example.com','0700000006'),
('Lina','Berg','lina@example.com','0700000007'),
('Oskar','Lund','oskar@example.com','0700000008'),
('Maja','Holm','maja@example.com','0700000009'),
('Nikolay','Petrov','nikolay@example.com','0700000010');

-- Orders (8)
INSERT INTO dbo.Orders (CustomerId, OrderNumber, Status, TotalAmount)
VALUES
(1,'ORD-10001','Paid',  1797.00),
(2,'ORD-10002','Paid',   399.00),
(3,'ORD-10003','Pending',0.00),
(4,'ORD-10004','Paid',   398.00),
(5,'ORD-10005','Paid',   349.00),
(6,'ORD-10006','Cancelled',0.00),
(7,'ORD-10007','Paid',   898.00),
(8,'ORD-10008','Paid',   699.00);

-- OrderItems (12)
-- OBS: UnitPrice sätts från TicketTypes.Price
INSERT INTO dbo.OrderItems (OrderId, TicketTypeId, Quantity, UnitPrice)
VALUES
(1, 2, 1, 1299.00), -- TechConf VIP
(1, 1, 1,  499.00), -- TechConf Standard
(2, 3, 1,  399.00), -- Symphony Balcony
(4, 5, 2,  199.00), -- Expo Pass x2
(5, 7, 1,  349.00), -- eSports Standard
(7,11, 2,  449.00), -- Balkan General x2
(8, 4, 1,  699.00), -- Symphony Front
(1, 5, 0+1,199.00), -- extra Expo pass 1 (sneaky, men Quantity >0 ok)
(2, 4, 0+1,699.00),
(4, 9, 1, 299.00),
(7,12, 1, 999.00),
(8,10, 1, 899.00);

-- Payments (6)
INSERT INTO dbo.Payments (OrderId, PaymentReference, Amount, Method, Status, PaidAt)
VALUES
(1,'PAY-90001',1797.00,'Card','Succeeded','2026-01-05 10:00:00'),
(2,'PAY-90002', 399.00,'Swish','Succeeded','2026-01-12 12:00:00'),
(4,'PAY-90003', 398.00,'Card','Succeeded','2026-02-02 09:30:00'),
(5,'PAY-90004', 349.00,'Invoice','Succeeded','2026-03-03 14:15:00'),
(7,'PAY-90005', 898.00,'PayPal','Succeeded','2026-04-01 16:20:00'),
(8,'PAY-90006', 699.00,'Card','Succeeded','2026-01-20 18:05:00');

-- EventAttendees (10)  (M:N bevis)
INSERT INTO dbo.EventAttendees (EventId, CustomerId, TicketTypeId, CheckedInAt)
VALUES
(1,1,2,NULL),
(1,2,1,NULL),
(2,3,3,'2026-02-05 18:40:00'),
(3,4,5,NULL),
(3,5,6,NULL),
(4,6,7,NULL),
(5,7,9,NULL),
(6,8,11,NULL),
(6,9,12,NULL),
(2,10,4,NULL);
GO