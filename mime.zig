const std = @import("std");

pub fn getMimeType(path: []const u8) ?[]const u8 {
    const extension = std.mem.lastIndexOf(u8, path, ".") orelse return null;
    if (std.mem.eql(u8, path[extension + 1 ..], "html")) {
        return "text/html";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "css")) {
        return "text/css";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "js")) {
        return "application/javascript";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "png")) {
        return "image/png";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "jpg") or std.mem.eql(u8, path[extension + 1 ..], "jpeg")) {
        return "image/jpeg";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "gif")) {
        return "image/gif";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "svg")) {
        return "image/svg+xml";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "mp4")) {
        return "video/mp4";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "webm")) {
        return "video/webm";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "mp3")) {
        return "audio/mpeg";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "wav")) {
        return "audio/wav";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "pdf")) {
        return "application/pdf";
    } else if (std.mem.eql(u8, path[extension + 1 ..], "ico")) {
        return "image/x-icon";
    } else {
        return null;
    }
}
