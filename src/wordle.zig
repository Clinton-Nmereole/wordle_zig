const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const Trie = @import("trie.zig").Trie;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const color = enum {
    green,
    yellow,
    gray,
};

const Cell = struct {
    value: ?u8 = null,
    color: ?color = null,
};

var winning_word: [5]u8 = undefined;

const wordle_grid = [6][5]Cell{
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
};

pub fn main() !void {
    var trie = Trie{ .root = null };
    print("This is the wordle grid: {any}\n", .{&wordle_grid[0]});
    const file = try fs.cwd().openFile("dictionary.txt", .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    const reader = buffered_reader.reader();

    var buf: [6]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 5) {
            try trie.insert(line, gpa_allocator);
        }
    }
    print("Search for the word bat: {}\n", .{trie.search("bat")});
}
