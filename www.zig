const std = @import("std");
const allocator = std.heap.page_allocator;
const mime = @import("mime.zig");

pub fn handleStatic(conn: std.net.StreamServer.Connection, buffer: *[1024]u8, path: []const u8) !void {
    // Serve the requested file from the www folder
    const file_path = try std.fmt.allocPrint(allocator, "www/{s}", .{path});
    defer allocator.free(file_path);
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    // Determine the MIME type of the file based on its extension
    const mime_type = mime.getMimeType(file_path) orelse "application/octet-stream";

    _ = try conn.stream.write("HTTP/1.1 200 OK\r\nContent-Type: ");
    _ = try conn.stream.write(mime_type);
    _ = try conn.stream.write("\r\n\r\n");

    var file_reader = file.reader();
    while (true) {
        const bytes_read = try file_reader.read(buffer[0..]);
        if (bytes_read == 0) break;
        _ = try conn.stream.write(buffer[0..bytes_read]);
    }
}
