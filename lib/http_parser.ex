defmodule HttpParser do
  @line_break "\r\n"
  @space " "

  defmodule Request do
    defstruct uri: %URI{},
      method: :get,
      http_version: :http1_1,
      headers: []
  end

  def create_request(%Request{} = rq) do
    [
      "GET ", path(rq.uri), @space, http_version_text(rq.http_version),
      @line_break,
      "Host: ", rq.uri.host,
      @line_break,
      rq.headers |> Enum.map(&render_header/1), # ends with a line_break
    ]
    |> IO.iodata_to_binary
  end

  defp render_header({name, value}), do: [name, ?:, @space, value, @line_break]

  defp http_version_text(:http1_1), do: "HTTP/1.1"
  defp http_version_text(:http1_0), do: "HTTP/1.0"

  defp path(%URI{path: path, query: nil}), do: path
  defp path(%URI{path: path, query: q}), do: [path, ??, q]
end
