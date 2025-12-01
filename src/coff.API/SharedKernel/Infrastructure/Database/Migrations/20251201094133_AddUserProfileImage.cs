using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace coff.API.SharedKernel.Infrastructure.Database.Migrations;

/// <inheritdoc />
public partial class AddUserProfileImage : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "profile_image_url",
            schema: "public",
            table: "Users",
            type: "text",
            nullable: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "profile_image_url",
            schema: "public",
            table: "Users");
    }
}

