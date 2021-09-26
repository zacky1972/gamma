defmodule GammaExla do
  import Nx.Defn

  @defn_compiler EXLA
  defn gamma32(t, gamma) do
    t = Nx.as_type(t, {:f, 32})
    n = Nx.divide(1, gamma)

    Nx.multiply(255, Nx.power(Nx.divide(t, 255), n))
    |> Nx.add(0.5)
    |> Nx.round()
    |> Nx.as_type({:u, 8})
  end

  @defn_compiler EXLA
  defn gamma16(t, gamma) do
    t = Nx.as_type(t, {:f, 16})
    n = Nx.divide(1, gamma)

    Nx.multiply(255, Nx.power(Nx.divide(t, 255), n))
    |> Nx.add(0.5)
    |> Nx.round()
    |> Nx.as_type({:u, 8})
  end
end
