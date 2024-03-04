const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const Trie = @import("trie.zig").Trie;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa_allocator = gpa.allocator();

pub fn main() !void {
    try start_game();
}

pub fn start_game() !void {
    var trie = try load_dictionary();
    var buf: [1024]u8 = undefined;
    defer trie.deinit(gpa_allocator);
    var n: usize = 0;
    while (n < 6) : (n += 1) {
        print("Make guess {d}: ", .{n + 1});
        var guess = try make_guesses(&buf);
        //print("The type of guess: {any}\n", .{@TypeOf(guess)});
        //print("guess letter at 0: {any}\n", .{guess[0]});
        if (std.mem.eql(u8, guess, winning_word)) {
            print("You win!\n", .{});
            break;
        } else {
            if (guess.len != 5) {
                print("Invalid guess\n", .{});
            } else if (!trie.search(guess)) {
                print("Not a wordle word\n", .{});
            } else {
                for (guess, 0..) |char, i| {
                    if (char == winning_word[i]) {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.green };
                        print("{any}\n", .{wordle_grid[n][i]});
                    } else if (valueInArray(guess[i], winning_word)) {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.yellow };
                        print("{any}\n", .{wordle_grid[n][i]});
                    } else {
                        wordle_grid[n][i] = Cell{ .value = char, .color = color.gray };
                        print("{any}\n", .{wordle_grid[n][i]});
                    }
                }
            }
        }
    }
    print("This is the wordle grid: {any}\n", .{wordle_grid});
}

pub fn load_dictionary() !Trie {
    var trie = Trie{};
    const file = try fs.cwd().openFile("/home/clinton/Developer/Zig_projects/wordle/dictionary.txt", .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    const reader = buffered_reader.reader();

    var buf: [2048]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 5) {
            try trie.insert(line, gpa_allocator);
        }
    }
    return trie;
}

pub fn make_guesses(buf: []u8) ![]const u8 {
    //var n: usize = 0;
    var reader = std.io.getStdIn().reader();
    //var buf: [1024]u8 = undefined;
    const user_guess = try reader.readUntilDelimiter(buf, '\n');
    print("Your guess: {any}\n", .{user_guess});
    return user_guess;
}

pub var wordle_grid = [6][5]Cell{
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
    .{Cell{}} ** 5,
};

//helper function
pub fn valueInArray(value: u8, array: []const u8) bool {
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
