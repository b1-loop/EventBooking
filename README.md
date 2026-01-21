🎟️ EventBooking – SQL & .NET Console Project

Detta projekt är ett **realistiskt eventbokningssystem** byggt för att träna:
- relationsdatabaser
- ER-modellering
- PK/FK & constraints
- CRUD-operationer
- SQL-queries (JOINs)
- förberedelse för Views & Stored Procedures

Projektet används tillsammans med en **.NET Console App**, men fokus ligger på **databasdesign och SQL**.

---

## 🧰 Tekniker

- SQL Server
- T-SQL
- .NET Console Application (C#)
- Entity Framework Core (för vidareutveckling)
- Docker (valfritt)

---

## 🗄️ Databasöversikt

Databasen heter **EventBookingDB** och innehåller bl.a.:

- Venues (platser)
- Events
- TicketTypes
- Customers
- Orders
- OrderItems
- Payments
- EventAttendees

Relationer är implementerade med **foreign keys**, **unique constraints**, **check constraints** och **default values** för dataintegritet.

Hur är min SQL byggt: 
01_CreateDatabase.sql - skapar min databas 
02_CreateTables.sql - alla tabeller, PK,FK och constraints
03_SeedData.sql - fyller samtliga tabeller med exempel data
04_CRUD_Insert.sql - skapar data
05_CRUD_Select.sql - hämtar data 
06_CRUD_Update.sql - uppdaterar data 
07_CRUD_Delete.sql - tar bort data 
08_Joins_Queries.sql - filterar och för ihop all data
09_Views_NextWeek.sql - Skapar återanvändbara SELECTs (Views) för rapportering och enklare queries för att slippa skriva JOINs varje gång ( ej färdigt) 
10_StoredProcedures_NextWeek.sql - Kapsla in logik i databasen och Mer säkerhet (ej färdigt) 

Reflektion: 
Planeringsfasen var den mest utmanande delen av projektet eftersom systemet innehåller många kopplingar mellan tabeller, 
såsom events, venues, biljetter, ordrar och betalningar. Det krävdes noggrann planering för att få relationerna korrekta och undvika redundans.

Jag upplevde även att det var svårt att koppla databasen till Visual Studio och få samspelet mellan SQL Server, 
Entity Framework och console-applikationen att fungera som jag ville. Särskilt viktigt var att förstå connection strings, 
datakontext och hur databasen och applikationen påverkar varandra.

Trots detta gav projektet en tydlig förståelse för hur viktigt det är att ha en genomtänkt databasdesign innan 
man börjar bygga applikationslogik, samt hur SQL och .NET samverkar i praktiska system









