using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using EventBooking.Models;

namespace EventBooking;

internal class Program
{
    static void Main()
    {
        var config = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: false)
            .Build();

        var cs = config.GetConnectionString("DefaultConnection");
        if (string.IsNullOrWhiteSpace(cs))
        {
            Console.WriteLine(" DefaultConnection saknas i appsettings.json");
            return;
        }

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(cs)
            .Options;

        using var db = new AppDbContext(options);

        if (!db.Database.CanConnect())
        {
            Console.WriteLine(" Kan inte ansluta till DB. Kontrollera Docker/connection string.");
            return;
        }

        while (true)
        {
            Console.Clear();
            Console.WriteLine("==================================");
            Console.WriteLine("   EventBooking  ");
            Console.WriteLine("==================================");
            Console.WriteLine("1) Lista alla Events");
            Console.WriteLine("2) Sök/filtrera Events (titel/datumintervall)");
            Console.WriteLine("3) Lista alla Customers");
            Console.WriteLine("4) Orders för customer (via email)");
            Console.WriteLine("5) Attendees för event (via EventId)");
            Console.WriteLine("6) CHECK-IN attendee (UPDATE)");
            Console.WriteLine("7) Uppdatera kundens telefon (UPDATE)");
            Console.WriteLine("8) Uppdatera orderstatus (UPDATE)");
            Console.WriteLine("9) Skapa ny customer (INSERT)");
            Console.WriteLine("10) Skapa order + orderitems (INSERT)");
            Console.WriteLine("11) Ta bort attendee (DELETE)");
            Console.WriteLine("0) Exit");
            Console.Write("Val: ");

            var choice = Console.ReadLine()?.Trim();

            try
            {
                switch (choice)
                {
                    case "1": ListEvents(db); break;
                    case "2": FilterEvents(db); break;
                    case "3": ListCustomers(db); break;
                    case "4": OrdersForCustomer(db); break;
                    case "5": AttendeesForEvent(db); break;
                    case "6": CheckInAttendee(db); break;
                    case "7": UpdateCustomerPhone(db); break;
                    case "8": UpdateOrderStatus(db); break;
                    case "9": CreateCustomer(db); break;
                    case "10": CreateOrderWithItems(db); break;
                    case "11": DeleteAttendee(db); break;
                    case "0": return;
                    default:
                        Console.WriteLine("Ogiltigt val.");
                        Pause();
                        break;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ Fel: " + ex.Message);
                Pause();
            }
        }
    }

    // ------------------------
    // READ (LIST)
    // ------------------------
    static void ListEvents(AppDbContext db)
    {
        Console.Clear();

        var events = db.Events
            .OrderBy(e => e.StartsAt)
            .Select(e => new
            {
                e.EventId,
                e.Title,
                e.StartsAt,
                e.EndsAt,
                e.Status,
                e.VenueId
            })
            .ToList();

        Console.WriteLine("=== Events ===");
        foreach (var e in events)
        {
            Console.WriteLine($"{e.EventId,3} | {e.Title,-26} | {e.StartsAt:yyyy-MM-dd HH:mm} -> {e.EndsAt:HH:mm} | {e.Status,-10} | VenueId:{e.VenueId}");
        }

        Pause();
    }

    static void ListCustomers(AppDbContext db)
    {
        Console.Clear();

        var customers = db.Customers
            .OrderBy(c => c.LastName)
            .Select(c => new { c.CustomerId, c.FirstName, c.LastName, c.Email, c.Phone })
            .ToList();

        Console.WriteLine("=== Customers ===");
        foreach (var c in customers)
        {
            Console.WriteLine($"{c.CustomerId,3} | {c.FirstName,-10} {c.LastName,-12} | {c.Email,-28} | {c.Phone}");
        }

        Pause();
    }

    // ------------------------
    // FILTER
    // ------------------------
    static void FilterEvents(AppDbContext db)
    {
        Console.Clear();
        Console.Write("Sök titel innehåller (tom = skip): ");
        var term = Console.ReadLine()?.Trim();

        Console.Write("Startdatum (yyyy-mm-dd) (tom = skip): ");
        var fromStr = Console.ReadLine()?.Trim();

        Console.Write("Slutdatum (yyyy-mm-dd) (tom = skip): ");
        var toStr = Console.ReadLine()?.Trim();

        DateTime? from = ParseDate(fromStr);
        DateTime? to = ParseDate(toStr);

        var query = db.Events.AsQueryable();

        if (!string.IsNullOrWhiteSpace(term))
            query = query.Where(e => e.Title.Contains(term));

        if (from.HasValue)
            query = query.Where(e => e.StartsAt >= from.Value);

        if (to.HasValue)
            query = query.Where(e => e.StartsAt <= to.Value.AddDays(1).AddSeconds(-1));

        var results = query
            .OrderBy(e => e.StartsAt)
            .Select(e => new { e.EventId, e.Title, e.StartsAt, e.Status })
            .ToList();

        Console.Clear();
        Console.WriteLine("=== Filterresultat ===");
        if (results.Count == 0)
        {
            Console.WriteLine("Inga events matchade.");
            Pause();
            return;
        }

        foreach (var e in results)
            Console.WriteLine($"{e.EventId,3} | {e.Title,-28} | {e.StartsAt:yyyy-MM-dd HH:mm} | {e.Status}");

        Pause();
    }

    // ------------------------
    // READ (Orders per customer)
    // ------------------------
    static void OrdersForCustomer(AppDbContext db)
    {
        Console.Clear();
        Console.Write("Customer email: ");
        var email = Console.ReadLine()?.Trim();

        if (string.IsNullOrWhiteSpace(email))
        {
            Console.WriteLine("Email kan inte vara tom.");
            Pause();
            return;
        }

        var customer = db.Customers.FirstOrDefault(c => c.Email == email);
        if (customer == null)
        {
            Console.WriteLine("Kund hittades inte.");
            Pause();
            return;
        }

        var orders = db.Orders
            .Where(o => o.CustomerId == customer.CustomerId)
            .OrderByDescending(o => o.OrderedAt)
            .Select(o => new { o.OrderId, o.OrderNumber, o.Status, o.TotalAmount, o.OrderedAt })
            .ToList();

        Console.Clear();
        Console.WriteLine($"=== Orders för {customer.Email} ===");
        if (orders.Count == 0)
        {
            Console.WriteLine("Inga ordrar.");
            Pause();
            return;
        }

        foreach (var o in orders)
            Console.WriteLine($"{o.OrderId,3} | {o.OrderNumber,-14} | {o.Status,-10} | {o.TotalAmount,8:0.00} | {o.OrderedAt:yyyy-MM-dd}");

        Pause();
    }

    // ------------------------
    // READ (Attendees per event)
    // ------------------------
    static void AttendeesForEvent(AppDbContext db)
    {
        Console.Clear();
        Console.Write("EventId: ");
        if (!int.TryParse(Console.ReadLine(), out int eventId))
        {
            Console.WriteLine("Fel EventId.");
            Pause();
            return;
        }

        var ev = db.Events.FirstOrDefault(e => e.EventId == eventId);
        if (ev == null)
        {
            Console.WriteLine("Event hittades inte.");
            Pause();
            return;
        }

        // Join via IDs (funkar även om navigation props saknas)
        var attendees = (
            from ea in db.EventAttendees
            join c in db.Customers on ea.CustomerId equals c.CustomerId
            join tt in db.TicketTypes on ea.TicketTypeId equals tt.TicketTypeId
            where ea.EventId == eventId
            orderby c.LastName
            select new
            {
                ea.EventAttendeeId,
                Name = c.FirstName + " " + c.LastName,
                c.Email,
                Ticket = tt.Name,
                ea.CheckedInAt
            }
        ).ToList();

        Console.Clear();
        Console.WriteLine($"=== Attendees: {ev.Title} ===");

        if (attendees.Count == 0)
        {
            Console.WriteLine("Inga attendees.");
            Pause();
            return;
        }

        foreach (var a in attendees)
        {
            var checkedIn = a.CheckedInAt.HasValue ? $"{a.CheckedInAt:yyyy-MM-dd HH:mm}" : " Not checked in";
            Console.WriteLine($"{a.EventAttendeeId,3} | {a.Name,-22} | {a.Email,-28} | {a.Ticket,-12} | {checkedIn}");
        }

        Pause();
    }

    // ------------------------
    // UPDATE
    // ------------------------
    static void CheckInAttendee(AppDbContext db)
    {
        Console.Clear();
        Console.Write("EventAttendeeId: ");
        if (!int.TryParse(Console.ReadLine(), out int id))
        {
            Console.WriteLine("Fel id.");
            Pause();
            return;
        }

        var attendee = db.EventAttendees.FirstOrDefault(a => a.EventAttendeeId == id);
        if (attendee == null)
        {
            Console.WriteLine("Attendee hittades inte.");
            Pause();
            return;
        }

        attendee.CheckedInAt = DateTime.UtcNow;
        db.SaveChanges();

        Console.WriteLine("Check-in sparad!");
        Pause();
    }

    static void UpdateCustomerPhone(AppDbContext db)
    {
        Console.Clear();
        Console.Write("Email: ");
        var email = Console.ReadLine()?.Trim();

        var customer = db.Customers.FirstOrDefault(c => c.Email == email);
        if (customer == null)
        {
            Console.WriteLine("Kund hittades inte.");
            Pause();
            return;
        }

        Console.Write($"Ny telefon för {customer.FirstName} {customer.LastName}: ");
        var phone = Console.ReadLine()?.Trim();

        customer.Phone = phone;
        db.SaveChanges();

        Console.WriteLine("Telefon uppdaterad!");
        Pause();
    }

    static void UpdateOrderStatus(AppDbContext db)
    {
        Console.Clear();
        Console.Write("OrderNumber (ex ORD-10001): ");
        var orderNumber = Console.ReadLine()?.Trim();

        var order = db.Orders.FirstOrDefault(o => o.OrderNumber == orderNumber);
        if (order == null)
        {
            Console.WriteLine("Order hittades inte.");
            Pause();
            return;
        }

        Console.WriteLine($"Nuvarande status: {order.Status}");
        Console.Write("Ny status (Pending/Paid/Cancelled/Refunded): ");
        var status = Console.ReadLine()?.Trim();

        order.Status = status;
        db.SaveChanges();

        Console.WriteLine(" Orderstatus uppdaterad!");
        Pause();
    }

    // ------------------------
    // INSERT
    // ------------------------
    static void CreateCustomer(AppDbContext db)
    {
        Console.Clear();
        Console.Write("FirstName: ");
        var first = Console.ReadLine()?.Trim();

        Console.Write("LastName: ");
        var last = Console.ReadLine()?.Trim();

        Console.Write("Email: ");
        var email = Console.ReadLine()?.Trim();

        Console.Write("Phone (valfritt): ");
        var phone = Console.ReadLine()?.Trim();

        if (string.IsNullOrWhiteSpace(first) || string.IsNullOrWhiteSpace(last) || string.IsNullOrWhiteSpace(email))
        {
            Console.WriteLine("FirstName, LastName, Email krävs.");
            Pause();
            return;
        }

        if (db.Customers.Any(c => c.Email == email))
        {
            Console.WriteLine("Email finns redan (UNIQUE).");
            Pause();
            return;
        }

        var customer = new Customer
        {
            FirstName = first,
            LastName = last,
            Email = email,
            Phone = phone
        };

        db.Customers.Add(customer);
        db.SaveChanges();

        Console.WriteLine($" Skapade kund med CustomerId={customer.CustomerId}");
        Pause();
    }

    static void CreateOrderWithItems(AppDbContext db)
    {
        Console.Clear();
        Console.Write("Customer email: ");
        var email = Console.ReadLine()?.Trim();

        var customer = db.Customers.FirstOrDefault(c => c.Email == email);
        if (customer == null)
        {
            Console.WriteLine("Kund hittades inte.");
            Pause();
            return;
        }

        Console.Write("EventId: ");
        if (!int.TryParse(Console.ReadLine(), out int eventId))
        {
            Console.WriteLine("Fel EventId.");
            Pause();
            return;
        }

        var ticketTypes = db.TicketTypes
            .Where(t => t.EventId == eventId)
            .OrderBy(t => t.Price)
            .Select(t => new { t.TicketTypeId, t.Name, t.Price })
            .ToList();

        if (ticketTypes.Count == 0)
        {
            Console.WriteLine("Inga TicketTypes för eventet.");
            Pause();
            return;
        }

        Console.WriteLine("TicketTypes:");
        foreach (var t in ticketTypes)
            Console.WriteLine($"{t.TicketTypeId}: {t.Name} - {t.Price:0.00} SEK");

        Console.Write("TicketTypeId: ");
        if (!int.TryParse(Console.ReadLine(), out int ticketTypeId))
        {
            Console.WriteLine("Fel TicketTypeId.");
            Pause();
            return;
        }

        var ticket = ticketTypes.FirstOrDefault(t => t.TicketTypeId == ticketTypeId);
        if (ticket == null)
        {
            Console.WriteLine("Ogiltigt TicketTypeId.");
            Pause();
            return;
        }

        Console.Write("Quantity: ");
        if (!int.TryParse(Console.ReadLine(), out int qty) || qty <= 0)
        {
            Console.WriteLine("Quantity måste vara > 0.");
            Pause();
            return;
        }

        // Transaktion (bra plus!)
        using var tx = db.Database.BeginTransaction();
        try
        {
            var orderNumber = "ORD-APP-" + DateTime.UtcNow.ToString("yyyyMMddHHmmss");

            var order = new Order
            {
                CustomerId = customer.CustomerId,
                OrderNumber = orderNumber,
                Status = "Pending",
                TotalAmount = 0,
                OrderedAt = DateTime.UtcNow
            };

            db.Orders.Add(order);
            db.SaveChanges();

            var item = new OrderItem
            {
                OrderId = order.OrderId,
                TicketTypeId = ticketTypeId,
                Quantity = qty,
                UnitPrice = ticket.Price
            };

            db.OrderItems.Add(item);
            db.SaveChanges();

            order.TotalAmount = qty * ticket.Price;
            db.SaveChanges();

            tx.Commit();

            Console.WriteLine($" Skapade order {order.OrderNumber} | Total {order.TotalAmount:0.00} SEK");
        }
        catch (Exception ex)
        {
            tx.Rollback();
            Console.WriteLine("Misslyckades. Rollback gjord.");
            Console.WriteLine(ex.Message);
        }

        Pause();
    }

    // ------------------------
    // DELETE
    // ------------------------
    static void DeleteAttendee(AppDbContext db)
    {
        Console.Clear();
        Console.Write("EventAttendeeId att ta bort: ");
        if (!int.TryParse(Console.ReadLine(), out int id))
        {
            Console.WriteLine("Fel id.");
            Pause();
            return;
        }

        var attendee = db.EventAttendees.FirstOrDefault(a => a.EventAttendeeId == id);
        if (attendee == null)
        {
            Console.WriteLine("Attendee hittades inte.");
            Pause();
            return;
        }

        db.EventAttendees.Remove(attendee);
        db.SaveChanges();

        Console.WriteLine(" Attendee borttagen!");
        Pause();
    }

    // ------------------------
    // Helpers
    // ------------------------
    static DateTime? ParseDate(string? s)
    {
        if (string.IsNullOrWhiteSpace(s)) return null;
        return DateTime.TryParse(s, out var d) ? d : null;
    }

    static void Pause()
    {
        Console.WriteLine();
        Console.Write("Tryck ENTER...");
        Console.ReadLine();
    }
}
