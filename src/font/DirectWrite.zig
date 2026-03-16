//! DirectWrite Font Backend
//!
//! This module implements font discovery and rendering using Windows
//! DirectWrite API. DirectWrite provides:
//! - Native font enumeration across system fonts
//! - Hardware-accelerated rendering via D3D12
//! - ClearType subpixel rendering
//! - Advanced typography via HarfBuzz integration
//!
//! Architecture:
//! - FontFactory: Enumerates and loads fonts (IDWriteFactory)
//! - FontCollection: System font collection (IDWriteFontCollection)
//! - Font: Individual font resource (IDWriteFont)
//! - GlyphMetrics: Per-glyph layout and rendering info
//! - AtlasCache: Caches rendered glyphs for performance
//!
//! Resource Management:
//! All COM objects (IDWriteFactory, IDWriteFont, IDWriteTextFormat) must
//! be properly released via IUnknown::Release(). This is NOT done in Phase 1
//! skeleton and will be added in Phase 2.
//!
//! This is a skeleton implementation following platform-specific patterns
//! from CoreText.zig (macOS) and Fontconfig implementation (Linux).

const std = @import("std");
const builtin = @import("builtin");

pub const Font = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    name: []const u8,
    size: f32,
    weight: Weight,
    italic: bool,

    // Phase 2: Add DirectWrite COM pointers
    // font_ptr: *anyopaque,  // IDWriteFont*
    // text_format_ptr: *anyopaque,  // IDWriteTextFormat*
    // NOTE: These must call Release() on all COM objects in deinit()

    pub const Weight = enum {
        thin,
        extra_light,
        light,
        normal,
        medium,
        semi_bold,
        bold,
        extra_bold,
        black,
    };

    pub fn init(
        allocator: std.mem.Allocator,
        name: []const u8,
        size: f32,
        weight: Weight,
        italic: bool,
    ) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
            .name = try allocator.dupe(u8, name),
            .size = size,
            .weight = weight,
            .italic = italic,
        };

        // TODO: Create DirectWrite text format via IDWriteFactory::CreateTextFormat
        // TODO: Set font weight and italic style

        return self;
    }

    pub fn deinit(self: *Self) void {
        // TODO: Call Release() on IDWriteFont pointer
        // TODO: Call Release() on IDWriteTextFormat pointer
        self.allocator.free(self.name);
        self.allocator.destroy(self);
    }

    pub fn getMetrics(self: *Self, char: u21) !GlyphMetrics {
        _ = self;
        _ = char;
        // TODO: Query glyph metrics from DirectWrite
        return GlyphMetrics{
            .advance_x = 8,
            .advance_y = 16,
            .left_side_bearing = 0,
            .top_side_bearing = 0,
            .width = 8,
            .height = 16,
        };
    }
};

pub const GlyphMetrics = struct {
    advance_x: i32,
    advance_y: i32,
    left_side_bearing: i32,
    top_side_bearing: i32,
    width: u32,
    height: u32,
};

pub const FontCollection = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    fonts: std.StringHashMap(*Font),

    // Phase 2: Add DirectWrite COM pointers
    // factory_ptr: *anyopaque,  // IDWriteFactory*
    // collection_ptr: *anyopaque,  // IDWriteFontCollection*
    // NOTE: These must call Release() on COM objects in deinit()

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
            .fonts = std.StringHashMap(*Font).init(allocator),
        };

        // TODO: Create DirectWrite factory via DWriteCreateFactory()
        // TODO: Get system font collection via IDWriteFactory::GetSystemFontCollection()
        // TODO: Enumerate fonts and populate HashMap

        return self;
    }

    pub fn deinit(self: *Self) void {
        var iter = self.fonts.valueIterator();
        while (iter.next()) |font| {
            font.deinit();
        }
        self.fonts.deinit();
        // TODO: Call Release() on IDWriteFactory pointer
        // TODO: Call Release() on IDWriteFontCollection pointer
        self.allocator.destroy(self);
    }

    pub fn findFont(self: *Self, name: []const u8) ?*Font {
        return self.fonts.get(name);
    }

    pub fn listFonts(self: *Self, allocator: std.mem.Allocator) ![][]const u8 {
        var names = std.ArrayList([]const u8).init(allocator);
        errdefer names.deinit();

        var iter = self.fonts.keyIterator();
        while (iter.next()) |key| {
            try names.append(key.*);
        }

        return names.toOwnedSlice();
    }
};

pub const AtlasCache = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    // TODO: Add glyph cache structure (HashMap<u21, AtlasEntry>)
    // TODO: Add D3D12 texture resource for atlas

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
        };

        // TODO: Initialize texture atlas with D3D12

        return self;
    }

    pub fn deinit(self: *Self) void {
        // TODO: Release D3D12 texture resource
        self.allocator.destroy(self);
    }

    pub fn cacheGlyph(self: *Self, char: u21, metrics: GlyphMetrics) !void {
        _ = self;
        _ = char;
        _ = metrics;
        // TODO: Render glyph and cache in atlas
    }

    pub fn getGlyph(self: *Self, char: u21) ?AtlasEntry {
        _ = self;
        _ = char;
        // TODO: Lookup glyph in cache
        return null;
    }
};

pub const AtlasEntry = struct {
    texture_x: u32,
    texture_y: u32,
    width: u32,
    height: u32,
    advance_x: i32,
    advance_y: i32,
};
