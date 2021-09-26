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
