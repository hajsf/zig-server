const std = @import("std");
const allocator = std.heap.page_allocator;
const index = @import("index.zig");
const login = @import("login.zig");
const www = @import("www.zig");
const embed = @import("embed.zig");

pub var debug: bool = undefined;

pub fn handleRoutes(conn: std.net.StreamServer.Connection, buffer: *[1024]u8, method: []const u8, route: []const u8) !void {
    // Handle different routes and methods
    if (std.mem.eql(u8, method, "GET")) {
        if (std.mem.eql(u8, route, "/")) {
            try index.handleIndex(conn, buffer);
        } else if (std.mem.eql(u8, route, "/login")) {
            try login.handleLogin(conn, buffer);
        } else {
            // Serve static files from the www folder
            std.log.info("The debug is: {}", .{debug});
            if (debug == true) {
                try www.handleStatic(conn, buffer, route);
            } else {
                try embed.handleStatic(conn, buffer, route);
            }
        }
    } else if (std.mem.eql(u8, method, "POST")) {
        // Serve a JSON error message for POST requests
        _ = try conn.stream.write("HTTP/1.1 400 Bad Request\r\nContent-Type: application/json\r\n\r\n{\"error\": \"POST requests are not supported\"}");
    } else {
        // Serve a 405 Method Not Allowed response for unknown methods
        _ = try conn.stream.write("HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/html\r\n\r\n<h1>405 Method Not Allowed</h1>");
    }
}
