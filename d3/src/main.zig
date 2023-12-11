const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    var file = try std.fs.cwd().openFile("d3", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var intersectionPlaces = std.AutoArrayHashMap(isize, bool).init(allocator);
    defer intersectionPlaces.deinit();

    var gearRatios = std.ArrayList([]isize).init(allocator);
    defer gearRatios.deinit();

    var places = std.ArrayList([][]u8).init(allocator);
    defer places.deinit();

    var lineNum: isize = 200;
    const step = 200;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var collector = std.ArrayList([]u8).init(allocator);
        var intersectionGearPlaces = std.AutoArrayHashMap(isize, bool).init(allocator);

        for (line, 0..line.len) |value, i| {
            var item = try std.fmt.allocPrint(allocator, "{s}", .{[_]u8{value}});
            errdefer allocator.free(item);
            try collector.append(item);

            if (value > 47 and value < 58) {
                continue;
            }

            if (value == 46) {
                continue;
            }

            var j: isize = @intCast(i);

            try intersectionPlaces.put(@intCast((j - 1) + lineNum), true);
            try intersectionPlaces.put(@intCast((j + 1) + lineNum), true);

            try intersectionPlaces.put(@intCast((j + 1) + (lineNum + step)), true);
            try intersectionPlaces.put(@intCast((j - 1) + (lineNum + step)), true);
            try intersectionPlaces.put(@intCast(j + (lineNum + step)), true);

            try intersectionPlaces.put(@intCast((j + 1) + (lineNum - step)), true);
            try intersectionPlaces.put(@intCast((j - 1) + (lineNum - step)), true);
            try intersectionPlaces.put(@intCast(j + (lineNum - step)), true);

            if (value == 42) {
                var collectorGearRatios = std.ArrayList(isize).init(allocator);

                try collectorGearRatios.append(@intCast((j - 1) + lineNum));
                try collectorGearRatios.append(@intCast((j + 1) + lineNum));

                try collectorGearRatios.append(@intCast((j + 1) + (lineNum + step)));
                try collectorGearRatios.append(@intCast((j - 1) + (lineNum + step)));
                try collectorGearRatios.append(@intCast(j + (lineNum + step)));

                try collectorGearRatios.append(@intCast((j + 1) + (lineNum - step)));
                try collectorGearRatios.append(@intCast((j - 1) + (lineNum - step)));
                try collectorGearRatios.append(@intCast(j + (lineNum - step)));

                const vGear = try collectorGearRatios.toOwnedSlice();
                
                try gearRatios.append(vGear);

                collectorGearRatios.deinit();
            }
        }

        const v = try collector.toOwnedSlice();
        try places.append(v);

        collector.deinit();
        intersectionGearPlaces.deinit();
        lineNum += step;
    }

    var intersectionNumbers = std.AutoArrayHashMap(isize, isize).init(allocator);
    defer intersectionNumbers.deinit();

    var totalPartNumbers: isize = 0;

    for (places.items, 1..places.items.len + 1) |items, row| {
        var collectedNumber: isize = 0;
        var sumNumber = false;
        var matchedKeyIntersection: isize = 0;
        for (items, 0..items.len) |item, position| {
            const keyIntersection: isize = @intCast(position + (row * step));
            if (item[0] < 48 or item[0] > 59) {
                if (sumNumber) {
                    totalPartNumbers += collectedNumber;
                    try intersectionNumbers.put(matchedKeyIntersection, collectedNumber);
                }
                collectedNumber = 0;
                sumNumber = false;
                continue;
            }

            const hasIntersection = intersectionPlaces.contains(keyIntersection);
            if (hasIntersection) matchedKeyIntersection = keyIntersection;
            sumNumber = hasIntersection or sumNumber;

            collectedNumber *= 10;
            collectedNumber += try std.fmt.parseInt(isize, item, 10);

            if (position == items.len - 1) {
                if (sumNumber) {
                    try intersectionNumbers.put(matchedKeyIntersection, collectedNumber);
                    totalPartNumbers += collectedNumber;
                }
            }
        }
    }

    var totalGearRatios: isize = 0;

    for (gearRatios.items) |gearRatioPositions| {
        var gearRatioMatchs: isize = 0;
        var gearRatio: isize = 1;

        for (gearRatioPositions) |gearRatioPosition| {
            if (gearRatioMatchs > 1) break;

            if (intersectionNumbers.get(gearRatioPosition)) |value| {
                gearRatio *= value;
                gearRatioMatchs += 1;
            }
        }

        if (gearRatioMatchs == 2) totalGearRatios += gearRatio;
    }

    try stdout.print("sol 1: {d}\n", .{totalPartNumbers});

    try stdout.print("sol 2: {d}\n", .{totalGearRatios});
}
