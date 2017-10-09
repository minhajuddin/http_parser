defmodule HttpParserTest do
  use ExUnit.Case
  doctest HttpParser

  alias HttpParser.Request

  def req(path \\ "/foobar"), do: %Request{uri: URI.parse("https://localhost:4000#{path}")}

  describe "GET create_request" do
    import HttpParser, only: [create_request: 1]

    test "uses the right verb" do
      assert "GET " <> _ = req() |> create_request
    end

    test "sets the path" do
      assert "GET /foobar HTTP" <> _ = req() |> create_request
    end

    test "sets the query string" do
      assert "GET /fooey?awesome=bar HTTP" <> _ = req("/fooey?awesome=bar#test") |> create_request
    end

    test "sets the host" do
      assert req() |> create_request =~ ~r[^GET /foobar HTTP/1.1\r\nHost: localhost]
    end

    test "uses CRLF line endings in header" do
      refute req() |> create_request |> String.replace("\r\n", "") |> String.contains?("\n")
    end

    test "appends headers" do
      r = req()
      r = %{r | headers: [{"User-Agent", "danny"}, {"Accept", "html"}]}
      assert r |> create_request =~ ~r[\r\nUser-Agent: danny\r\nAccept: html\r\n]
    end

    test "uses valid http protocol string" do
      r = req()

      r = %{r | http_version: :http1_1}
      assert r |> create_request |> String.contains?("HTTP/1.1")

      r = %{r | http_version: :http1_0}
      assert r |> create_request |> String.contains?("HTTP/1.0")
    end

    test "creates a complex request" do
      r = %Request{
        uri: URI.parse("https://dannyisawesome.com/romeo-AND-juliet?by=dire-straits#juliet-juliet"),
        headers: [
          {"Content/Type", "application/json"},
          {"Accept", "application/json"},
          {"User-Agent", "dann"},
        ]
      }
      assert r |> create_request == "\
GET /romeo-AND-juliet?by=dire-straits HTTP/1.1\r\n\
Host: dannyisawesome.com\r\n\
Content/Type: application/json\r\n\
Accept: application/json\r\n\
User-Agent: dann\r\n"
    end

  end
end
