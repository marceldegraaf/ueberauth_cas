defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @source_url "https://github.com/marceldegraaf/ueberauth_cas"
  @version "2.1.0"

  def project do
    [
      app: :ueberauth_cas,
      version: @version,
      elixir: "~> 1.8",
      name: "Ueberauth CAS",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.6.3"},
      {:httpoison, "~> 1.7.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:excoveralls, "~> 0.13.1", only: :test},
      {:inch_ex, "~> 2.0.0", only: :docs},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mock, "~> 0.3.5", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "An Ueberauth strategy for CAS authentication.",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md"],
      maintainers: ["Marcel de Graaf", "Niko Strijbol"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/ueberauth_cas/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
