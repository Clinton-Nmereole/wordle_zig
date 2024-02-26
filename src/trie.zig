const std = @import("std");
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

pub const TrieNode = struct {
    children: [26]?*TrieNode = [_]?*TrieNode{null} ** 26,
    is_word: bool = false,
};

pub const Trie = struct {
    const Self = @This();
    root: ?*TrieNode = null,

    pub fn charToIndex(char: u8) usize {
        return char - 'a';
    }

    pub fn insert(self: *Self, word: []const u8, allocator: std.mem.Allocator) !void {
        if (self.root == null) {
            self.root = try allocator.create(TrieNode);
            self.root.?.* = TrieNode{};
        }
        var node = self.root;
        for (word) |char| {
            if (node.?.children[charToIndex(char)] == null) {
                var new_node = try allocator.create(TrieNode);
                new_node.* = TrieNode{};
                node.?.children[charToIndex(char)] = new_node;
            }
            node = node.?.children[charToIndex(char)].?;
        }
        node.?.is_word = true;
    }

    pub fn search(self: *Self, word: []const u8) bool {
        if (self.root == null) return false;
        var node = self.root;
        for (word) |char| {
            if (node.?.children[charToIndex(char)] == null) return false;
            node = node.?.children[charToIndex(char)].?;
        }
        return node.?.is_word;
    }
};

pub fn main() !void {
    var trie = Trie{ .root = null };
    try trie.insert("hello", gpa_allocator);
    try trie.insert("hi", gpa_allocator);
    var word: []const u8 = "cat";
    //try trie.insert("cat", gpa_allocator);
    print("search for the word {s}: {}\n", .{ word, trie.search(word) });
}
