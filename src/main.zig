const std = @import("std");
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();
const Wordle = @import("wordle.zig");
const Trie = @import("trie.zig").Trie;
const WordleGrid = @import("wordle.zig").WordleGrid;
const Cell = @import("wordle.zig").Cell;
const color = @import("wordle.zig").color;

pub fn main() !void {
    try Wordle.start_game();
}
