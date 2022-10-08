#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath("//table[.//th[contains(.,'Fonctions')]][2]//tr[td]")
    end
  end

  class Member
    REMAP = {
      "Ministre de l'enseignement supérieur, de la Recherche, des Sciences, des Technologies et des Sports" => [
        "Ministre de l'enseignement supérieur",
        'Ministre de la Recherche',
        'Ministre des Sciences et des Technologies',
        'Ministre des Sports'
      ]
    }

    field :id do
      name_node.css('a/@wikidata').first
    end

    field :name do
      name_node.at_css('a') ? name_node.at_css('a').text.tidy : name_node.text.tidy
    end

    field :positionID do
    end

    field :position do
      tds[3].text.split('(').first.split(/,\s*(?=Ministre)/).map(&:tidy).flat_map { |pos| REMAP.fetch(pos, pos) }
    end

    field :startDate do
    end

    field :endDate do
    end

    private

    def tds
      noko.css('td,th')
    end

    def name_node
      tds[1]
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
