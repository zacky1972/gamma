Application.put_env(:exla, :clients,
  default: [platform: :host],
  cuda: [platform: :cuda]
)

input_u8 = Nx.iota({255}, type: {:u, 8})

result = Gamma.gamma32(input_u8, 1.5)
^result = GammaNif.gamma32_n(input_u8, 1.5)
^result = GammaNif.gamma32p_n(input_u8, 1.5)
^result = GammaNif.gamma32_Maclaurin_n(input_u8, 1.5)

benches =   %{
  "nx_32" => fn -> Gamma.gamma32(input_u8, 1.5) end,
  "nx_16" => fn -> Gamma.gamma16(input_u8, 1.5) end,
  "xla jit-cpu 32" => fn -> GammaExla.gamma32(input_u8, 1.5) end,
  "xla jit-cpu 16" => fn -> GammaExla.gamma16(input_u8, 1.5) end,
  "nif_32" => fn -> GammaNif.gamma32_n(input_u8, 1.5) end,
  "nif_32p" => fn -> GammaNif.gamma32p_n(input_u8, 1.5) end,
  "nif_32_Maclaurin" => fn -> GammaNif.gamma32_Maclaurin_n(input_u8, 1.5) end
}

benches =
  if System.get_env("EXLA_TARGET") == "cuda" do
    dt8 = Nx.backend_transfer(input_u8, {EXLA.DeviceBackend, client: :cuda})

    Map.merge(benches, %{
      "xla jit-gpu 32" => fn -> GammaExlaCuda.gamma32(dt8, 1.5) end,
      "xla jit-gpu 16" => fn -> GammaExlaCuda.gamma16(dt8, 1.5) end,
      "xla jit-gpu keep 32" => {fn -> GammaExlaCudaKeep.gamma32(dt8, 1.5) end, after_each: &Nx.backend_deallocate/1},
      "xla jit-gpu keep 16" => {fn -> GammaExlaCudaKeep.gamma16(dt8, 1.5) end, after_each: &Nx.backend_deallocate/1}
    })
  else
    benches
  end

Benchee.run(
  benches,
  time: 10,
  memory_time: 2
) \
|> then(fn _ -> :ok end)
