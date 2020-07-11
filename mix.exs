defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @version "1.1.0"
  @url     "https://github.com/marceldegraaf/ueberauth_cas"

  def project do
    [
      app: :ueberauth_cas,
      version: @version,
      elixir: "~> 1.8",
      name: "Ueberauth CAS strategy",
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @url,
      homepage_url: @url,
      description: "An Ueberauth strategy for CAS authentication.",
      deps: deps(),
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
      {:ueberauth, "~> 0.6.3"},
      {:httpoison, "~> 1.7.0"},
      {:floki, "~> 0.27.0"},
      {:excoveralls, "~> 0.13.0", only: :test},
      {:inch_ex, "~> 2.0.0", only: :docs},
      {:earmark, "~> 1.4.9", only: :dev},
      {:ex_doc, "~> 0.22.1", only: :dev},
      {:mock, "~> 0.3.5", only: :test},
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
