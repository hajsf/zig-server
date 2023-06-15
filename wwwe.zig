const std = @import("std");
const fs = std.fs;
const io = std.io;
const mem = std.mem;
const mime = @import("mime.zig");

const EmbeddedFile = struct {
    path: []const u8,
    content: []const u8,
};

var embedded_files = std.ArrayList(EmbeddedFile).init(std.heap.page_allocator);

fn processDirectory(path: []const u8) !void {
    var dir = try fs.cwd().openIterableDir(path, .{});
    defer dir.close();
    var it = dir.iterate();
    while (try it.next()) |entry| {
        var entry_path_buf: [256]u8 = undefined;
        const entry_path = try std.fmt.bufPrint(&entry_path_buf, "{s}/{s}", .{ path, entry.name });
        switch (entry.kind) {
            .File => {
                const file = try fs.cwd().openFile(entry_path, .{});
                defer file.close();
                const max_file_size = 10 * 1024 * 1024; // 10 MB
                const file_content = try file.reader().readAllAlloc(std.heap.page_allocator, max_file_size);
                defer std.heap.page_allocator.free(file_content);
                try embedded_files.append(EmbeddedFile{ .path = entry_path, .content = file_content });
            },
            .Directory => {
                try processDirectory(entry_path);
            },
            else => {},
        }
    }
}

pub fn handleStatic(conn: std.net.StreamServer.Connection, buffer: *[1024]u8, path: []const u8) !void {
    _ = buffer;
    // Serve the requested file from the embedded files
    const allocator = std.heap.page_allocator;
    const file_path = try std.fmt.allocPrint(allocator, "www/{s}", .{path});
    defer allocator.free(file_path);

    var file_content: ?[]const u8 = null;
    //inline
    for (embedded_files.items) |embedded_file| {
        if (mem.eql(u8, embedded_file.path, file_path)) {
            file_content = embedded_file.content;
            break;
        }
    }

    if (file_content == null) {
        _ = try conn.stream.write("HTTP/1.1 404 Not Found\r\n\r\n");
        return;
    }

    // Determine the MIME type of the file based on its extension
    const mime_type = mime.getMimeType(file_path) orelse "application/octet-stream";

    _ = try conn.stream.write("HTTP/1.1 200 OK\r\nContent-Type: ");
    _ = try conn.stream.write(mime_type);
    _ = try conn.stream.write("\r\n\r\n");

    _ = try conn.stream.write(file_content.?);
}

//pub fn main() !void {
//    try processDirectory("www");
//}
