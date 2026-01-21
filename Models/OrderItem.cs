using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("OrderId", Name = "IX_OrderItems_OrderId")]
[Index("OrderId", "TicketTypeId", Name = "UQ_OrderItems_OrderId_TicketTypeId", IsUnique = true)]
public partial class OrderItem
{
    [Key]
    public int OrderItemId { get; set; }

    public int OrderId { get; set; }

    public int TicketTypeId { get; set; }

    public int Quantity { get; set; }

    [Column(TypeName = "decimal(10, 2)")]
    public decimal UnitPrice { get; set; }

    [ForeignKey("OrderId")]
    [InverseProperty("OrderItems")]
    public virtual Order Order { get; set; } = null!;

    [ForeignKey("TicketTypeId")]
    [InverseProperty("OrderItems")]
    public virtual TicketType TicketType { get; set; } = null!;
}
