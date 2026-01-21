using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("Name", Name = "UQ_Venues_Name", IsUnique = true)]
public partial class Venue
{
    [Key]
    public int VenueId { get; set; }

    [StringLength(150)]
    public string Name { get; set; } = null!;

    [StringLength(200)]
    public string AddressLine1 { get; set; } = null!;

    [StringLength(100)]
    public string City { get; set; } = null!;

    [StringLength(2)]
    [Unicode(false)]
    public string CountryCode { get; set; } = null!;

    public int Capacity { get; set; }

    [Precision(0)]
    public DateTime CreatedAt { get; set; }

    [InverseProperty("Venue")]
    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
}
