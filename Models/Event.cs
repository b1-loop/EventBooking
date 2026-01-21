using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("StartsAt", Name = "IX_Events_StartsAt")]
[Index("VenueId", Name = "IX_Events_VenueId")]
public partial class Event
{
    [Key]
    public int EventId { get; set; }

    public int VenueId { get; set; }

    [StringLength(200)]
    public string Title { get; set; } = null!;

    [StringLength(1000)]
    public string? Description { get; set; }

    [Precision(0)]
    public DateTime StartsAt { get; set; }

    [Precision(0)]
    public DateTime EndsAt { get; set; }

    [StringLength(20)]
    [Unicode(false)]
    public string Status { get; set; } = null!;

    [Precision(0)]
    public DateTime CreatedAt { get; set; }

    [InverseProperty("Event")]
    public virtual ICollection<EventAttendee> EventAttendees { get; set; } = new List<EventAttendee>();

    [InverseProperty("Event")]
    public virtual ICollection<TicketType> TicketTypes { get; set; } = new List<TicketType>();

    [ForeignKey("VenueId")]
    [InverseProperty("Events")]
    public virtual Venue Venue { get; set; } = null!;
}
