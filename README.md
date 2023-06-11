# IPL-_2020
I have used sql to analyze IPL 2020 data using Joins, CTEs, Window Functions, Aggregation Functions, Creating view, Creating user defined functions, Creating stored procedures.

I have done analysis on batsman score, team win percentage, created scorecards to analyse teams, individual batsmans and bowlers, calculated percentage of how a batsman is scoring runs and many more expolitary analysis on 2020 season which helps the user to understand every particular detail about the dataset.
I have used 3 datasets Venue, Matches and Deliveries which are stored in CSV Files.

Venue dataset is about date of of match played and in which stadium has id as primary key.

Matches dataset tells which team won match,how they won, Toss winner and has Match_id as a primary key

Delivery data set record every bowl bowled by batsman and every bowl faced by batsman in which inning in which and how many runs he scored on a particular bowl and it has match_id as primary key.

I have used sql for these datasets as it wil take us into deep analysis of the 2020 season of ipl.

Created cte to know what is the average winning marginn when a team bowling in second inning wins.

Created procedure which will take batsman name as input and will tell his total score in entire tournament which will heplp in further analysis of the batsman.

Created viwe which will help to know the difference between batsman runs across differnt teams which help to track highest scorer of the tournament and how much runs a particular batsman is leading as compared to the batsman who has scored less runs as compared to him.

As there are so many matches played across a single season so, I created a user defined function to track winners which will tell winner of any particular match by knowing the match id.


