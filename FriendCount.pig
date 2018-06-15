/*
  Big Data Management
  Assignment 2
	
  Authors: Angeliki Mylonaki	
	   Vasiliki Konstantopoulou

  Pig Script for requirement 1
  Counting Facebook Friends
*/


--load file into row (aka strings which have spaces)
row = LOAD 'friendship-20-persons.txt' using PigStorage('\n')  AS (line:chararray);

--splitting each line into two parts: user, friends(string)
userAndFriends = FOREACH row GENERATE FLATTEN(STRSPLIT(line, ' ',2)) AS (user:chararray, friends:chararray);

--splitting the friends-string into words and placing them into a tuple
tupled = foreach userAndFriends generate user, STRSPLIT(friends, ' ') AS (y:tuple());

--for each line in (meaning for each user), calculate the tuple size(friends) 
final = foreach tupled generate user, SIZE(y);

STORE final INTO 'CountFriendsResult';

--display result
Dump final;
