defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @version "0.1.0"
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
      deps: deps
    ]
  end

  def application do
    [
      applications: [:logger, :ueberauth]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.2"}
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
