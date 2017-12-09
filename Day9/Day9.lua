--Key characters for parsing
BEGIN_GARBAGE = "<"
END_GARBAGE = ">"
BEGIN_GROUP = "{"
END_GROUP = "}"
BEGIN_SKIP = "!"
--
INCREMENT = 1
BEGINNING_GROUP_LEVEL = 0
STARTING_INDEX = 1
DEFAULT_INITIALIZE_VALUE = 0
FILE_ARG_INDEX = 1
Garbage_Count = 0


--[[ returns the value increased by INCREMENT ]]
local function increment(value) return value + INCREMENT end

--[[ returns the value decreased by INCREMENT ]]
local function decrement(value) return value - INCREMENT end

--[[ adds garbage to the garbage count ]]
local function add_garbage() Garbage_Count = increment(Garbage_Count) end

--[[ returns valid character after skip
(where the input index is the index after the skip character) ]]
function consume_skip(index) return increment(index) end

--[[ return the next valid index after the BEGIN_GARBAGE character ]]
function consume_garbage(content, index)
  --loop until the end of the garbage character is hit
  while index <= content:len() and content:sub(index, index) ~= END_GARBAGE do
    --check for skip character since they are still valid in the garbage
    if content:sub(index, index) == BEGIN_SKIP then
      index = consume_skip(increment(index))

    --if not a skip character, then it is valid garbage
    else
      index = increment(index)

      --keep track of the garbage consumed for Part 2
      add_garbage()
    end
  end

  --reached the end of garbage character, increment beyond it
  return increment(index)
end

--[[ returns the (score, index) after evaluating a group
(which starts with a valid BEGIN_GROUP character)]]
function consume_group(content, index, level, score)
  local character = content:sub(index, index)
  local score = DEFAULT_INITIALIZE_VALUE

  --loop until the end of the group character is hit
  while index <= content:len() and character ~= END_GROUP do

    --check if the character is the beginning skip
    if character == BEGIN_SKIP then
      index = consume_skip(increment(index))

    --next, check if the character is the beginning of garbage
    elseif character == BEGIN_GARBAGE then
      index = consume_garbage(content, increment(index))

    --next, check if the character is the beginning of a group
    elseif character == BEGIN_GROUP then
      local group_score = DEFAULT_INITIALIZE_VALUE
      group_score, index = consume_group(content, increment(index), increment(level), score)
      score = score + group_score

    --if the character is none of the above, just skip forward
    else
      index = increment(index)

    end

    --get the next character for the next iteration,
    --sub returns nil for out-of-bounds, so this is safe
    character = content:sub(index, index)
  end
  return score + level, increment(index)
end

--[[ Begins the program, first argument is file name;
defaults to input.txt if not specified
execute as such:
  lua Day9.lua <filename>
]]
local function main()
  local filename = arg[FILE_ARG_INDEX]
  if not filename then
    filename = "input.txt"
  end

  local file = io.open(filename, "r")
  local data = file:read("*all")
  file:close()

  --compute the group score by starting to consume groups from the data
  local score = consume_group(data, STARTING_INDEX, BEGINNING_GROUP_LEVEL)

  --close the file
  print(string.format("Group Score: %d", score))
  print(string.format("Garbage Count: %d", Garbage_Count))

end main()
