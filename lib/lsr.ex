defmodule Lsr do
  def main([]), do: ls_r
  def main([path | _]), do: path |> ls_r

  def ls_r(path \\ ".", depth \\ 0, end? \\ true, lead \\ "") do
    lead = lead <>
      cond do
        depth == 0 -> IO.puts lead <> Path.basename(path); ""
        end? -> IO.puts lead <> "└── " <> Path.basename(path); "    "
        true -> IO.puts lead <> "├── " <> Path.basename(path); "│   "
      end
    case File.stat!(path) do
      %{type: :directory} ->
        File.ls!(path)
        |> Enum.reverse
        |> Enum.with_index
        |> Enum.reverse
        |> Enum.map(fn {subpath, c} ->
          Path.join(path, subpath) |> ls_r(depth + 1, c == 0, lead)
        end)
      _ ->
        :ok
    end
    :ok
  end
end
