defmodule HttpParserTest do
  use ExUnit.Case
  doctest HttpParser

  alias HttpParser.Response

  describe "parse" do

    setup do
      {:ok, resp} =
        Response.parse("HTTP/1.1 200 OK\r\nContent-Length: 6\r\nContent-Type: text/plain; charset=utf-8\r\nServer: Microsoft-IIS/8.0\r\nDate: Mon, 09 Oct 2017 12:59:28 GMT\r\n\r\nAwesome Danny")
      {:ok, resp: resp}
    end

    test "parses status_code", %{resp: resp} do
      assert resp.status_code == 200
    end

    test "parses status_text", %{resp: resp} do
      assert resp.status_text == "OK"
    end

    test "parses http version", %{resp: resp} do
      assert resp.http_version == :http1_1
    end

    test "parses headers", %{resp: resp} do
      assert resp.headers |> Enum.sort == [
        {"Content-Length", "6"},
        {"Content-Type", "text/plain; charset=utf-8"},
        {"Server", "Microsoft-IIS/8.0"},
        {"Date", "Mon, 09 Oct 2017 12:59:28 GMT"},
      ] |> Enum.sort
    end

    test "parses body", %{resp: resp} do
      assert resp.body == "Awesome Danny"
    end
  end

end
