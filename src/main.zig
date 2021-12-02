const std = @import("std");

const process = std.process;
const fs = std.fs;
const io = std.io;
const Allocator = std.mem.Allocator;

pub fn main() anyerror!void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = &arena_instance.allocator;
    const print = std.io.getStdOut().writer().print;
    const args = try process.argsAlloc(arena);
    if (args.len != 2) {
        try print("Usage: zhexdump <file>\n", .{});
        return;
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const contents = try file.reader().readAllAlloc(
        arena,
        1024 * 1024 * 4,
    );
    const BYTES_PER_LINE = 16;
    var address: usize = 0;
    std.debug.print("[0x{x:0>8}] ", .{address});
    for (contents) |c| {
        if (address % BYTES_PER_LINE == 0 and address != 0) {
            try print("\n", .{});
            try print("[0x{x:0>8}] ", .{address});
        }

        switch (c) {
            0x00 => try print(".  ", .{}),
            0xFF => try print("## ", .{}),
            else => try print("{x:0>2} ", .{c}),
        }

        address += 1;
    }
}
