using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("EventId", Name = "IX_TicketTypes_EventId")]
[Index("EventId", "Name", Name = "UQ_TicketTypes_EventId_Name", IsUnique = true)]
public partial class TicketType
{
    [Key]
    public int TicketTypeId { get; set; }

    public int EventId { get; set; }

    [StringLength(80)]
    public string Name { get; set; } = null!;

    [Column(TypeName = "decimal(10, 2)")]
    public decimal Price { get; set; }

    public int QuantityTotal { get; set; }

    public int QuantitySold { get; set; }

    [Precision(0)]
    public DateTime? SalesStartAt { get; set; }

    [Precision(0)]
    public DateTime? SalesEndAt { get; set; }

    [ForeignKey("EventId")]
    [InverseProperty("TicketTypes")]
    public virtual Event Event { get; set; } = null!;

    [InverseProperty("TicketType")]
    public virtual ICollection<EventAttendee> EventAttendees { get; set; } = new List<EventAttendee>();

    [InverseProperty("TicketType")]
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}
