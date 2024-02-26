const std = @import("std");
const print = std.debug.print;

const wordle_grid = [6][5]?u8{
    .{null} ** 5,
    .{null} ** 5,
    .{null} ** 5,
    .{null} ** 5,
    .{null} ** 5,
    .{null} ** 5,
};

pub fn main() void {
    print("This is the wordle grid: {any}", .{&wordle_grid[0]});
}
