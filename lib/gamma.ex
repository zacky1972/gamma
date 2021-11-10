defmodule Gamma do
  import Nx.Defn

  @moduledoc """
  Documentation for `Gamma`.
  """

  defn gamma32(t, gamma) do
    t = Nx.as_type(t, {:f, 32})
    gamma = Nx.as_type(gamma, {:f, 32})
    n = Nx.divide(1, gamma)

    Nx.multiply(255, Nx.power(Nx.divide(t, 255), n))
    |> Nx.add(0.5)
    |> Nx.round()
    |> Nx.subtract(1)
    |> Nx.as_type({:u, 8})
  end

  defn gamma16(t, gamma) do
    t = Nx.as_type(t, {:f, 16})
    gamma = Nx.as_type(gamma, {:f, 16})
    n = Nx.divide(1, gamma)

    Nx.multiply(255, Nx.power(Nx.divide(t, 255), n))
    |> Nx.add(0.5)
    |> Nx.round()
    |> Nx.subtract(1)
    |> Nx.as_type({:u, 8})
  end

  def pow_mac_i_1(_x, _y, 0) do
    1
  end

  def pow_mac_i_1(x, y, n) when is_integer(n) and n > 0 do
    (y - n + 1) * pow_mac_i_1(x, y, n - 1)
  end

  def factorial(0) do
    1
  end

  def factorial(n) when is_integer(n) and n > 0 do
    n * factorial(n - 1)
  end

  def pow(_x, 0) do
    1
  end

  def pow(x, n) when is_integer(n) and n > 0 do
    x * pow(x, n - 1)
  end

  def pow_mac_1(x, y, n) do
    0..n
    |> Enum.map(fn i -> pow_mac_i_1(x - 1, y, i) * pow(x - 1, i) / factorial(i) end)
    |> Enum.sum()
  end

  def gamma_mac_1(x, y, n) do
    (255 * pow_mac_1(x / 255, 1 / y, n)) |> round()
  end

  def gamma_2(x, y) do
    if x == 0 do
      0
    else
      (255 * fast_exp(fast_log(x / 255) * (1 / y), 10)) |> round()
    end
  end

  def coefficient(0) do
    0
  end

  def coefficient(1) do
    1 - :math.log(2)
  end

  def coefficient(2) do
    log2 = :math.log(2)
    -log2 * log2
  end

  def coefficient(n) when is_integer(n) and n > 2 do
    :math.log(2) * coefficient(n - 1)
  end

  def fast_exp(x, n) do
    log2 = :math.log(2)
    x = x / log2
    xi = Float.floor(x) |> round()
    xf = x - xi

    c = Enum.map(1..n, &(coefficient(&1) / factorial(&1)))
    xn = Enum.map(1..n, &pow(xf, &1))

    k =
      Enum.zip(c, xn)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum()

    <<0::size(1), (xi + 127)::size(8), round((xf - k) * 1024 * 1024 * 8)::size(23)>> |> parse_float()
  end

  def to_binary(v), do: <<v::size(32)>>
  def parse_float(<<v::float-32>>), do: v

  def fast_log(x) do
    <<0::size(1), exp::size(8), man::size(23)>> = <<x::float-32>>
    exp = exp - 127
    man = man / (1024 * 1024 * 8) + 1
    exp * :math.log(2) + :math.log(man)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Gamma.hello()
      :world

  """
  def hello do
    :world
  end
end
