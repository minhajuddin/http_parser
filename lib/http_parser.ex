defmodule HttpParser do
  @line_break "\r\n"
  @space " "

  defmodule Request do
    defstruct uri: %URI{},
      method: :get,
      http_version: :http1_1,
      headers: [], # e.g. [{"User-Agent", "Danny"}, {"Accept", "text/html"}]
      body: [] # iodata/iolist
  end

  def create_request(%Request{} = request) do
    [
      # headers
      # GET /foobar HTTP/1.1
      method_text(request.method), @space, path(request.uri), @space, http_version_text(request.http_version),
      @line_break,
      "Host: ", request.uri.host,
      @line_break,
      request.headers |> Enum.map(&render_header/1),
      @line_break,
      # end of headers
      request.body
    ]
    |> IO.iodata_to_binary()
  end

  defp render_header({name, value}), do: [name, ?:, @space, value, @line_break]

  defp http_version_text(:http1_1), do: "HTTP/1.1"
  defp http_version_text(:http1_0), do: "HTTP/1.0"

  defp path(%URI{path: nil} = uri), do: path(%{uri | path: "/"})
  defp path(%URI{path: path, query: nil}), do: path
  defp path(%URI{path: path, query: q}), do: [path, ??, q]

  # TODO: get all methods
  defp method_text(:get), do: "GET"
  defp method_text(:post), do: "POST"
  defp method_text(:head), do: "HEAD"
  defp method_text(:delete), do: "DELETE"
  defp method_text(:put), do: "PUT"
  defp method_text(:patch), do: "PATCH"
  defp method_text(:options), do: "OPTIONS"
end
