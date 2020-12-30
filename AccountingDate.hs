module AccountingDate where

type Year = Int;
type Day = Int;
type Month = Int;
type Date = (Day, Month, Year);

month :: Int -> Month
month num = num `mod` 12

day :: Int -> Day
day num = num `mod` 30

toDate :: Int -> Date
toDate num = (days, months, years)
  where years = num `div` 360
  	inyear = num `mod` 360
	months = inyear `div` 30 + 1
	days = inyear `mod` 30 + 1

toInt :: Date -> Int
toInt (d,m,y) = y * 360 + cm * 30 + cd
  where cd = d - 1
        cm = m - 1

addDays :: Date -> Int -> Date
addDays d n = toDate (n + toInt d)
