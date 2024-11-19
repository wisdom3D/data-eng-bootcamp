--SELECT * FROM public.player_seasons;
--ORDER BY age asc
--create type season_stats as (
--					season integer,
--					gp integer,
--					pts real,
--					reb real,
--					ast real
--)
-- CREATE TYPE scoring_class AS
--     ENUM ('bad', 'average', 'good', 'star');
drop table players1
create table players1 (
			player_name text,
			height text,
			college text,
			country text,
			draft_year text,
			draft_round text,
			draft_number text,
			season_stats season_stats[],
			scoring_class scoring_class,
			year_since_last_season int,
			current_season integer,
			primary key(player_name, current_season)
)

--select min(season) from public.player_seasons;
INSERT INTO players1
with yesterday as (
	select * from players1
	where current_season = 2000
),
	 today as (
	select * from public.player_seasons
	where season = 2001
)
select 
coalesce(t.player_name, y.player_name) as player_name,
coalesce(t.height, y.height) as height,
coalesce(t.college, y.college) as college,
coalesce(t.country, y.country) as country,
coalesce(t.draft_year, y.draft_year) as draft_year,
coalesce(t.draft_round, y.draft_round) as draft_round,
coalesce(t.draft_number, y.draft_number) as draft_number,
case when y.season_stats is null then array[
		   	(
					t.season,
					t.gp,
					t.pts,
					t.reb,
					t.ast
			)::season_stats]
when t.season is not null then y.season_stats || array[
			(
					t.season,
					t.gp,
					t.pts,
					t.reb,
					t.ast
			)::season_stats]
else y.season_stats
end as season_stats,
case 
	when t.season is not null then 
		case when t.pts > 20 then 'star'
			when t.pts > 15 then 'good'
			when t.pts > 10 then 'average'
		else 'bad'
	end::scoring_class
	else y.scoring_class
end as scoring_class,
case 
	when t.season is not null then 0
	else coalesce(y.year_since_last_season, 0) + 1
end  as year_since_last_season,

coalesce(t.season, y.current_season + 1) current_season
--case when t.season is not null then t.season else y.current_season + 1 end
from today t full outer join yesterday y 
on t.player_name = y.player_name

--with unestcte as (
--	select player_name, unnest(season_stats) season_stats from players 
--where current_season = 2001 and player_name = 'Michael Jordan'
--)
--select player_name, (season_stats::season_stats).* from unestcte


select * from players1 order by year_since_last_season desc
