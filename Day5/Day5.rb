#Constants
INCREMENT = 1
ZERO = 0
DECREMENT = -1
OFFSET_INCREMENT_LIMIT = 3
INPUT_DELIMITER = "\n"

def escape_part1(values, index)
    steps = ZERO
    while index < values.count and index >= ZERO
        offset = values[index]
        values[index] += INCREMENT
        index += offset
        steps += INCREMENT
    end
    steps
end

def escape_part2(values, index)
    steps = ZERO
    while index < values.count and index >= ZERO
        offset = values[index]
        values[index] += if offset < OFFSET_INCREMENT_LIMIT then INCREMENT else DECREMENT end
        index += offset
        steps += INCREMENT
    end
    steps
end

#parameter: input -> string of integers, delimited by INPUT_DELIMITER const above
#escape is a method parameter, pass in an escape function
#call example: start "0\n3\n0\n1\n-3", method(:part1)
def start(input, escape)
    values = Array.new
    input.each_line INPUT_DELIMITER do |value|
        values.push value.to_i
    end
    escape.call values, ZERO
end

