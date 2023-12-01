const std = @import("std");

const humanNums: [10][]const u8 = [10][]const u8{ "zer", "one", "two", "thr", "fou", "fiv", "six", "sev", "eig", "nin" };

fn isAHumanNum(possibleNum: []u8) bool {
    for (humanNums) |num| {
        if (std.mem.eql(u8, num, possibleNum)) {
            return true;
        }
    }

    return false;
}

fn getNum(humanNum: []u8) isize {
    for (humanNums, 0..humanNums.len) |num, i| {
        if (std.mem.eql(u8, num, humanNum)) {
            return @intCast(i);
        }
    }
    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var file = try std.fs.cwd().openFile("d1", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var totalCalibration: usize = 0;
    var realCalibration: isize = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums = [2]u8{ 0, 0 };
        var possibleHumanNumber = [3]u8{ 0, 0, 0 };
        var numsCollector: [2]isize = [2]isize{ -1, 0 };
        var realNum: isize = 0;

        for (line, 0..line.len) |value, i| {
            _ = i;
            if (value >= 48 and value <= 57) {
                var num = [1]u8{value};

                if (nums[0] == 0) {
                    nums[0] = value;

                    if (numsCollector[0] == -1) {
                        numsCollector[0] = try std.fmt.parseInt(isize, &num, 10);
                    }
                }

                nums[1] = value;
                numsCollector[1] = try std.fmt.parseInt(isize, &num, 10);
            }

            if (possibleHumanNumber[0] != 0 and possibleHumanNumber[1] != 0 and possibleHumanNumber[2] != 0) {
                possibleHumanNumber[0] = possibleHumanNumber[1];
                possibleHumanNumber[1] = possibleHumanNumber[2];
                possibleHumanNumber[2] = value;
            } else {
                if (possibleHumanNumber[0] == 0) {
                    possibleHumanNumber[0] = value;
                } else {
                    if (possibleHumanNumber[1] == 0) {
                        possibleHumanNumber[1] = value;
                    } else {
                        possibleHumanNumber[2] = value;
                    }
                }
            }

            if (isAHumanNum(&possibleHumanNumber)) {
                if (numsCollector[0] == -1) {
                    numsCollector[0] = getNum(&possibleHumanNumber);
                }

                numsCollector[1] = getNum(&possibleHumanNumber);
            }
        }

        for (numsCollector) |num| {
            realNum *= 10;
            realNum += num;
        }

        realCalibration += realNum;
        if (nums[0] != 0) totalCalibration += try std.fmt.parseInt(usize, &nums, 10);
    }
    try stdout.print("sol 1: {d}\n", .{totalCalibration});
    try stdout.print("sol 2: {d}\n", .{realCalibration});
}
