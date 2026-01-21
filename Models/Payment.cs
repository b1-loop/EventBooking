using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace EventBooking.Models;

[Index("OrderId", Name = "IX_Payments_OrderId")]
[Index("PaymentReference", Name = "UQ_Payments_Reference", IsUnique = true)]
public partial class Payment
{
    [Key]
    public int PaymentId { get; set; }

    public int OrderId { get; set; }

    [StringLength(50)]
    [Unicode(false)]
    public string PaymentReference { get; set; } = null!;

    [Column(TypeName = "decimal(10, 2)")]
    public decimal Amount { get; set; }

    [StringLength(20)]
    [Unicode(false)]
    public string Method { get; set; } = null!;

    [StringLength(20)]
    [Unicode(false)]
    public string Status { get; set; } = null!;

    [Precision(0)]
    public DateTime? PaidAt { get; set; }

    [Precision(0)]
    public DateTime CreatedAt { get; set; }

    [ForeignKey("OrderId")]
    [InverseProperty("Payments")]
    public virtual Order Order { get; set; } = null!;
}
