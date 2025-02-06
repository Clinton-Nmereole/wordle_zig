const std = @import("std");
const print = std.debug.print;
const rand = std.crypto.random;
const Wordle = @import("wordle.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa_allocator = gpa.allocator();

pub fn main() !void {
    const winner = try Wordle.set_winning_word("./dictionary.txt", gpa_allocator);
    try Wordle.start_game(winner);
}
