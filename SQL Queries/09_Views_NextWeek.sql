-- 09_Views_NextWeek.sql
-- Nästa vecka: Views för säkerhet + förenkla queries.

-- Plan:
-- 1) View: PublicCustomerInfo (döljer Email)
-- 2) View: EventSalesSummary (event + tickets + attendees + revenue)
-- 3) Behörigheter: GRANT SELECT på view, inte på base tables

-- Placeholder (implementeras nästa vecka)
-- CREATE VIEW dbo.PublicCustomerInfo AS
-- SELECT CustomerId, FirstName, LastName, Phone
-- FROM dbo.Customers;