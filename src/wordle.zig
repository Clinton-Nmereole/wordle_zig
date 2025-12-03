const std = @import("std");
const print = std.debug.print;
const rand = std.crypto.random;
const fs = std.fs;
const Trie = @import("trie.zig").Trie;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa_allocator = gpa.allocator();

pub fn main() !void {
    try start_game();
}

pub fn start_game(winning_word: []const u8) !void {
    print("Welcome to Wordle!\n", .{});
    print("The winning word is: {s}\n", .{winning_word});
    var trie = try load_dictionary();
    var buf: []u8 = undefined;
    buf = try gpa_allocator.alloc(u8, 4096);
    defer trie.deinit(gpa_allocator);
    var n: usize = 1;
    while (n < 7) : (n += 1) {
        print("Make guess {d}: ", .{n});
        const guess = try make_guesses(buf);
        if (std.mem.eql(u8, guess, winning_word)) {
            print("\n", .{});
            print("You win!\n", .{});
            break;
        } else {
            if (guess.len != 5) {
                print("Invalid guess, word guessed is not a 5 letter word! Try Again\n", .{});
                n -= 1;
                continue;
            } else if (!trie.search(guess)) {
                print("Not a wordle word\n", .{});
                n -= 1;
                continue;
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
    print("\n", .{});
    print("Game over!\n", .{});
    print("\n", .{});
    print("The word was: {s}\n", .{winning_word});
    print("\n", .{});
    print("This is your wordle grid: {any}\n", .{wordle_grid});
}

pub fn load_dictionary() !Trie {
    var trie = Trie{};
    const file = try fs.cwd().openFile("./dictionary.txt", .{});
    defer file.close();

    var buf: []u8 = undefined;
    buf = try gpa_allocator.alloc(u8, 4096);
    var file_reader = file.reader(buf[0..]);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        if (line.len == 5) {
            try trie.insert(line, gpa_allocator);
        }
    } else |err| {
        if (err == error.EndOfStream) {
            //do nothing
        } else {
            return err;
        }
    }
    return trie;
}

pub fn make_guesses(buf: []u8) ![]const u8 {
    // 1. Get the stdin file handle
    // Note: We use 'var' because reading changes the file state
    var stdin_file = std.fs.File.stdin();

    // 2. Create your own buffer (e.g., 4KB on the stack)
    //var buffer: [4096]u8 = undefined;

    // 3. Create the buffered reader wrapper
    // We pass the slice 'buf[0..]' to be explicit
    var stdin_reader = stdin_file.reader(buf[0..]);

    // 4. Get the generic interface (*std.Io.Reader)
    const reader = &stdin_reader.interface;
    //const stdout = std.fs.File.stdout();
    const user_guess = try reader.takeDelimiterExclusive('\n');
    print("Your guess: {s}\n", .{user_guess});
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

pub fn readLineAt(file_path: []const u8, line_num: u32, allocator: std.mem.Allocator) ![]u8 {
    var file = try fs.cwd().openFile(file_path, .{});
    defer file.close();
    var buffer: []u8 = undefined;
    buffer = try allocator.alloc(u8, 4096);
    var file_reader = file.reader(buffer[0..]);

    //var buffered_reader = std.Io.Reader.buffered(file_reader);
    const reader = &file_reader.interface;
    var line_count: u32 = 0;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        line_count += 1;
        if (line_count == line_num) {
            return line;
        }
    } else |err| {
        if (err == error.EndOfStream) {
            //return nothing
        } else {
            return err;
        }
    }

    return error.FileLineOutOfBounds;
}

pub const color = enum {
    green,
    yellow,
    gray,
};

pub const Cell = struct {
    value: ?u8 = null,
    color: ?color = null,

    pub fn format(self: Cell, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        if (self.color == color.green) {
            try writer.print("Wordle.Cell{{\x1b[32m{c}\x1b[0m}}'", .{self.value.?});
        } else if (self.color == color.yellow) {
            try writer.print("Wordle.Cell{{\x1b[33m{c}\x1b[0m}}", .{self.value.?});
        } else if (self.color == color.gray) {
            try writer.print("Wordle.Cell{{\x1b[90m{c}\x1b[0m}}", .{self.value.?});
        }
    }
};

pub fn set_winning_word(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const random_line = rand.intRangeAtMost(u32, 0, 2315);
    const line = try readLineAt(file_path, random_line, allocator);
    return line;
}
