# cashflow - haskell
Simple program to calculate cashflow every day by using income/expense patterns

## Input
The cashflow binary reads stdin and expects the following pattern to use as program input:

```
# <- lines beginning with # are ignored
# date format is (d,m,y)
START DATE
CHANGE 0
CHANGE 1
CHANGE 2
...
CHANGE N
QUERY
```

### Changes
Changes are money transactions, which may be reaccurring or not.
The format these are specified in works like this:

```
Type Amount (Date)
# Type may be either Change or Deposit
Change -3000 (30, 12, 2020)
# Deposits are meant as no real transaction, but security buffers of sorts (e.g. amounts of money that are for emergencies and not available at leisure)
Deposit 2500 (1,1,2022)
# Reaccurring transactions may also provide the number of days after which the action is repeated
Change 10000 (1,2,2021) 30
```

Note that dates used are of accounting format, so 12 exactly 30-day months.

### Query
There are three types of Queries which may be used with this application:
1. **When <Amount>** (App will show the date at which the specified amount is available)
2. **Available <Days>** (App will show the amount available in the specified number of days)
3. **Total <Days>**  (App will show the total amount (e.g. ignoring deposits) available in the specified number of days)

## cashflow.sh
This is a convenience script, which allows the use of with a separate file of changes, independent of the query, which is supplied as an argument.
The script uses the current date as the start date of the calculation per default.

```
./cashflow.sh FILE QUERY
# (e.g.)
./cashflow changes.txt "Available 90"
