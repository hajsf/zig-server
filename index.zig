const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn handleIndex(conn: std.net.StreamServer.Connection, buffer: *[1024]u8) !void {
    // Serve the index.html file from the www folder
    _ = try conn.stream.write("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n");
    const file = try std.fs.cwd().openFile("www/index.html", .{});
    defer file.close();
    var file_reader = file.reader();
    while (true) {
        const bytes_read = try file_reader.read(buffer[0..]);
        if (bytes_read == 0) break;
        _ = try conn.stream.write(buffer[0..bytes_read]);
    }
}
