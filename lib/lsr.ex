defmodule Lsr do
  def main(args) do
    {opts, argv, _} = OptionParser.parse(args,
      aliases: [a: :all],
      switches: [all: :boolean])
    path =
      case argv do
        [] -> "."
        [path | _] -> path
      end
    opts = Keyword.merge(default_opts, opts)
    ls_r(path, opts)
  end

  defp default_opts, do: [depth: 0, end?: true, lead: "", all: false]

  defp ls_r(path, opts) do
    lead = opts[:lead] <>
      cond do
        opts[:depth] == 0 -> IO.puts opts[:lead] <> Path.basename(path); ""
        opts[:end?] -> IO.puts opts[:lead] <> "└── " <> Path.basename(path); "    "
        true -> IO.puts opts[:lead] <> "├── " <> Path.basename(path); "│   "
      end
    case File.stat!(path) do
      %{type: :directory} ->
        File.ls!(path)
        |> Enum.filter(&(opts[:all] || !(Path.basename(&1) |> String.starts_with?("."))))
        |> Enum.reverse
        |> Enum.with_index
        |> Enum.reverse
        |> Enum.map(fn {subpath, c} ->
          opts = Keyword.merge(opts, depth: opts[:depth] + 1, end?: c == 0, lead: lead)
          Path.join(path, subpath) |> ls_r(opts)
        end)
      _ ->
        :ok
    end
    :ok
  end
end
