defmodule Lsr.Mixfile do
  use Mix.Project

  def project do
    [app: :lsr,
     version: "0.1.1",
     escript: [main_module: Lsr]]
  end
end
