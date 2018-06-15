/*
  Big Data Management
  Assignment 2
	
  Authors: Angeliki Mylonaki	
	   Vasiliki Konstantopoulou

  Pig Script for requirement 2
  Counting Common Facebook friends
*/


--load file into row (aka strings which have spaces)
row = LOAD 'friendship-20-persons.txt' using PigStorage('\n')  AS (line:chararray);


--splitting each line into two parts, delimiting on the first space character occurence
--first part is the user, and second part is the friend-string (similar to requirment1)
UserFriendString = FOREACH row GENERATE FLATTEN(STRSPLIT(line, ' ',2)) AS (user:chararray, friends:chararray);


--splitting the friend string into tokens(on space) and pairs(user,friend) for every friend in the friendlist
UserFriendPair =  foreach UserFriendString generate user as friend1, flatten( TOKENIZE(friends)) as friend2;


--removing dublicates, aka PersonA <--isFriendWith--> PersonB
UserFriendPairDistinct =  DISTINCT UserFriendPair;


--joining the (user,friend) pairs with the initial friend-string
--As a result we have the user pair, with all personA friends
join_list = JOIN UserFriendPairDistinct BY friend1, UserFriendString BY user;


--putting personA friends into a Bag for easier handling:
--result form (personA, personB, {personA friends}}
join_list2 = FOREACH join_list GENERATE $0, $1, TOBAG($3);


--removing null values (don't really need that)
join_list2 = FILTER join_list2 BY ($0 is not null);


--order (personA, personB) pairs (needed for next step)
orderedList = FOREACH join_list2 GENERATE (($0 < $1 ? ($0, $1) : ($1, $0))) AS user_pair, $2;


--removing duplicate entries
distinct_list = DISTINCT orderedList;


--Grouping pairs
--Grouping creates something like:
-- (personA,personB),(personA,personB), {(personA friends),(personB friends)}
grouped_list = GROUP distinct_list BY $0;	


--Removing duplicate pair of grouping result----> (personA,personB), {(personA friends),(personB friends)}
result = FOREACH grouped_list GENERATE group, distinct_list.$1;


--In order to keep only the unique common friends, we convert the grouping part:{(personA friends),(personB friends)}
--into strings and keep only the unique ones.
final = FOREACH result GENERATE $0,  org.apache.pig.builtin.Distinct(TOKENIZE(REPLACE(BagToString(TOBAG($1)), '[{()}]', ''))) as friendList;

dump final
