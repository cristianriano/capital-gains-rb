# Capital Gains

This script calculates capital gains for a fiscal year using FIFO.

## Usage

Simply run the script passing a CSV containing the required info with (no need to install gems)
```
./main.rb trades.csv
```

The CSV must have the following headers in any order
1. **Asset**: The symbol of the transaction (any unique identifier will do)
2. **Amount Asset**: Number of units purchases/sold
3. **Asset market price**: Unit price of the asset at the given time
4. **Timestamp**: A string containing the date of the operation in format (YYYY-mm-dd)

## Test

It has a test suite with input examples. Run it with `bundle exec rspec spec/`
