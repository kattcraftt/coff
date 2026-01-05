using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace coff.API.SharedKernel.Infrastructure.Database.Migrations;

/// <inheritdoc />
public partial class ChangeTypeUserProfileImage : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "profile_image_url",
            schema: "public",
            table: "Users");

        migrationBuilder.AddColumn<Guid>(
            name: "profile_image_id",
            schema: "public",
            table: "Users",
            type: "uuid",
            nullable: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "profile_image_id",
            schema: "public",
            table: "Users");

        migrationBuilder.AddColumn<string>(
            name: "profile_image_url",
            schema: "public",
            table: "Users",
            type: "text",
            nullable: true);
    }
}

