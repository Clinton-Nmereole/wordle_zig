const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa_allocator = gpa.allocator();

pub const TrieNode = struct {
    children: [26]?*TrieNode = [_]?*TrieNode{null} ** 26,
    is_word: bool = false,

    fn deinit(self: *TrieNode, allocator: std.mem.Allocator) void {
        for (&self.children) |maybe_node| {
            if (maybe_node) |node| node.deinit(allocator);
        }
        allocator.destroy(self);
    }
};

pub const Trie = struct {
    const Self = @This();
    root: ?*TrieNode = null,

    pub fn deinit(self: *Trie, allocator: std.mem.Allocator) void {
        self.root.?.deinit(allocator);
    }

    pub fn char_to_Index(char: u8) usize {
        return char - 'a';
    }

    pub fn insert(self: *Self, word: []const u8, allocator: std.mem.Allocator) !void {
        if (self.root == null) {
            self.root = try allocator.create(TrieNode);
            self.root.?.* = TrieNode{};
        }
        var node = self.root;
        for (word) |char| {
            if (node.?.children[char_to_Index(char)] == null) {
                var new_node = try allocator.create(TrieNode);
                new_node.* = TrieNode{};
                node.?.children[char_to_Index(char)] = new_node;
            }
            node = node.?.children[char_to_Index(char)].?;
        }
        node.?.is_word = true;
    }

    pub fn search(self: *Self, word: []const u8) bool {
        if (self.root == null) return false;
        var node = self.root;
        for (word) |char| {
            if (node.?.children[char_to_Index(char)] == null) return false;
            node = node.?.children[char_to_Index(char)].?;
        }
        return node.?.is_word;
    }
};

test "Trie test" {
    var trie = Trie{ .root = null };
    defer trie.deinit(testing.allocator);
    try trie.insert("hello", testing.allocator);
    try trie.insert("hi", testing.allocator);
    var word: []const u8 = "hello";
    //try trie.insert("cat", gpa_allocator);
    try testing.expectEqual(true, trie.search(word));
}
