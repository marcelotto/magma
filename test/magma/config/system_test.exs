defmodule Magma.Config.SystemTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config.System

  test "load/1" do
    assert {:ok,
            %Magma.Config.System{
              name: "Magma.system.config",
              tags: ["magma-config"],
              custom_metadata: %{
                default_tags: ["magma-vault"],
                default_generation: %Magma.Generation.Mock{},
                link_resolution_style: :at_file_ref,
                session_response_mode: :import
              }
            } = config} = Magma.Config.System.load()

    assert config.content ==
             """
             # Magma system config

             ## Persona

             #{Magma.Config.System.default_persona()}


             ## Context knowledge

             """

    assert config.path == Vault.path("magma.config/Magma.system.config.md")
  end

  test "system config roundtrip: template -> write -> read -> verify" do
    # Create template content with all default values
    template_content = Magma.Config.System.template()

    # Write to the system config path
    config_path = Magma.Config.System.path()
    File.write!(config_path, template_content)

    # Reset config cache to force reload
    Magma.Config.reset()

    # Load and verify all config values match defaults
    assert {:ok, config} = Magma.Config.System.load()

    assert config.custom_metadata[:default_tags] == Magma.Config.System.default_tags()

    assert config.custom_metadata[:link_resolution_style] ==
             Magma.Config.System.default_link_resolution_style()

    assert config.custom_metadata[:session_response_mode] ==
             Magma.Config.System.default_session_response_mode()

    assert config.custom_metadata[:include_prompt_header] ==
             Magma.Config.System.default_include_prompt_header()

    assert config.custom_metadata[:include_prompt_header] ==
             Magma.Config.System.default_include_prompt_header()
  end

  test "system config roundtrip with false boolean value" do
    template_content = Magma.Config.System.template()

    modified_content =
      String.replace(
        template_content,
        "include_prompt_header: true",
        "include_prompt_header: false"
      )

    # Write to the system config path
    config_path = Magma.Config.System.path()
    File.write!(config_path, modified_content)

    # Reset config cache to force reload
    Magma.Config.reset()

    # Load and verify false boolean is correctly deserialized
    assert {:ok, config} = Magma.Config.System.load()

    assert config.custom_metadata[:include_prompt_header] == false
  end
end
