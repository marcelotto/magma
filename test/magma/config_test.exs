defmodule Magma.ConfigTest do
  use Magma.Vault.Case, async: false

  doctest Magma.Config

  test "system/0" do
    assert {:ok, Magma.Config.system()} ==
             Magma.Config.System.load()
  end

  test "system/1" do
    assert Magma.Config.system(:default_tags) == ["magma-vault"]
    assert Magma.Config.system(:default_generation) == %Magma.Generation.Mock{}
    assert Magma.Config.system(:link_resolution_style) == :plain
  end

  @tag vault_files: ["concepts/Project.md"]
  test "project/0" do
    assert {:ok, Magma.Config.project()} ==
             Magma.Matter.Project.concept()
  end

  test "matter/1" do
    assert {:ok, Magma.Config.matter(Magma.Matter.Project)} ==
             Magma.Config.Matter.load("Project.matter.config")

    assert {:ok, Magma.Config.matter(Magma.Matter.Module)} ==
             Magma.Config.Matter.load("Module.matter.config")

    assert {:ok, Magma.Config.matter(Magma.Matter.Text.Section)} ==
             Magma.Config.Matter.load("Text.Section.matter.config")
  end

  test "artefact/1" do
    assert {:ok, Magma.Config.artefact(Magma.Artefacts.ModuleDoc)} ==
             Magma.Config.Artefact.load("ModuleDoc.artefact.config")

    assert {:ok, Magma.Config.artefact(Magma.Artefacts.Readme)} ==
             Magma.Config.Artefact.load("Readme.artefact.config")
  end

  test "text_type/1" do
    assert {:ok, Magma.Config.text_type(Magma.Matter.Texts.Generic)} ==
             Magma.Config.TextType.load("Generic.text_type.config")

    assert {:ok, Magma.Config.text_type(Magma.Matter.Texts.UserGuide)} ==
             Magma.Config.TextType.load("UserGuide.text_type.config")
  end

  test "text_types/0" do
    assert Magma.Config.text_types() ==
             [Magma.Matter.Texts.Generic, Magma.Matter.Texts.UserGuide]
  end
end
