const std = @import("std");
const io = std.io;
const os = std.os;
const fs = std.fs;

const direction = enum { increasing, decreasing };

fn part1() !void {
    const args = os.argv;

    if (args.len != 2) {
        @panic("Usage: day02 <input_filename>");
    }

    var buf: [1024]u8 = undefined;
    var bufstream = io.fixedBufferStream(&buf);
    const temp_writer = bufstream.writer();

    const f = try fs.cwd().openFileZ(args[1], .{});
    defer f.close();
    const reader = f.reader();

    var safe: usize = 0;

    while (true) {
        buf = [_]u8{0} ** 1024;
        bufstream.reset();

        reader.streamUntilDelimiter(temp_writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                break;
            },
            else => |e| return e,
        };

        std.debug.print("{s}\n", .{buf});

        var start: usize = 0;
        var cur: usize = 0;

        var previous: ?i32 = null;
        var dir: ?direction = null;

        const res: bool = blk: while (true) {
            if (buf[cur] == ' ' or buf[cur] == 0) {
                const num = try std.fmt.parseInt(i32, buf[start..cur], 10);

                std.debug.print("looking at {d}\n", .{num});

                if (previous) |p| {
                    const a = @abs(p - num);
                    if (a < 1 or a > 3) break :blk false;
                }

                if (dir) |d| {
                    switch (d) {
                        .increasing => {
                            if (num <= previous.?) break :blk false;
                        },
                        .decreasing => {
                            if (num >= previous.?) break :blk false;
                        },
                    }
                } else if (previous) |p| {
                    dir = if (p < num) .increasing else .decreasing;
                }

                std.debug.print("buf[cur] == 0 : {any}\n", .{buf[cur] == 0});

                if (buf[cur] == 0) {
                    break :blk true;
                }
                previous = num;
                start = cur + 1;
            }
            cur += 1;
        };
        if (res) safe += 1;
        if (!res) {
            std.debug.print("NOPE\n", .{});
        }
    }

    std.debug.print("PART1 safe count = {d}\n", .{safe});
}

fn get_dir(a: i32, b: i32) direction {
    if (a < b) return .increasing;
    return .decreasing;
}

fn is_safe(levels: []i32) bool {
    var pidx: usize = 0;
    var cidx = pidx + 1;

    const d = @abs(levels[pidx] - levels[cidx]);
    if (d < 1 or d > 3) return false;
    const dir: direction = if (levels[pidx] < levels[cidx]) .increasing else .decreasing;

    while (cidx < levels.len) {
        const a = levels[pidx];
        const b = levels[cidx];

        const di = @abs(levels[pidx] - levels[cidx]);
        if (di < 1 or di > 3) return false;

        if (get_dir(a, b) != dir) return false;

        pidx += 1;
        cidx += 1;
    }

    return true;
}

fn part2() !void {
    const args = os.argv;

    if (args.len != 2) {
        @panic("Usage: day02 <input_filename>");
    }

    var buf: [1024]u8 = undefined;
    var bufstream = io.fixedBufferStream(&buf);
    const temp_writer = bufstream.writer();

    const f = try fs.cwd().openFileZ(args[1], .{});
    defer f.close();
    const reader = f.reader();

    var safe: usize = 0;

    const allocator = std.heap.page_allocator;

    blk: while (true) {
        buf = [_]u8{0} ** 1024;
        bufstream.reset();

        reader.streamUntilDelimiter(temp_writer, '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                break;
            },
            else => |e| return e,
        };

        std.debug.print("{s}\n", .{buf});

        var start: usize = 0;
        var cur: usize = 0;

        var levels = std.ArrayList(i32).init(allocator);
        defer levels.deinit();

        while (true) {
            if (buf[cur] == ' ' or buf[cur] == 0) {
                const num = try std.fmt.parseInt(i32, buf[start..cur], 10);
                try levels.append(num);

                if (buf[cur] == 0) {
                    break;
                }
                start = cur + 1;
            }
            cur += 1;
        }

        if (is_safe(levels.items)) {
            safe += 1;
            continue :blk;
        }
        std.debug.print("NOT SAFE\n", .{});

        for (levels.items, 0..) |_, idx| {
            var ignoring: []i32 = undefined;
            if (idx == 0) {
                ignoring = levels.items[1..];
            } else if (idx == levels.items.len - 1) {
                ignoring = levels.items[0..idx];
            } else {
                ignoring = try std.mem.concat(allocator, i32, &.{ levels.items[0..idx], levels.items[idx + 1 ..] });
            }
            std.debug.print("testing {any}\n", .{ignoring});
            if (is_safe(ignoring)) {
                safe += 1;
                continue :blk;
            }
        }
    }

    std.debug.print("PART2 safe count = {d}\n", .{safe});
}

pub fn main() !void {
    try part1();
    try part2();
}
