use Bitwise;
require IEx;
alias Decimal, as: D;

defmodule Pi do
  @moduledoc """
  Documentation for Pi.
  """

  def main(_) do
    prompt_for_digits()
  end

  defp prompt_for_digits() do
    IO.gets("How many digits of pi do you want to see? ")
    |> parse_prompt
  end

  defp parse_prompt(n) do
    case Integer.parse(n) do
      :error ->
        IO.puts("Enter a nonnegative integer.")
        prompt_for_digits()
      {digits, "\n"} ->
        validate_nonnegative_integer(digits)
    end
  end

  defp validate_nonnegative_integer(n) when n <= 0 do
    IO.puts("Enter a nonnegative integer.")
    prompt_for_digits()
  end
  defp validate_nonnegative_integer(n) when n >= 10000 do
    IO.puts("Enter a number smaller than 10000.")
    prompt_for_digits()
  end
  defp validate_nonnegative_integer(n) do
    size = n + 2
    <<trimed_pi :: binary-size(size)>> <> _ = pi_digits(n)
    IO.puts("#{trimed_pi}")
  end

  def chudnovksy(digits) do
    # With every term one gets 14 more correct decimal digits of π,
    # so we find how many chudnovksy we need to calculate
    needed_digits = (div(digits, 14) + 1)
    0..needed_digits
    |> Enum.to_list
    |> Enum.reduce(D.new(0), fn(n, acc) -> D.add(chudnovsky_term(n, digits),acc) end)
  end

  def pi_digits(digits) do
    D.set_context(%D.Context{precision: (5 + digits)})
    D.div(D.new(1),chudnovksy(digits))
    |> D.to_string
  end

  def chudnovsky_term(n, digits) do
    D.set_context(%D.Context{precision: (5 + digits)})

    if rem(n,2) == 0 do
      sign = D.new(1)
    else
      sign = D.new(-1)
    end

    x = D.div(D.div(factorial(6*n),pow(factorial(n),3)),factorial(3*n))
    x = D.mult(x,
      D.div(
        D.add(D.new(13591409), D.mult(D.new(545140134), D.new(n))),
        pow(D.new(640320), 3*n)
      )
    )

    D.mult(x, D.div( D.mult(sign, sqrt(10005, digits)), D.new(4270934400)))
  end

  def pow(_, 0), do: D.new(1)
  def pow(base, exponent) when exponent > 0 do
    D.mult(D.new(base), pow(base, exponent-1))
  end
  def pow(base, exponent) when exponent < 0 do
    D.mult(D.div(D.new(1), D.new(base)), pow(base, exponent+1))
  end

  def factorial(0), do: D.new(1)
  def factorial(n) when n > 0 do
    D.mult(D.new(n), factorial(n-1))
  end
  def sqrt_flt(x, precision) do
    sqrt(x, precision)
    |> D.to_string
  end

  def sqrt(x, precision) do
    f = fn(prev) ->
      D.with_context %D.Context{precision: 10 + precision}, fn ->
        D.div(
          D.add(
            prev,
            D.div(D.new(x), prev)
          ),
          D.new(2)
        )
      end
    end

    fixed_point(f, D.new(x), pow(10, (-1 * precision)), f.(D.new(x)), precision)
  end

  defp fixed_point(f, guess, tolerance, next, precision) do
    D.with_context %D.Context{precision: (10 + precision)}, fn ->
      if D.to_float(D.compare(D.abs(D.add(guess, D.minus(next))), tolerance)) < 0 do
        next
      else
        fixed_point(f, next, tolerance, f.(next), precision)
      end
    end
  end



end
