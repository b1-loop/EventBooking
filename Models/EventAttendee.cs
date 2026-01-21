using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("EventId", Name = "IX_EventAttendees_EventId")]
[Index("EventId", "CustomerId", Name = "UQ_EventAttendees_EventId_CustomerId", IsUnique = true)]
public partial class EventAttendee
{
    [Key]
    public int EventAttendeeId { get; set; }

    public int EventId { get; set; }

    public int CustomerId { get; set; }

    public int TicketTypeId { get; set; }

    [Precision(0)]
    public DateTime? CheckedInAt { get; set; }

    [ForeignKey("CustomerId")]
    [InverseProperty("EventAttendees")]
    public virtual Customer Customer { get; set; } = null!;

    [ForeignKey("EventId")]
    [InverseProperty("EventAttendees")]
    public virtual Event Event { get; set; } = null!;

    [ForeignKey("TicketTypeId")]
    [InverseProperty("EventAttendees")]
    public virtual TicketType TicketType { get; set; } = null!;
}
