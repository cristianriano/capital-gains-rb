#!/usr/bin/env ruby

# require 'bundler/inline'

# gemfile do
#   source 'https://rubygems.org'
#   gem 'mysql2'
# end

require 'csv'
require 'pry'

TYPE = 'Transaction Type'
IGNORED_TYPES = Set['deposit', 'withdrawal']

file_name = ARGV[0] || raise('Please provide a file name')

class Transaction

  attr_reader :type, :asset, :amount, :price, :total

  def initialize(type, asset, amount, price)
    @type = type
    @asset = asset
    @amount = amount.to_f
    @price = price.to_f
    @total = @amount * @price
  end

  def self.buy(row)
    new(:buy, row['Asset'], row['Amount Asset'], row['Asset market price'])
  end

  def self.sell(row)
    new(:sell, row['Asset'], row['Amount Asset'], row['Asset market price'])
  end
end

movements_by_asset = Hash.new { |h, k| h[k] = [] }

CSV.foreach(file_name, headers: true) do |row|
  type = row[TYPE]
  next if IGNORED_TYPES.include?(type)

  case type
  when 'buy'
    transaction = Transaction.buy(row)
    movements_by_asset[transaction.asset] << transaction
  when 'sell'
    transaction = Transaction.sell(row)
    movements_by_asset[transaction.asset] << transaction
  when 'transfer'
  else
    println "Unknown type: #{type}"
  end
end
