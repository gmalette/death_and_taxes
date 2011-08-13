require 'active_record'
require 'active_record/version'

require 'active_support/core_ext'

require File.join(File.dirname(__FILE__), 'death_and_taxes', 'railtie')

module DeathAndTaxes
  %w( Country State Tax Taxable Taxation Taxer TaxInfo TaxVersion ).each do |class_name|
    autoload class_name.to_sym, File.join(File.dirname(__FILE__), "death_and_taxes/#{class_name.underscore}")
  end
  
  Dir[File.join(File.dirname(__FILE__), '..', 'config', '*.yml')].each do |filename|
    country_code = filename.match(/\W(?<country_code>[a-z]+)\.yml/)[:country_code]
    @countries = {}
    @countries[country_code] = Country.new( YAML::load_file filename )
  end
  
  def self.applicable_taxes from, to, date = nil
    date ||= Date.today
    @countries.detect{|country| country.applies_taxes?(from, to, date)}
  end
  
  def self.build tax, date
    @countries.detect {|country| country.build_tax(tax, date)}
  end
end