defmodule HttpParser.Response do
  alias __MODULE__

  defstruct status_code: 0,
    status_text: "",
    http_version: :http1_1,
    headers: [], # e.g. [{"User-Agent", "Danny"}, {"Accept", "text/html"}]
    body: [] # iodata/iolist

  def parse(response_binary)
  when is_binary(response_binary)
  do
    with {:ok, rest_response, response} <- parse_version(response_binary),
         {:ok, rest_response, response} <- parse_status(rest_response, response),
         {:ok, rest_response, response} <- parse_headers(rest_response, response)
    do
      {:ok, %{response|body: rest_response}}
    end
  end

  defp parse_version("HTTP/1.1" <> rest_response),
    do: {:ok, rest_response, %Response{http_version: :http1_1}}
  defp parse_version("HTTP/1.0" <> rest_response),
    do: {:ok, rest_response, %Response{http_version: :http1_0}}

  defp parse_status(" " <> << status_code_str :: binary-size(3) >> <> rest_response,
                    %Response{} = response)
  do
    {status_code, ""} = Integer.parse(status_code_str)

    {" " <> status_text, rest_response} = parse_till_crlf(rest_response)

    {:ok, rest_response, %{response | status_code: status_code, status_text: status_text}}
  end

  defp parse_till_crlf(response) do
    parse_till_crlf(response, [])
  end
  defp parse_till_crlf("", acc) do
    {acc |> Enum.reverse |> IO.iodata_to_binary, ""}
  end
  defp parse_till_crlf("\r\n" <> response, acc) do
    {acc |> Enum.reverse |> IO.iodata_to_binary, response}
  end
  defp parse_till_crlf(<<ch::binary-size(1)>> <> response, acc) do
    parse_till_crlf(response, [ch | acc])
  end

  defp parse_headers(rest_response, %Response{} = response, parsed_headers \\ []) do
    case parse_till_crlf(rest_response) do
      {"", rest_response} ->
        {:ok, rest_response, %{response|headers: parsed_headers}}
      {header, rest_response} ->
        parse_headers(rest_response, response, [parse_header(header)|parsed_headers])
    end
  end

  defp parse_header(header) do
    [k, " " <> v] = String.split(header, ":", parts: 2)
    {k, v}
  end

end
