defmodule Lsr do
  @doc false
  def main(args) do
    {opts, argv, _} = OptionParser.parse(args,
      aliases: [a: :all, i: :ignore, h: :help],
      switches: [all: :boolean, ignore: :keep])

    if opts[:help] do
      IO.puts """
      Usage: lsr [-h] [-a] [-i <ignore>]

        -h --help    Display this help message
        -a --all     Display all files, including hidden ones
        -i --ignore  Ignore the specified file(s)
      """
      exit :normal
    end

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
        |> Enum.filter(fn path ->
          (opts[:all] || !(Path.basename(path) |> String.starts_with?(".")))
          && !(Path.basename(path) in Keyword.get_values(opts, :ignore))
        end)
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
