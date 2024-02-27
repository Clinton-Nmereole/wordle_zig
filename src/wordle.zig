const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const Trie = @import("trie.zig").Trie;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

//helper function

fn valueInArray(value: u8, array: []const u8) bool {
    for (array) |num| {
        if (value == num) {
            return true;
        }
    }
    return false;
}

pub const color = enum {
    green,
    yellow,
    gray,
};

pub const Cell = struct {
    value: ?u8 = null,
    color: ?color = null,
};

pub var winning_word: *const [5]u8 = "sunny";

pub var wordle_grid = [6][5]Cell{
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
};

pub fn load_dictionary() !Trie {
    var trie = Trie{};
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
    return trie;
}

pub fn make_guesses() ![]u8 {
    //var n: usize = 0;
    var reader = std.io.getStdIn().reader();
    var buf: [6]u8 = undefined;
    var user_guess = try reader.readUntilDelimiter(&buf, '\n');
    //print("Your guess: {s}\n", .{user_guess});
    return user_guess;
}

pub fn start_game() !void {
    //var trie = try load_dictionary();
    var n: usize = 0;
    while (n < 6) : (n += 1) {
        print("Make guess {d}: ", .{n + 1});
        var guess = try make_guesses();
        if (std.mem.eql(u8, guess, winning_word)) {
            print("You win!\n", .{});
            break;
        } else {
            if (guess.len != 5) {
                print("Invalid guess\n", .{});
            } else {
                for (guess, 0..5) |char, i| {
                    if (guess[i] == winning_word[i]) {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.green };
                    } else if (valueInArray(guess[i], winning_word)) {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.yellow };
                    } else {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.gray };
                    }
                }
            }
        }
    }
    print("This is the wordle grid: {any}\n", .{wordle_grid});
}

pub fn main() !void {
    try start_game();
}
