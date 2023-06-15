const std = @import("std");
const builtin = @import("builtin");

pub fn killtask(port: u16) !void {
    // const port: u16 = 8181;
    const allocator = std.heap.page_allocator;
    var buf: [20]u8 = undefined;
    var pid: []const u8 = undefined;
    var kill_result: []const u8 = undefined;

    if (builtin.os.tag == .macos or builtin.os.tag == .ios or builtin.os.tag == .linux) {
        const cmd = [_][]const u8{ "lsof", "-ti", std.fmt.bufPrint(&buf, "tcp:{}", .{port}) catch unreachable };
        const result = try std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = &cmd,
        });
        // Clean the tailing white spaces
        pid = std.mem.trimRight(u8, result.stdout, &std.ascii.spaces);
    } else if (builtin.os.tag == .windows) {
        const cmd = [_][]const u8{ "cmd", "/C", std.fmt.bufPrint(&buf, "netstat -aon | findstr :{}", .{port}) catch unreachable };
        const result = try std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = &cmd,
        });
        // Clean the tailing white spaces
        pid = std.mem.trimRight(u8, result.stdout, &std.ascii.spaces);
    } else {
        std.debug.print("Unsupported operating system\n", .{});
        return;
    }

    std.log.info("The pid running at port {} is {s}, let's kill it.", .{ port, pid });

    if (builtin.os.tag == .macos or builtin.os.tag == .ios or builtin.os.tag == .linux) {
        const kill = [_][]const u8{ "kill", "-9", std.fmt.bufPrint(&buf, "{s}", .{pid}) catch unreachable };
        const result = try std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = &kill,
        });
        kill_result = result.stderr;
    } else if (builtin.os.tag == .windows) {
        const kill = [_][]const u8{ "taskkill", "/F", "/PID", std.fmt.bufPrint(&buf, "{s}", .{pid}) catch unreachable };
        const result = try std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = &kill,
        });
        kill_result = result.stderr;
    }

    if (kill_result.len == 0) {
        std.log.info("killed confirmation.", .{});
    } else {
        std.log.err("{s}", .{kill_result});
    }
}
