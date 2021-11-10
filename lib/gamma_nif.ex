defmodule GammaNif do
  require Logger

  @moduledoc """
  Documentation for GammaNif.
  """

  @on_load :load_nif

  def load_nif do
    nif_file = '#{Application.app_dir(:gamma, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  def gamma32_nif(_size, _x, _gamma), do: raise("NIF sin32_nif/3 not implemented")

  defp gamma32_sub(t, gamma) do
    %{
      t
      | data: %{
          t.data
          | state: gamma32_nif(Nx.size(t), t.data.state, gamma)
        }
    }
  end

  def gamma32_n(x, gamma) when is_struct(x, Nx.Tensor) and is_float(gamma) do
    shape = Nx.shape(x)

    Nx.reshape(x, {Nx.size(x)})
    |> Nx.as_type({:u, 8})
    |> gamma32_sub(gamma)
    |> Nx.reshape(shape)
  end

  def gamma32_n(x, gamma) when is_number(x) and is_float(gamma) do
    gamma32_sub(Nx.tensor([x], type: {:u, 8}), gamma)
  end

  def gamma32p_nif(_size, _x, _gamma), do: raise("NIF gamma32p_nif/3 not implemented")

  defp gamma32p_sub(t, gamma) do
    %{
      t
      | data: %{
          t.data
          | state: gamma32p_nif(Nx.size(t), t.data.state, gamma)
        }
    }
  end

  def gamma32p_n(x, gamma) when is_struct(x, Nx.Tensor) and is_float(gamma) do
    shape = Nx.shape(x)

    Nx.reshape(x, {Nx.size(x)})
    |> Nx.as_type({:u, 8})
    |> gamma32p_sub(gamma)
    |> Nx.reshape(shape)
  end

  def gamma32p_n(x, gamma) when is_number(x) and is_float(gamma) do
    gamma32p_sub(Nx.tensor([x], type: {:u, 8}), gamma)
  end

  def gamma32_Maclaurin_nif(_size, _x, _gamma),
    do: raise("NIF gamma32_Maclaurin_nif/3 not implemented")

  defp gamma32_Maclaurin_sub(t, gamma) do
    %{
      t
      | data: %{
          t.data
          | state: gamma32_Maclaurin_nif(Nx.size(t), t.data.state, gamma)
        }
    }
  end

  def gamma32_Maclaurin_n(x, gamma) when is_struct(x, Nx.Tensor) and is_float(gamma) do
    shape = Nx.shape(x)

    Nx.reshape(x, {Nx.size(x)})
    |> Nx.as_type({:u, 8})
    |> gamma32_Maclaurin_sub(gamma)
    |> Nx.reshape(shape)
  end

  def gamma32_Maclaurin_n(x, gamma) when is_number(x) and is_float(gamma) do
    gamma32_Maclaurin_sub(Nx.tensor([x], type: {:u, 8}), gamma)
  end
end
