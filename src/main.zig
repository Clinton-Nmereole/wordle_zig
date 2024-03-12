const std = @import("std");
const print = std.debug.print;
const Wordle = @import("wordle.zig");

pub fn main() !void {
    try Wordle.start_game();
}
