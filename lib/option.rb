# frozen_string_literal: true

require "yaml"

module Option
  providers = YAML.load_file("config/providers.yml")

  Provider = Struct.new(:name, :display_name)
  Location = Struct.new(:provider, :name, :display_name, :visible)

  PROVIDERS = {}
  LOCATIONS = []

  providers.each do |provider|
    provider_internal_name = provider["provider_internal_name"]
    PROVIDERS[provider_internal_name] = Provider.new(provider_internal_name, provider["provider_display_name"])
    Provider.const_set(provider_internal_name.gsub(/[^a-zA-Z]/, "_").upcase, provider_internal_name)

    provider["locations"].each do |location|
      LOCATIONS.push(Location.new(
        PROVIDERS[provider_internal_name],
        location["internal_name"],
        location["display_name"],
        location["visible"]
      ))
    end
  end

  PROVIDERS.freeze
  LOCATIONS.freeze

  def self.locations(only_visible: true)
    Option::LOCATIONS.select { !only_visible || _1.visible }
  end

  def self.postgres_locations
    Option::LOCATIONS.select { _1.name == "hetzner-fsn1" }
  end

  BootImage = Struct.new(:name, :display_name)
  BootImages = [
    ["ubuntu-jammy", "Ubuntu Jammy 22.04 LTS"],
    ["almalinux-9.1", "AlmaLinux 9.1"]
  ].map { |args| BootImage.new(*args) }.freeze

  VmSize = Struct.new(:name, :family, :vcpu, :memory, :storage_size_gib) do
    alias_method :display_name, :name
  end
  VmSizes = [2, 4, 8, 16].map {
    VmSize.new("standard-#{_1}", "standard", _1, _1 * 4, (_1 / 2) * 25)
  }.freeze

  PostgresSize = Struct.new(:name, :vm_size, :family, :vcpu, :memory, :storage_size_gib) do
    alias_method :display_name, :name
  end
  PostgresSizes = [2, 4, 8, 16].map {
    PostgresSize.new("standard-#{_1}", "standard-#{_1}", "standard", _1, _1 * 4, (_1 / 2) * 128)
  }.freeze

  PostgresHaOption = Struct.new(:name, :standby_count, :title, :explanation)
  PostgresHaOptions = [[PostgresResource::HaType::NONE, 0, "No Standbys", "No replication"],
    [PostgresResource::HaType::ASYNC, 1, "1 Standby", "Asyncronous replication"],
    [PostgresResource::HaType::SYNC, 2, "2 Standbys", "Syncronous replication with quorum"]].map {
    PostgresHaOption.new(*_1)
  }.freeze
end
