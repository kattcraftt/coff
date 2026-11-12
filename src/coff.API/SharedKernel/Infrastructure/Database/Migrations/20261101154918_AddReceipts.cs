using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace coff.API.SharedKernel.Infrastructure.Database.Migrations;

/// <inheritdoc />
public partial class AddReceipts : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "receipts",
            schema: "public",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                image_id = table.Column<Guid>(type: "uuid", nullable: false),
                merchant = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                total = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                tax = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: true),
                status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                transaction_id = table.Column<Guid>(type: "uuid", nullable: true),
                created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("pk_receipts", x => x.id);
                table.ForeignKey(
                    name: "fk_receipts_users_user_id",
                    column: x => x.user_id,
                    principalSchema: "public",
                    principalTable: "Users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "ix_receipts_user_id_created_at_utc",
            schema: "public",
            table: "receipts",
            columns: new[] { "user_id", "created_at_utc" });
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "receipts",
            schema: "public");
    }
}

