using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace coff.API.SharedKernel.Infrastructure.Database.Migrations;

/// <inheritdoc />
public partial class AddCategoryAndTransactionTables_UpdateAccount : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "plaid_account_id",
            schema: "public",
            table: "accounts",
            type: "text",
            nullable: true);

        migrationBuilder.CreateTable(
            name: "categories",
            schema: "public",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("pk_categories", x => x.id);
                table.ForeignKey(
                    name: "fk_categories_users_user_id",
                    column: x => x.user_id,
                    principalSchema: "public",
                    principalTable: "Users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "transactions",
            schema: "public",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                payee = table.Column<string>(type: "text", nullable: false),
                notes = table.Column<string>(type: "text", nullable: true),
                date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                account_id = table.Column<Guid>(type: "uuid", nullable: false),
                category_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("pk_transactions", x => x.id);
                table.ForeignKey(
                    name: "fk_transactions_accounts_account_id",
                    column: x => x.account_id,
                    principalSchema: "public",
                    principalTable: "accounts",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "fk_transactions_categories_category_id",
                    column: x => x.category_id,
                    principalSchema: "public",
                    principalTable: "categories",
                    principalColumn: "id",
                    onDelete: ReferentialAction.SetNull);
            });

        migrationBuilder.CreateIndex(
            name: "ix_categories_user_id",
            schema: "public",
            table: "categories",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "ix_transactions_account_id",
            schema: "public",
            table: "transactions",
            column: "account_id");

        migrationBuilder.CreateIndex(
            name: "ix_transactions_category_id",
            schema: "public",
            table: "transactions",
            column: "category_id");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "transactions",
            schema: "public");

        migrationBuilder.DropTable(
            name: "categories",
            schema: "public");

        migrationBuilder.DropColumn(
            name: "plaid_account_id",
            schema: "public",
            table: "accounts");
    }
}
