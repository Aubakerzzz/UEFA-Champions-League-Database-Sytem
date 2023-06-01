USE new;

---*************************1.(PART 1) Design SQL Schema for the given dataset. Identify the Entities/Tables and *************************
---*************************corresponding columns, constraints, and primary keys. Also, identify the *****************************
---*************************relationships between different Entities and map them through foreign keys correctly. ****************


-- Create STADIUMS table
CREATE TABLE STADIUMS (
    ID INT PRIMARY KEY NOT NULL,
    NAME VARCHAR(100) NOT NULL,
    CITY VARCHAR(100) NOT NULL,
    COUNTRY VARCHAR(100) NOT NULL,
    CAPACITY INT NOT NULL
);

-- Create TEAM table
CREATE TABLE TEAM (
    ID INT PRIMARY KEY NOT NULL,
    TEAM_NAME VARCHAR(100) NOT NULL,
    COUNTRY VARCHAR(100) NOT NULL,
    HOME_STADIUM_ID INT NOT NULL,
    FOREIGN KEY (HOME_STADIUM_ID) REFERENCES STADIUMS(ID)
);

-- Create PLAYERS table
CREATE TABLE PLAYERS (
    PLAYER_ID INT PRIMARY KEY NOT NULL,
    FIRST_NAME VARCHAR(100) NOT NULL,
    LAST_NAME VARCHAR(100) NOT NULL,
    NATIONALITY VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    TEAM_ID INT NOT NULL,
    JERSEY_NUMBER INT NOT NULL,
    POSITION VARCHAR(100) NOT NULL,
    HEIGHT INT NOT NULL,
    WEIGHT INT NOT NULL,
    FOOT VARCHAR(100) NOT NULL,
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(ID)
);

-- Create MANAGERS table
CREATE TABLE MANAGERS (
    ID INT PRIMARY KEY NOT NULL,
    FIRST_NAME VARCHAR(100) NOT NULL,
    LAST_NAME VARCHAR(100) NOT NULL,
    NATIONALITY VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    TEAM_ID INT NOT NULL,
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(ID)
);

-- Create MATCHES table
CREATE TABLE MATCHES (
    MATCH_ID INT PRIMARY KEY NOT NULL,
    SEASON VARCHAR(100) NOT NULL,
    DATE_TIME DATETIME NOT NULL,
    HOME_TEAM_ID INT NOT NULL,
    AWAY_TEAM_ID INT NOT NULL,
    STADIUM_ID INT NOT NULL,
    HOME_TEAM_SCORE INT NOT NULL,
    AWAY_TEAM_SCORE INT NOT NULL,
    PENALTY_SHOOT_OUT VARCHAR(10),
    ATTENDANCE INT,
    FOREIGN KEY (HOME_TEAM_ID) REFERENCES TEAM(ID),
    FOREIGN KEY (AWAY_TEAM_ID) REFERENCES TEAM(ID),
    FOREIGN KEY (STADIUM_ID) REFERENCES STADIUMS(ID)
);

-- Create GOALS table
CREATE TABLE GOALS (
    GOAL_ID INT PRIMARY KEY NOT NULL,
    MATCH_ID INT NOT NULL,
    PID INT NOT NULL,
    DURATION VARCHAR(10) NOT NULL,
    ASSIST VARCHAR(100),
    GOAL_DESC VARCHAR(100),
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID),
    FOREIGN KEY (PID) REFERENCES PLAYERS(PLAYER_ID)
);

--**********************QUESTION 02******************--
select *from  [dbo].[team]
select *from  [dbo].[stadiums]
select *from  [dbo].[player]
select *from  [dbo].[matches]
select *from  [dbo].[manager]
select *from  [dbo].[goals]

ALTER TABLE [dbo].[player]
DROP COLUMN [column12];
ALTER TABLE [dbo].[player]
DROP COLUMN [column13];
ALTER TABLE [dbo].[player]
DROP COLUMN [column14];


---***QUESTION NO: 03***---

--==========================================**************************EASY*******************************=============================================--:
	---1. All the players that have played under a specific manager.
SELECT *
FROM [dbo].[player] p
JOIN [dbo].[manager] m ON p.TEAM_ID = m.TEAM_ID
WHERE m.ID = 50;

	---2. All the matches that have been played in a specific country.
SELECT *
FROM [dbo].[matches] m
INNER JOIN  [dbo].[stadiums] s ON m.STADIUM_ID = s.ID
WHERE s.COUNTRY = 'Italy';
	
	---3. All the teams that have won more than 3 matches in their home stadium. (Assume a team wins only if they scored more goals then other team)
SELECT t.TEAM_NAME, COUNT(*) AS WINS
FROM [dbo].[team] t
INNER JOIN [dbo].[matches] m ON t.ID = m.HOME_TEAM_ID
WHERE m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE
  AND t.HOME_STADIUM_ID = m.STADIUM_ID
GROUP BY t.TEAM_NAME
HAVING COUNT(*) > 3;

	---4. All the teams with foreign managers.
SELECT t.TEAM_NAME
FROM  [dbo].[team] t
INNER JOIN [dbo].[manager] m ON t.ID = m.TEAM_ID
WHERE m.NATIONALITY != t.COUNTRY;

	---5.All the matches that were played in stadiums with seating capacity greater than 60,000.
SELECT m.MATCH_ID, m.SEASON, m.DATE_TIME,s.NAME AS STADIUM_NAME, s.CAPACITY
FROM [dbo].[matches] m
JOIN [dbo].[stadiums] s ON m.STADIUM_ID = s.ID
WHERE s.CAPACITY > 60000;

--=====================================*********************MEDIUM************************************===================================================--:

	---6. All Goals made without an assist in 2020 by players having height greater than 180 cm. (DIDN'T ADD YEAR AS THERE IS NO ATTRIBUTE GIVEN)
SELECT G.GOAL_ID, P.FIRST_NAME, P.LAST_NAME, G.DURATION, G.GOAL_DESC
FROM [dbo].[goals] G
LEFT JOIN [dbo].[player] P ON G.PID = P.PLAYER_ID
WHERE  P.HEIGHT > '180' AND G.ASSIST IS NULL;

	---7. All Russian teams with win percentage less than 50% in home matches.
SELECT t.TEAM_NAME, COUNT(*) AS TOTAL_MATCHES, 
    SUM(CASE WHEN m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS WINS,
    SUM(CASE WHEN m.HOME_TEAM_SCORE < m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS LOSSES,
    SUM(CASE WHEN m.HOME_TEAM_SCORE = m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS DRAWS,
    (CAST(SUM(CASE WHEN m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS FLOAT)/COUNT(*)) * 100 AS WIN_PERCENTAGE
FROM [dbo].[team] t
INNER JOIN MATCHES m ON m.HOME_TEAM_ID = t.ID
WHERE t.COUNTRY = 'Italy'
GROUP BY t.ID, t.TEAM_NAME
HAVING ((CAST(SUM(CASE WHEN m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS FLOAT)/COUNT(*)) * 100) < 50;

	---8. All Stadiums that have hosted more than 6 matches with host team having a win percentage less than 50%.
SELECT s.ID, s.NAME, s.CITY, s.COUNTRY, s.CAPACITY
FROM [dbo].[stadiums] s
JOIN [dbo].[matches] m ON s.ID = m.STADIUM_ID
JOIN [dbo].[team] t ON m.HOME_TEAM_ID = t.ID
WHERE m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE
GROUP BY s.ID, s.NAME, s.CITY, s.COUNTRY, s.CAPACITY
HAVING COUNT(*) > 6
   AND SUM(CASE WHEN m.HOME_TEAM_ID = t.ID THEN 1 ELSE 0  END) / COUNT(*) < 0.5;

	---9. The season with the greatest number of left-foot goals.
SELECT TOP 1
    M.SEASON,
    COUNT(G.GOAL_ID) AS LEFT_FOOT_GOALS
FROM
    [dbo].[matches] M
    JOIN [dbo].[goals] G ON M.MATCH_ID = G.MATCH_ID
    JOIN [dbo].[player] P ON G.PID = P.PLAYER_ID
WHERE
    P.FOOT = 'L'
GROUP BY
    M.SEASON
ORDER BY
    LEFT_FOOT_GOALS DESC;
	
	---10)	The country with maximum number of players with at least one goal.
SELECT TOP 1 p.NATIONALITY AS COUNTRY, COUNT(DISTINCT g.PID) AS NUM_PLAYERS_WITH_GOALS
FROM [dbo].[player] p
JOIN [dbo].[goals] g ON p.PLAYER_ID = g.PID
GROUP BY p.NATIONALITY
ORDER BY NUM_PLAYERS_WITH_GOALS DESC;


--=====================================*********************!!!HARD!!!************************************===================================================--:

	--11.All the stadiums with greater number of left-footed shots than right-footed shots.
SELECT s.NAME, COUNT(CASE WHEN p.FOOT = 'L' THEN g.GOAL_ID END) AS LEFT_FOOTED_SHOTS, COUNT(CASE WHEN p.FOOT = 'R' THEN g.GOAL_ID END) AS RIGHT_FOOTED_SHOTS
FROM [dbo].[stadiums] s
INNER JOIN [dbo].[matches] m ON s.ID = m.STADIUM_ID
INNER JOIN [dbo].[goals] g ON m.MATCH_ID = g.MATCH_ID
INNER JOIN [dbo].[player] p ON g.PID = p.PLAYER_ID
GROUP BY s.NAME
HAVING COUNT(CASE WHEN p.FOOT = 'L' THEN g.GOAL_ID END) > COUNT(CASE WHEN p.FOOT = 'R' THEN g.GOAL_ID END);

	--12.All matches that were played in country with maximum cumulative stadium seating capacity order by recent first.
SELECT m.MATCH_ID, m.SEASON, m.DATE_TIME, s.NAME, s.CITY, s.COUNTRY, s.CAPACITY
FROM [dbo].[matches] m
JOIN [dbo].[stadiums] s ON m.STADIUM_ID = s.ID
WHERE s.COUNTRY = (
  SELECT TOP 1 S.COUNTRY
  FROM (
    SELECT TOP 1 s.COUNTRY, SUM(s.CAPACITY) AS TOTAL_CAPACITY
    FROM [dbo].[stadiums] s
    GROUP BY s.COUNTRY
    ORDER BY TOTAL_CAPACITY DESC
  ) AS MAX_CAPACITY_COUNTRY
)
ORDER BY m.DATE_TIME DESC;

	---13.The player duo with the greatest number of goal-assist combination (i.e. pair of players that have assisted each other in more goals than any other duo).
SELECT TOP 1
    CONCAT(p1.FIRST_NAME, ' ', p1.LAST_NAME) AS PLAYER_1,
    CONCAT(p2.FIRST_NAME, ' ', p2.LAST_NAME) AS PLAYER_2,
    COUNT(*) AS GOAL_ASSIST_COMBINATION
FROM [dbo].[goals] g1
JOIN [dbo].[player] p1 ON g1.PID = p1.PLAYER_ID
JOIN GOALS g2 ON g1.MATCH_ID = g2.MATCH_ID AND g1.PID != g2.PID
JOIN [dbo].[player] p2 ON g2.PID = p2.PLAYER_ID
WHERE g1.ASSIST = g2.PID
GROUP BY p1.FIRST_NAME, p1.LAST_NAME, p2.FIRST_NAME, p2.LAST_NAME
ORDER BY GOAL_ASSIST_COMBINATION DESC;



	---14.The team having players with more header goal percentage than any other team in 2020.
SELECT TOP 10 t.TEAM_NAME,
       SUM(CASE WHEN g.GOAL_DESC = 'header' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS HEADER_GOAL_PERCENTAGE
FROM [dbo].[matches] m
     JOIN [dbo].[goals] g ON g.MATCH_ID = m.MATCH_ID
     JOIN [dbo].[player] p ON p.PLAYER_ID = g.PID
     JOIN [dbo].[team] t ON t.ID = p.TEAM_ID
WHERE (CAST(SUBSTRING(m.DATE_TIME, 8, 2) AS INT) = 20)
GROUP BY t.TEAM_NAME
ORDER BY HEADER_GOAL_PERCENTAGE DESC;

	---15.The most successful manager of UCL (2016-2022).
SELECT m.FIRST_NAME, m.LAST_NAME, t.TEAM_NAME, COUNT(*) AS UCL_TITLES
FROM [dbo].[manager] m
JOIN [dbo].[team] t ON t.ID = m.TEAM_ID
JOIN [dbo].[matches] ma ON (ma.HOME_TEAM_ID = t.ID OR ma.AWAY_TEAM_ID = t.ID) AND ma.SEASON >= '2016' AND MA.SEASON <='2023'
WHERE ma.HOME_TEAM_SCORE != ma.AWAY_TEAM_SCORE -- Exclude draws
GROUP BY m.ID, m.FIRST_NAME, m.LAST_NAME, t.TEAM_NAME
ORDER BY UCL_TITLES DESC;


--- ~~~~~~~~~~~~~~~~~*****!!!!!!!!!!!!BONUS!!!!!!!!!!*****~~~~~~~~~~~~~~~~---

-- 16) The winner teams for each season of UCL (2016-2022).
WITH TeamWins AS (
    SELECT 
        t.TEAM_NAME,
        m.SEASON,
        SUM(CASE 
            WHEN m.HOME_TEAM_ID = t.ID AND m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1
            WHEN m.AWAY_TEAM_ID = t.ID AND m.AWAY_TEAM_SCORE > m.HOME_TEAM_SCORE THEN 1
            ELSE 0
        END) AS WINS
    FROM [dbo].[team] t
    JOIN [dbo].[matches] m ON t.ID IN (m.HOME_TEAM_ID, m.AWAY_TEAM_ID)
    WHERE m.SEASON BETWEEN '2016-2017' AND '2021-2022'
    GROUP BY t.TEAM_NAME, m.SEASON
), RankedTeams AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY SEASON ORDER BY WINS DESC) AS Rank
    FROM TeamWins
)
SELECT 
    TEAM_NAME,
    SEASON,
    WINS
FROM RankedTeams
WHERE Rank = 1
ORDER BY SEASON;


