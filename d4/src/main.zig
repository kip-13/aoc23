const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    var file = try std.fs.cwd().openFile("d4", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var totalWorthNums: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var winnerNums = std.AutoArrayHashMap(usize, void).init(allocator);

        const startIndex = std.mem.indexOf(u8, line, ":").?;
        var cards = std.mem.split(u8, line[startIndex + 1 ..], "|");

        var i: isize = 0;
        while (cards.next()) |card| {
            const areWinnerNums = i == 0;
            i += 1;
            var nums = std.mem.split(u8, std.mem.trim(u8, card, " "), " ");

            if (areWinnerNums) {
                while (nums.next()) |num| {
                    if (std.mem.eql(u8, num, "")) continue;

                    var realNum = try std.fmt.parseInt(usize, num, 10);
                    try winnerNums.put(realNum, {});
                }

                continue;
            }

            var doubledValue: usize = 0;

            while (nums.next()) |num| {
                if (std.mem.eql(u8, num, "")) continue;

                var realNum = try std.fmt.parseInt(usize, num, 10);

                if (!winnerNums.contains(realNum)) continue;

                if (doubledValue == 0) {
                    doubledValue = 1;
                } else {
                    doubledValue *= 2;
                }
            }

            totalWorthNums += doubledValue;
        }
    }

    try stdout.print("sol 1: {d}\n", .{totalWorthNums});
}
