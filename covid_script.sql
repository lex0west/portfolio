--Vaccination and Death Trends from COVID19 
--Data dated: February 2020 - February 2023
--Source: ourworldindata.org 

--First we're taking a look at our data sets

SELECT *
FROM covid_deaths
ORDER BY 3, 4

SELECT *
FROM covid_vax
ORDER BY 3, 4

--Selecting the data we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2

--Looking at Total Cases VS Total Deaths
--Shows the likelihood of dying from covid across the globe 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%States%'
AND continent is not null
ORDER BY 1, 2

--Creating a View for US Death Percentages
--This allows for visualization in other programs

CREATE VIEW us_death_percentage as

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%States%'
AND continent is not null
ORDER BY 1, 2

--Looking at Total Cases VS Population
--Shows what percentage of the population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
FROM covid_deaths
--WHERE location LIKE '%States%'
ORDER BY 1, 2

--Creating a View for visualizations

CREATE VIEW percent_population_infected as
SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
FROM covid_deaths
WHERE continent is not null

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM covid_deaths
WHERE total_cases is not null
AND population is not null
AND continent is not null
GROUP BY location, population
ORDER BY percent_population_infected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE total_deaths is not null
AND continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--Showing continents with highest death count per population

SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE total_deaths is not null
AND continent is null
GROUP BY location
ORDER BY total_death_count DESC

--Creating a View for Vizualization

CREATE VIEW continent_death_count as

SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE total_deaths is not null
AND continent is null
GROUP BY location


--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as death_percentage
FROM covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as death_percentage
FROM covid_deaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Total Population VS Vaccination

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_people_vaccinated
FROM covid_deaths as death
JOIN covid_vax as vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent is not null
ORDER BY 2, 3

--Calculating the Data using a few different methods
--Using CTE

WITH Pop_vs_vax (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_people_vaccinated
FROM covid_deaths as death
JOIN covid_vax as vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent is not null
)

SELECT *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
FROM pop_vs_vax

--Using a Temp Table

DROP TABLE if exists percent_population_vax
CREATE TABLE percent_population_vax

(
continent text,
	location text,
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
)

INSERT INTO percent_population_vax
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_people_vaccinated
FROM covid_deaths as death
JOIN covid_vax as vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
FROM percent_population_vax

--Creating a View for Visualizations

CREATE VIEW percent_population_vaccinated as
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_people_vaccinated
FROM covid_deaths as death
JOIN covid_vax as vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent is not null