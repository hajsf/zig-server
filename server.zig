const std = @import("std");
const allocator = std.heap.page_allocator;
const routes = @import("routes.zig");

pub fn main() !void {
    const server_options: std.net.StreamServer.Options = .{};
    var server = std.net.StreamServer.init(server_options);
    defer server.deinit();
    const addr = try std.net.Address.parseIp("0.0.0.0", 8080);

    // Start listening on the given address
    var listen_attempts: u8 = 0;
    while (true) {
        if (server.listen(addr)) |_| {
            //  var addr_str: [64]u8 = undefined;
            //  const addr_str_len = try std.fmt.bufPrint(addr_str[0..], "{}", .{addr});
            //  const addr_str_slice = std.mem.sliceTo(addr_str[0..addr_str_len], u8);
            //  std.debug.print("Server listening on http://{}:{}/\n", .{ addr_str_slice, addr.port });
            std.log.info("Server listening on http://{s}:{s}/", .{ "localhost", "8080" });
            break;
        } else |err| {
            switch (err) {
                error.AddressInUse => {
                    std.debug.print("Failed to listen on port because it is in use by another process, trying to kill it\n", .{});
                    listen_attempts += 1;
                    if (listen_attempts >= 3) {
                        std.debug.print("Failed to listen on port after {} attempts: {}\n", .{ listen_attempts, err });
                        return;
                    }
                },
                else => {
                    std.debug.print("Failed to listen on port: {}\n", .{err});
                },
            }
        }
    }

    // Handling connections
    while (true) {
        // Accept incoming connections
        const conn = if (server.accept()) |conn| conn else |_| continue;
        // Close the connection when exiting the scope
        defer conn.stream.close();

        // Create a reader for the connection stream
        const reader = conn.stream.reader();
        // Initialize a buffer to store incoming data
        var buffer: [1024]u8 = undefined;
        var buffer_len: usize = 0;

        // Read incoming data from the connection stream
        while (true) {
            if (reader.readByte()) |byte| {
                // Append incoming bytes to the buffer
                buffer[buffer_len] = byte;
                buffer_len += 1;
                // Check if the buffer contains a double CRLF sequence indicating the end of an HTTP request header
                if (buffer_len > 3) if (std.mem.eql(u8, buffer[buffer_len - 4 .. buffer_len], "\r\n\r\n")) break;
            } else |_| {
                break;
            }
        }

        // Parse the incoming request to extract the method and route
        const request_end = std.mem.indexOf(u8, buffer[0..buffer_len], "\r\n") orelse buffer_len;
        const request_line = buffer[0..request_end];
        const method_end = std.mem.indexOf(u8, request_line, " ") orelse request_line.len;
        const method = request_line[0..method_end];
        const route_start = method_end + 1;
        const route_end = std.mem.indexOf(u8, request_line[route_start..], " ") orelse (request_line.len - route_start);
        const route = request_line[route_start .. route_start + route_end];
        try routes.handleRoutes(conn, &buffer, method, route);
    }
}
