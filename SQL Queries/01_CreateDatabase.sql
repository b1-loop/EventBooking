-- 02_CreateTables.sql
USE EventBookingDB;
GO

-- ===== Venues =====
CREATE TABLE dbo.Venues (
    VenueId        INT IDENTITY(1,1) CONSTRAINT PK_Venues PRIMARY KEY,
    Name           NVARCHAR(150) NOT NULL,
    AddressLine1   NVARCHAR(200) NOT NULL,
    City           NVARCHAR(100) NOT NULL,
    CountryCode    CHAR(2) NOT NULL,
    Capacity       INT NOT NULL,
    CreatedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_Venues_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Venues_Name UNIQUE (Name),
    CONSTRAINT CK_Venues_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_Venues_CountryCode CHECK (CountryCode LIKE '[A-Z][A-Z]')
);
GO

-- ===== Events =====
CREATE TABLE dbo.Events (
    EventId     INT IDENTITY(1,1) CONSTRAINT PK_Events PRIMARY KEY,
    VenueId     INT NOT NULL,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    StartsAt    DATETIME2(0) NOT NULL,
    EndsAt      DATETIME2(0) NOT NULL,
    Status      VARCHAR(20) NOT NULL CONSTRAINT DF_Events_Status DEFAULT 'Scheduled',
    CreatedAt   DATETIME2(0) NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Events_Venues FOREIGN KEY (VenueId) REFERENCES dbo.Venues(VenueId),
    CONSTRAINT CK_Events_Time CHECK (EndsAt > StartsAt),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Scheduled','Cancelled','Completed'))
);
GO

CREATE INDEX IX_Events_VenueId ON dbo.Events(VenueId);
CREATE INDEX IX_Events_StartsAt ON dbo.Events(StartsAt);
GO

-- ===== TicketTypes =====
CREATE TABLE dbo.TicketTypes (
    TicketTypeId   INT IDENTITY(1,1) CONSTRAINT PK_TicketTypes PRIMARY KEY,
    EventId        INT NOT NULL,
    Name           NVARCHAR(80) NOT NULL,
    Price          DECIMAL(10,2) NOT NULL,
    QuantityTotal  INT NOT NULL,
    QuantitySold   INT NOT NULL CONSTRAINT DF_TicketTypes_QuantitySold DEFAULT 0,
    SalesStartAt   DATETIME2(0) NULL,
    SalesEndAt     DATETIME2(0) NULL,

    CONSTRAINT FK_TicketTypes_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId),
    CONSTRAINT UQ_TicketTypes_EventId_Name UNIQUE (EventId, Name),
    CONSTRAINT CK_TicketTypes_Price CHECK (Price >= 0),
    CONSTRAINT CK_TicketTypes_QuantityTotal CHECK (QuantityTotal > 0),
    CONSTRAINT CK_TicketTypes_QuantitySold CHECK (QuantitySold >= 0),
    CONSTRAINT CK_TicketTypes_SalesWindow CHECK (
        SalesStartAt IS NULL OR SalesEndAt IS NULL OR SalesEndAt > SalesStartAt
    )
);
GO

CREATE INDEX IX_TicketTypes_EventId ON dbo.TicketTypes(EventId);
GO

-- ===== Customers =====
CREATE TABLE dbo.Customers (
    CustomerId INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FirstName  NVARCHAR(80) NOT NULL,
    LastName   NVARCHAR(80) NOT NULL,
    Email      NVARCHAR(255) NOT NULL,
    Phone      NVARCHAR(30) NULL,
    CreatedAt  DATETIME2(0) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

-- ===== Orders =====
CREATE TABLE dbo.Orders (
    OrderId     INT IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerId  INT NOT NULL,
    OrderNumber VARCHAR(30) NOT NULL,
    Status      VARCHAR(20) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT 'Pending',
    OrderedAt   DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_OrderedAt DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_Orders_TotalAmount DEFAULT 0,

    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT UQ_Orders_OrderNumber UNIQUE (OrderNumber),
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending','Paid','Cancelled','Refunded')),
    CONSTRAINT CK_Orders_TotalAmount CHECK (TotalAmount >= 0)
);
GO

CREATE INDEX IX_Orders_CustomerId ON dbo.Orders(CustomerId);
GO

-- ===== OrderItems =====
CREATE TABLE dbo.OrderItems (
    OrderItemId  INT IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderId      INT NOT NULL,
    TicketTypeId INT NOT NULL,
    Quantity     INT NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderItems_TicketTypes FOREIGN KEY (TicketTypeId) REFERENCES dbo.TicketTypes(TicketTypeId),
    CONSTRAINT UQ_OrderItems_OrderId_TicketTypeId UNIQUE (OrderId, TicketTypeId),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0)
);
GO

CREATE INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId);
GO

-- ===== Payments =====
CREATE TABLE dbo.Payments (
    PaymentId         INT IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    OrderId           INT NOT NULL,
    PaymentReference  VARCHAR(50) NOT NULL,
    Amount            DECIMAL(10,2) NOT NULL,
    Method            VARCHAR(20) NOT NULL,
    Status            VARCHAR(20) NOT NULL CONSTRAINT DF_Payments_Status DEFAULT 'Initiated',
    PaidAt            DATETIME2(0) NULL,
    CreatedAt         DATETIME2(0) NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT UQ_Payments_Reference UNIQUE (PaymentReference),
    CONSTRAINT CK_Payments_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Payments_Method CHECK (Method IN ('Card','Swish','Invoice','PayPal')),
    CONSTRAINT CK_Payments_Status CHECK (Status IN ('Initiated','Succeeded','Failed','Refunded'))
);
GO

CREATE INDEX IX_Payments_OrderId ON dbo.Payments(OrderId);
GO

-- ===== EventAttendees (M:N kopplingstabell) =====
CREATE TABLE dbo.EventAttendees (
    EventAttendeeId INT IDENTITY(1,1) CONSTRAINT PK_EventAttendees PRIMARY KEY,
    EventId         INT NOT NULL,
    CustomerId      INT NOT NULL,
    TicketTypeId    INT NOT NULL,
    CheckedInAt     DATETIME2(0) NULL,

    CONSTRAINT FK_EventAttendees_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId),
    CONSTRAINT FK_EventAttendees_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT FK_EventAttendees_TicketTypes FOREIGN KEY (TicketTypeId) REFERENCES dbo.TicketTypes(TicketTypeId),

    CONSTRAINT UQ_EventAttendees_EventId_CustomerId UNIQUE (EventId, CustomerId)
);
GO

CREATE INDEX IX_EventAttendees_EventId ON dbo.EventAttendees(EventId);
GO
