/*
IPL 2020 Data Expolaration
Skills Used : Joins, CTEs, Window Functions, Aggregation Functions, Creating view, Creating user defined functions, Creating stored procedures
*/

-- Dataset for this project
USE ipl;


select * 
from deliveries;

select * 
from matches;

select * from 
venue;

-- Looking at number of matches played in each city
Select city, count(id) as 'Number of matches'
from venue
group by city
order by 2 desc;

-- Finding run scored in each inning of a match
select match_id, inning, sum(total_runs) 
from deliveries
group by match_id, inning;

-- Calculating Group Points and Win percentage for every team
select winner, Number_of_matches_won, (Number_of_matches_won * 100 / 14) as "Win %", (Number_of_matches_won * 2) as 'Points'
from(
select winner,count(id) as'Number_of_matches_won'
from matches
group by winner) a
order by 2 desc;

-- Total centuries scored
Select count(*) 
from( 
Select batsman, match_id,
sum(batsman_runs) AS batsman_match_score
FROM  deliveries
GROUP BY batsman,
match_id
HAVING batsman_match_score >= 100 ) a ;

-- Number of sixes scored in tournament
Select count(batsman_runs) as 'Tournament Sixes'
from deliveries 
where batsman_runs = 6 ;

-- Top Scorers of the tournament
Select batsman, sum(batsman_runs) as 'Total_runs'
from deliveries
group by batsman
having total_runs> 300
order by 2 desc;

-- Calculating Average win margin by runs
SELECT winner,
Avg (win_by_runs) AS avg_winning_margin
FROM matches
WHERE  win_by_runs > 0
GROUP  BY winner
ORDER  BY avg_winning_margin DESC;

-- Total runs scored by batsman And Total runs scored by sixes and boundaries
SELECT 
    batsman,
    SUM(batsman_runs) AS 'Total_runs',
    SUM(CASE
        WHEN batsman_runs = 6 THEN batsman_runs
        ELSE 0
    END) AS 'Runs_scored_in_Sixes',
    SUM(CASE
        WHEN batsman_runs = 4 THEN batsman_runs
        ELSE 0
    END) AS 'Runs_scored_in_Boundaries'
FROM
    deliveries
GROUP BY batsman
ORDER BY 2 DESC ;

-- Percent of Batsman runs through boundaries and sixes
Select Batsman, Total_runs , (Runs_scored_in_sixes / Total_runs) * 100  as "%_Runs_in_sixes",
(Runs_scored_in_Boundaries / Total_runs) * 100 as "%_Runs_in_boundaries"
from (SELECT 
    batsman,
    SUM(batsman_runs) AS 'Total_runs',
    SUM(CASE
        WHEN batsman_runs = 6 THEN batsman_runs
        ELSE 0
    END) AS 'Runs_scored_in_Sixes',
    SUM(CASE
        WHEN batsman_runs = 4 THEN batsman_runs
        ELSE 0
    END) AS 'Runs_scored_in_Boundaries'
FROM
    deliveries
GROUP BY batsman) a order by 2 desc;

-- Bowlers who gave more than 30 extra runs throughout the tournament
SELECT bowler,
Sum(extra_runs) AS "total_extra_runs"
FROM   deliveries
GROUP  BY bowler
HAVING total_extra_runs > 30
ORDER  BY total_extra_runs DESC;

-- Number of days Tournament was played
select datediff(max(date),min(date))
from venue;

-- On which day of october month more than 1 match was played
SELECT Day(date),
       Count(id) AS "total_matches"
FROM   venue
WHERE  Monthname(date) = "October"
GROUP  BY Day(date)
HAVING total_matches > 1 ;

-- City in which highest runs were scored in single inning
Select match_id, inning,
city,
Sum(total_runs) AS "match_score"
FROM venue a
INNER JOIN  deliveries b
ON a.id = b.match_id
GROUP  BY match_id,
inning, city
ORDER  BY match_score DESC;

-- Lowest first inning score in Sharjah City
SELECT b.match_id,
Sum(total_runs) AS inn_score
FROM venue a
LEFT JOIN deliveries b
ON a.id = b.match_id
WHERE  inning = 1
AND city = 'Sharjah'
GROUP  BY match_id
ORDER  BY inn_score ASC;

-- Runs scored by DC at Dubai in the matches they won
select winner, sum(total_runs) as tot
from deliveries d 
inner join venue v
on v.ID = d.match_id 
inner join matches m 
on d.match_id = m.ID
where v.city = "Dubai (DSC)" and m.winner = "DC";

-- Creating batsman scorecard for every inning of a match and ranking them
Select match_id, batting_team, batsman, batsman_score,inning,
Rank() Over (partition by match_id, inning order by batsman_score desc) as 'Ranks'
from( 
Select match_id, inning,batsman,
batting_team, sum(batsman_runs) as batsman_score
from deliveries
group by match_id,batting_team,
inning, batsman) as match_scorecard;

-- Creating a running total scorecard for each inning
Select row_id, match_id,inning, batsman,
batsman_score,
sum(batsman_score) over (partition by match_id, inning order by row_id) as Match_cumulative_scorecard
from(
Select match_id, inning, batsman,
sum(batsman_runs) as 'batsman_score',
row_number() over(partition by match_id, inning) as row_id
from deliveries
group by match_id, inning, batsman) a;

-- Rating matches on number of runs scored then counting the different rating achieved
select count(Match_id),
IF(Total_runs < 300, "Low_Scoring_match",
IF(Total_runs < 375, "Average_scoring_match","High_scoring_match")) As Rating
from(
Select match_id, Sum(total_runs) as 'Total_runs'
from deliveries
group by match_id 
order by 2) a
group by rating ;

Select * from
CTE_MatchRating;

-- Creating  CTE to check number of matches above the average win by runs margin as compared to total number of matches where 2nd Inning bowling team won
WITH CTE as (
select avg(win_by_runs) as avg_WinByRuns from matches)
Select 
sum(case when m.win_by_runs > c.avg_winByRuns then 1 else 0 End) as 'Matches_above_avg_win_by_runs',
count(win_by_runs) as 'Total_no_matches_where_Team_won_by_runs'
from matches m
join cte c
where win_by_runs > 0 ; 

-- Creating a Procedure where we have to input batsman name to know total runs scored by batsman in the tournament
DROP procedure if exists Total_batsman_runs;

DELIMITER $$
Create procedure Total_batsman_runs(in p_batsman varchar(255), out p_batsman_runs INTEGER)
BEGIN
Select sum(batsman_runs) 
into p_batsman_runs
from deliveries
where batsman = p_batsman ; 
END$$
DELIMITER ;

-- Creating view to compare diference between batsman scores in the tournament
Create view v_difference_between_batsman_total_runs AS 
Select batsman, 
batsman_total_runs, batsman_total_runs - lead(batsman_total_runs, 1 , 'N/A') over () as'Difference_compare_to_below_rank',
lag(batsman_total_runs, 1, Null) over() - batsman_total_runs as 'Difference_compare_to_above_rank'
from(
Select batsman,
sum(batsman_runs) as "batsman_total_runs"
from deliveries
group by batsman) a
order by batsman_total_runs desc;

-- Creating a Function which help us to know winner by entering match_id
DELIMITER $$
Create function f_winner(f_id integer)
Returns varchar (255)
Deterministic
BEGIN
DECLARE f_match_winner
varchar (255);

Select winner 
into f_match_winner
from matches
where id = f_id;

Return f_match_winner;
END$$
DELIMITER ;

















