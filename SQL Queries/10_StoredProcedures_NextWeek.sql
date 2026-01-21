-- 10_StoredProcedures_NextWeek.sql
--  Stored Procedures + input validation + transactions.

-- Plan:
-- 1) sp_CreateOrderWithItems (@CustomerId, @ItemsJson) med TRAN
-- 2) sp_CheckInAttendee (@EventId, @CustomerId) uppdaterar CheckedInAt
-- 3) sp_GetEventDetails (@EventId) returnerar event + venue + tickettypes

-- Placeholder
-- CREATE PROCEDURE dbo.sp_CheckInAttendee
--   @EventId INT,
--   @CustomerId INT
-- AS
-- BEGIN
--   UPDATE dbo.EventAttendees
--   SET CheckedInAt = SYSUTCDATETIME()
--   WHERE EventId=@EventId AND CustomerId=@CustomerId;
-- END