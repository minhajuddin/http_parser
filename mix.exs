defmodule HttpParser.Mixfile do
  use Mix.Project

  def project do
    [
      app: :http_parser,
      description: "A complete HTTP parser written in pure Elixir",
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/minhajuddin/http_parser"},
      maintainers: ["Khaja Minhajuddin"],
    ]
  end
end
