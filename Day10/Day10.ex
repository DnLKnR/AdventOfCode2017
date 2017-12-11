defmodule Const do
  @moduledoc """
  This module defines function(s) that operate on cyclic enums
  """
  @value 0
  def zero, do: @value

  @value 1
  def increment, do: @value

  @value 16
  def dense_hash_length, do: @value

  @value 64
  def hash_iterations, do: @value

  @value 255
  def sparse_hash_length, do: @value

  @string "\n"
  def newline, do: @string

  @string ","
  def comma, do: @string

  @string " "
  def space, do: @string

  @string ""
  def empty, do: @string

  @string "0"
  def hexadecimal_start, do: @string

  @list [17, 31, 73, 47, 23]
  def pre_hash_ending, do: @list
end

use Bitwise
defmodule Hashing do
  @moduledoc """
  This module defines function(s) that operate on a list of characters
  and transforms them into a hash string.

  **Not safe for real world applications**
  """

  @doc """
  Generate a hash string from list of numbers
  """
  def generate(list, base) do
    values = chunk list, base
    String.downcase(to_hexadecimal(values, base))
  end

  defp repair_hex(value, base) do
    hexadecimal = Integer.to_string(value, base)
    if String.length(hexadecimal) == 1 do
      Const.hexadecimal_start <> hexadecimal
    else
      hexadecimal
    end
  end

  defp to_hexadecimal(list, base) do to_hexadecimal(list, base, Const.zero) end

  defp to_hexadecimal(list, base, index) do
    value = Enum.at(list, index)
    hexadecimal = repair_hex(value, base)
    if index == Math.decrement(Enum.count(list)) do
      hexadecimal
    else
      hexadecimal <> to_hexadecimal(list, base, Math.increment(index))
    end
  end

  defp x_or(list) do x_or(list, Const.zero) end

  defp x_or(list, index) do
      if index == Math.decrement(Enum.count(list)) do
        Enum.at(list, index)
      else
        Enum.at(list, index) ^^^ x_or(list, Math.increment(index))
      end
  end

  defp chunk(list, size) do chunk(list, size, Const.zero) end

  defp chunk(list, size, index) do
    start = size * index
    slice = Enum.slice(list, start, size)
    if (start + size >= Enum.count(list)) do
      [x_or(slice)]
    else
      [x_or(slice)] ++ chunk(list, size, Math.increment(index))
    end
  end
end

defmodule CyclicEnum do
  @moduledoc """
  This module defines function(s) that operate on cyclic enums
  """

  @doc """
  Reverses a slice from a cyclic enumerable
  """
  def reverse_slice(enumerable, start, count) do
    length = Enum.count(enumerable)
    last = start + count
    if (last >= length) do
      front_slice = Enum.slice(enumerable, start, count)
      back_slice = Enum.slice(enumerable, Const.zero, start)
      cycled_enumerable = Enum.reverse_slice(front_slice ++ back_slice, Const.zero, count)
      repair(cycled_enumerable, start)
    else
      Enum.reverse_slice(enumerable, start, count)
    end
  end

  defp repair(list, start) do
    last = Enum.count(list) - 1
    split = last - start
    front_slice = Enum.slice(list, Math.increment(split), last - split)
    back_slice = Enum.slice(list, Const.zero, Math.increment(split))
    front_slice ++ back_slice
  end
end


defmodule Math do
  @doc """
  increases value by Const.increment
  """
  def increment value do
    value + Const.increment
  end
  @doc """
  Decreases value by Const.increment
  """
  def decrement value do
    value - Const.increment
  end
end

defmodule Main do
  @moduledoc """
  This module defines function(s) that operate on cyclic enums
  """

  def execute(filename) do
    {:ok, text} = File.read(filename)
    #clean out newline and whitespace from text
    text = String.replace(text, Const.newline, Const.empty)
    text = String.replace(text, Const.space, Const.empty)
    #compute the rotated solution and the hashcode solution from the text
    IO.inspect rotated(text)
    IO.inspect hashcode(text)
  end

  defp rotated(text) do
    enumerable = Const.zero..Const.sparse_hash_length
    values = String.split(text, Const.comma)
    lengths = to_integer_list(values)
    solve(enumerable, lengths)
  end

  defp to_integer_list(list) do to_integer_list(list, Const.zero) end

  defp to_integer_list(list, index) do
    if index == Math.decrement(Enum.count(list)) do
      [String.to_integer(Enum.at(list, index))]
    else
      [String.to_integer(Enum.at(list, index))] ++ to_integer_list(list, Math.increment(index))
    end
  end

  defp hashcode(text) do
    enumerable = Const.zero..Const.sparse_hash_length

    input = to_charlist(text)
    ascii = input ++ Const.pre_hash_ending
    final = solutions(enumerable, ascii, Const.hash_iterations)

    Hashing.generate(final, Const.dense_hash_length)
  end

  defp solutions(enumerable, lengths, solve_total) do
    solutions(enumerable, Const.zero, Const.zero, lengths, Const.zero, solve_total)
  end

  defp solutions(enumerable, start, skip, counts, solve_count, solve_total) do
    if (solve_count >= solve_total) do
      enumerable
    else
      {new_enumerable, next_start, next_skip} = solve(enumerable, start, skip, counts, Const.zero)
      solutions(new_enumerable, next_start, next_skip, counts, Math.increment(solve_count), solve_total)
    end
  end

  defp solve(enumerable, lengths) do
    {solution, _, _} = solve(enumerable, Const.zero, Const.zero, lengths, Const.zero)
    solution
  end

  defp solve(enumerable, start, skip, lengths, index) do
    if (index >= Enum.count(lengths)) do
      {enumerable, start, skip}
    else
      length = Enum.at(lengths, index)
      new_enumerable = CyclicEnum.reverse_slice(enumerable, start, length)
      new_start = rem(start + length + skip, Enum.count(new_enumerable))
      solve(new_enumerable, new_start, Math.increment(skip), lengths, Math.increment(index))
    end
  end
end

Main.execute("input.txt")
