defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @source_url "https://github.com/marceldegraaf/ueberauth_cas"
  @version "2.3.1"

  def project do
    [
      app: :ueberauth_cas,
      version: @version,
      elixir: "~> 1.9",
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
    # Needed for compatibility with old elixir versions :|
    mime_dependency =
      if Mix.env() == :test || Mix.env() == :test_no_nif do
        case Version.compare(System.version(), "1.10.0") do
          :lt -> [{:mime, "~> 1.0"}]
          _ -> []
        end
      else
        []
      end

    [
      {:ueberauth, "~> 0.6"},
      {:httpoison, "~> 1.8"},
      {:sweet_xml, "~> 0.7"},
      {:excoveralls, "~> 0.14", only: :test},
      {:inch_ex, "~> 2.0", only: :docs},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mock, "~> 0.3", only: :test}
    ] ++ mime_dependency
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
