SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
ORDER BY 1, 2


--global cases and deaths data

SELECT 
'Worldwide' as Location,
date,
sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as percent_deaths
FROM covidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 2,3

-- total global cases and deaths data till date
SELECT 
'Worldwide' as Location,
sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as percent_deaths
FROM covidDeaths
WHERE continent is not null



--CREATE VIEW OF TOP 3 countries in every continent with highest percent vaccination BETWEEN '2020-05-01' and '2021-12-31'

CREATE VIEW Top3_vaccinated as 


--looking at total population vs vaccination

with popvacc as

(select 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) as rolling_total_vaccination

from covidDeaths cd
JOIN 
covidVaccinations cv
on
cd.location = cv.location
and 
cd.date = cv.date
where cd.continent is not null
)


--Getting Top 3 countries in every continent with highest percent vaccination.
  --(used JOINS, Used aggregate functions, Sub Query, Windows function, Assigned Rows and limited to top N countries from each continent)
	--(we can also get the bottom N countries by removing 'DESC' from the ROW_NUMBER ORDER BY clause)


select * from
(select 
ROW_NUMBER() OVER (PARTITION BY continent ORDER BY percent_vaccinated DESC ) AS Sr_No,
*
from(
select 
continent, 
location,
max(rolling_total_vaccination) as max_total_vaccination,
round(max(rolling_total_vaccination/population*100),2) as percent_vaccinated
from popvacc
where date between '2020-05-01' and '2021-12-31'
group by continent, location) t1) t2
where Sr_No <= 3





--Looking at total cases vs total deaths
--SHOWS LIKLIHOOD Of DYING IF YOU CONTACT COVID IN YOUR COUNTRY

SELECT 
location , DATE, total_cases , total_deaths, ROUND(total_deaths/total_cases*100,2) as percent_deaths
FROM covidDeaths
WHERE location like '%INDIA%'
ORDER BY 1,2


--Looking at total cases vs population
--Shows what % of population got covid

SELECT 
location , DATE, population, total_cases , ROUND(total_cases/population*100,2) as percent_contaminated
FROM covidDeaths
WHERE location like '%INDIA%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT 
location ,  population,
MAX(total_cases) AS Highest_infection_rate , 
round(max(total_cases/population)*100,2) as percent_contaminated
FROM covidDeaths
group by location , population
ORDER BY 4 desc


--Showing countries with highest % death count with respect to their population

SELECT 
location ,  population,
max(cast(total_deaths as int)) AS Highest_death_count , 
round(max(cast(total_deaths as int)/population)*100,2) as percent_population_death
FROM covidDeaths
group by location , population
ORDER BY 4 desc

--Showing countries with highest death count 
SELECT 
location ,  max(cast(total_deaths as int)) AS Highest_death_count 
FROM covidDeaths
where continent is not null
group by location 
ORDER BY 2 desc

-- Breakdown of the same by continent
SELECT 
location ,  max(cast(total_deaths as int)) AS Highest_death_count 
FROM covidDeaths
where continent is null
and location not like '%income%'
group by location 
ORDER BY 2 desc


select continent, sum(Highest_death_count) as total_deaths from (SELECT 
continent ,location,  max(cast(total_deaths as int)) AS Highest_death_count 
FROM covidDeaths
where continent is not null
and location not like '%income%'
group by continent ,location) t1
group by continent
order by 2 desc






-- TEMP TABLE
-- Creating a temp table and inserting data into it using query.

DROP TABLE IF exists #Percent_population_vacc
CREATE TABLE #Percent_population_vacc
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
rolling_total_vaccination numeric
)





INSERT INTO #Percent_population_vacc
select 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) as rolling_total_vaccination

from covidDeaths cd
JOIN 
covidVaccinations cv
on
cd.location = cv.location
and 
cd.date = cv.date
where cd.continent is not null


--Getting rolling total of vaccination count and vaccinated percentage of population starting from the first vaccinated date.


select *,
convert(DECIMAL(5,2),(rolling_total_vaccination/population*100)) as percent_vaccinated
from #Percent_population_vacc
where rolling_total_vaccination is not null


--CREATE VIEW OF TOP 3 countries in every continent with highest percent vaccination BETWEEN '2020-05-01' and '2021-12-31'

CREATE VIEW Top3_vaccinated as 


--looking at total population vs vaccination

with popvacc as

(select 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) as rolling_total_vaccination

from covidDeaths cd
JOIN 
covidVaccinations cv
on
cd.location = cv.location
and 
cd.date = cv.date
where cd.continent is not null
)


--Getting Top 3 countries in every continent with highest percent vaccination.
  --(used JOINS, Used aggregate functions, Sub Query, Windows function, Assigned Rows and limited to top N countries from each continent)
	--(we can also get the bottom N countries by removing 'DESC' from the ROW_NUMBER ORDER BY clause)


select * from
(select 
ROW_NUMBER() OVER (PARTITION BY continent ORDER BY percent_vaccinated DESC ) AS Sr_No,
*
from(
select 
continent, 
location,
max(rolling_total_vaccination) as max_total_vaccination,
round(max(rolling_total_vaccination/population*100),2) as percent_vaccinated
from popvacc
where date between '2020-05-01' and '2021-12-31'
group by continent, location) t1) t2
where Sr_No <= 3

