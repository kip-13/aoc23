const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var file = try std.fs.cwd().openFile("d2", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    const limitRed = 12;
    const limitBlue = 14;
    const limitGreen = 13;

    var sumIds: usize = 0;
    var powerOfSets: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const indexId = std.mem.indexOf(u8, line, ":").?;
        const gameId = try std.fmt.parseInt(usize, line[5..indexId], 10);

        var subsets = std.mem.split(u8, line[indexId + 1 ..], ";");
        var shouldNotIncludeTheGame = false;

        var maxRed: usize = 0;
        var maxBlue: usize = 0;
        var maxGreen: usize = 0;

        while (subsets.next()) |subset| {
            var red: usize = 0;
            var blue: usize = 0;
            var green: usize = 0;

            var sets = std.mem.split(u8, subset, ",");
            while (sets.next()) |set| {
                const trimmedSet = std.mem.trim(u8, set, " ");
                const indexSpace = std.mem.indexOf(u8, trimmedSet, " ").?;
                const indicator = trimmedSet[indexSpace + 1 .. indexSpace + 2];

                if (std.mem.eql(u8, indicator, "r")) {
                    red = try std.fmt.parseInt(usize, trimmedSet[0..indexSpace], 10);
                    if (red > maxRed) maxRed = red;
                }
                if (std.mem.eql(u8, indicator, "b")) {
                    blue = try std.fmt.parseInt(usize, trimmedSet[0..indexSpace], 10);
                    if (blue > maxBlue) maxBlue = blue;
                }
                if (std.mem.eql(u8, indicator, "g")) {
                    green = try std.fmt.parseInt(usize, trimmedSet[0..indexSpace], 10);
                    if (green > maxGreen) maxGreen = green;
                }

                if (!shouldNotIncludeTheGame) shouldNotIncludeTheGame = red > limitRed or blue > limitBlue or green > limitGreen;
            }
        }

        if (!shouldNotIncludeTheGame) sumIds += gameId;

        powerOfSets += maxRed * maxBlue * maxGreen;
    }

    try stdout.print("sol 1: {d}\n", .{sumIds});
    try stdout.print("sol 2: {d}\n", .{powerOfSets});
}
