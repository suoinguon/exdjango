defmodule ExDjango.BaseConv do

  @base10_chars "0123456789"

  def get_chars(base) do
    case base do
      :base2  -> "012"
      :base10 -> @base10_chars
      :base16 -> "0123456789ABCDEF"
      :base36 -> "0123456789abcdefghijklmnopqrstuvwxyz"
      :base56 -> "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz"
      :base62 -> "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      :base64 -> "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"
      _       ->
    end
  end

  def get_sign(base) do
    case base do
      :base64 -> "$"
      _       -> "-"
    end
  end

  def convert(number, from_digits, to_digits, sign) do
    neg  = false
    if String.starts_with?(number, sign) do
      {_, number} = String.split_at(number, 1)
      neg = true
    end

    x = convert_from(String.graphemes(number), from_digits, 0)

    if x == 0 do
      {res, _} = String.split_at(to_digits, 1)
    else
      res = convert_to(x, to_digits, "")
    end

    {neg, res}
  end

  def convert_from([], _from_digits, x), do: x
  def convert_from([digit|t], from_digits, x) do
    x = x * String.length(from_digits) + Enum.find_index(String.graphemes(from_digits), fn(x) -> x == digit end)
    convert_from(t, from_digits, x)
  end

  def convert_to(x, _to_digits, res) when x <= 0, do: res
  def convert_to(x, to_digits, res) when x > 0 do
    digit = rem(x, String.length(to_digits))
    res = String.slice(to_digits, digit, 1) <> res
    x = div(x, String.length(to_digits))
    convert_to(x, to_digits, res)
  end

  def encode(base, s), do: encode(get_chars(base), get_sign(base), s)
  def encode(chars, sign, s) do
    {neg, res} = convert(s, @base10_chars, chars, "-")
    if neg, do: res = sign <> res
    res
  end

  def decode(base, s), do: decode(get_chars(base), get_sign(base), s)
  def decode(chars, sign, s) do
    {neg, res} = convert(s, chars, @base10_chars, sign)
    if neg, do: res = "-" <> res
    String.to_integer(res)
  end

end