module Main where
import AccountingDate

data StType = Deposit | Change deriving (Read, Show);
type Statement = (StType, Int, Date, Maybe Int);

isBefore :: Statement -> Date -> Bool
isBefore (_,_,st,_) dt = nst < ndt
  where nst = toInt st
        ndt = toInt dt

apply :: Statement -> Date -> Either Int Int
apply (Change, amount, from, Just every) to = Left (amount * times)
  where inbetween = (toInt to) - (toInt from)
        times = (inbetween `div` every) + 1
apply (Change, amount, from, Nothing) to = Left amount
apply (Deposit, amount, _,_) _ = Right (-amount)

parseStmt :: [String] -> Maybe Statement
parseStmt (st:i:dt:itv:_) = Just (read st, read i, read dt, Just (read itv))
parseStmt (st:i:dt:_) = Just (read st, read i, read dt, Nothing)
parseStmt _ = Nothing

print_st :: Statement -> String
print_st (t, val, dt, intval) = (show t) ++ ": " ++ (show val) ++ " on " ++ (show dt)

data QueryType = When | Available | Total deriving (Read, Show);
type Query = (QueryType, Int);

parseQuery :: [String] -> Maybe Query
parseQuery (qt:i:_) = Just (read qt, read i)
parseQuery _ = Nothing

present :: (Maybe a, Maybe b) -> Maybe (a, b)
present (Just a, Just b) = Just (a, b)
present _ = Nothing

presentList :: [Maybe a] -> Maybe [a]
presentList [] = Just []
presentList (Nothing:_) = Nothing
presentList ((Just a):rest) = case (presentList rest) of
  Just list -> Just ([a] ++ list)
  Nothing -> Nothing

attach :: [a] -> b -> [(a, b)]
attach [] _ = []
attach (x:xs) y = [(x,y)] ++ (attach xs y)

total :: Either Int Int -> Int
total (Left x) = x
total _ = 0

available :: Either Int Int -> Int
available (Left x) = x
available (Right x) = x

flatten :: Date -> (Either Int Int -> Int) -> [Statement] -> Int
flatten until fn st = sum $ map (fn . uncurry apply) used
  where used = filter (uncurry isBefore) (attach st until)

nextAvailable :: Int -> Date -> [Statement] -> Int
nextAvailable minAmount dt st
  | avbl >= minAmount = 0
  | otherwise         = (nextAvailable minAmount (addDays dt 1) st) + 1 -- Try next date (count up for each retry)
  where avbl = flatten dt available st

serveQuery :: Date -> [Statement] -> Query -> String
serveQuery date st (Total, days) = "Total balance in " ++ (show days) ++ " days: " ++ (show balance) 
  where balance = flatten (addDays date days) total st
serveQuery date st (Available, days) = "Available cash in " ++ (show days) ++ " days: " ++ (show cash)
  where cash = flatten (addDays date days) available st
serveQuery date st (When, amount) = "Cash " ++ (show amount) ++ " available in: " ++ (show $ addDays date days)
  where days = nextAvailable amount date st

compileData :: [String] -> Maybe ([Statement], Query)
compileData ln = present (presentList (map (parseStmt . words) (init $ ln)), parseQuery $ words $ last ln)

serve :: [String] -> String
serve ln = maybe "Invalid request." (uncurry $ serveQuery $ date) (compileData rest)
  where date = read $ head $ ln
        rest = tail $ ln

isValid:: String -> Bool
isValid [] = False
isValid (a:_) = a /= '#'

main :: IO ()
main = interact $ serve . filter isValid . lines 
