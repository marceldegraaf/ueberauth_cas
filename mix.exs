defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @url     "https://github.com/marceldegraaf/ueberauth_cas"

  def project do
    [
      app: :ueberauth_cas,
      version: @version,
      elixir: "~> 1.2",
      name: "Ueberauth CAS strategy",
      package: package,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @url,
      homepage_url: @url,
      description: "An Ueberauth strategy for CAS authentication.",
      deps: deps,
      test_coverage: [tool: ExCoveralls],
    ]
  end

  def application do
    [
      applications: [:logger, :ueberauth, :httpoison]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.2"},
      {:httpoison, "~> 0.9.0"},
      {:floki, "~> 0.9.0"},
      {:excoveralls, "~> 0.5", only: :test},
      {:inch_ex, "~> 0.5.0", only: :docs},
      {:earmark, "~> 0.2.1", only: :dev},
      {:ex_doc, "~> 0.12.0", only: :dev},
      {:mock, "~> 0.1.1", only: :test},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Marcel de Graaf"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}
    ]
  end
end
