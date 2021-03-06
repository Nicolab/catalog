require "shardbox-core/catalog"
require "./tools"

module Catalog::Tools
  def self.command_format
    all_entries = {} of Repo::Ref => Catalog::Entry
    all_mirrors = Set(Repo::Ref).new
    has_warnings = false

    catalog = Catalog.new(catalog_path)
    catalog.each_category do |category|
      warnings = Catalog::Tools.normalize_category(category)

      category.shards.each do |shard|
        all_entries[shard.repo_ref] ||= shard
        if duplicate_repo = Catalog.duplicate_mirror?(shard, all_mirrors, all_entries)
          warnings << "Duplicate mirror #{duplicate_repo}."
        end
      end

      Catalog::Tools.write(catalog_path, category)

      warnings.each do |warning|
        Catalog::Tools.warn warning, category.slug
      end
      has_warnings ||= warnings.any?
    end

    !has_warnings
  end
end
