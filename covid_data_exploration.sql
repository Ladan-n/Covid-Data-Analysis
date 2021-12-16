SELECT * 
FROM covid_schema.coviddeaths
ORDER BY 3,4;

SELECT * 
FROM covid_schema.covidvaccinations
ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_schema.coviddeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths in Canada and Iran
-- Shows the likelihood of dying if you contract covid in each country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_schema.coviddeaths
WHERE Location like '%canada%'
ORDER BY 1,2;

-- Death percentage in Canada is 1.65%.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_schema.coviddeaths
-- WHERE Location like '%iran%'
ORDER BY 1,2;

-- Death percentage in Iran is 2.12%.

-- Looking at the Total cases vs population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS PercentatgePopulationInfected
FROM covid_schema.coviddeaths
-- WHERE location like '%canada%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as PercentatgePopulationInfected
FROM covid_schema.coviddeaths
GROUP BY Location, Population
ORDER BY PercentatgePopulationInfected DESC;

-- Showing the countries with highest death count per population

SELECT Location, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM covid_schema.coviddeaths
WHERE continent <> ''
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Encountered a problem as the data has continents as locations 
-- We needed only countries so the 'WHERE' line is added.

SELECT * 
FROM covid_schema.coviddeaths
WHERE continent <> ''
ORDER BY 3,4;

-- LET'S BREAK THIS DOWN BY CONTINENT

SELECT continent, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM covid_schema.coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM covid_schema.coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) as total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_schema.coviddeaths
-- WHERE Location like '%canada%
WHERE continent <> ""
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) as total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_schema.coviddeaths
WHERE continent <> ""
ORDER BY 1,2;

SELECT * 
FROM covid_schema.covidvaccinations;

-- Lets join the two tables.

SELECT *
FROM covid_schema.coviddeaths dea
JOIN covid_schema.covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date;
 
 -- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_schema.coviddeaths dea
JOIN covid_schema.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ''    
ORDER BY 2, 3;

-- Creating a view table

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE VIEW covid_schema.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM covid_schema.coviddeaths dea
JOIN covid_schema.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 2, 3;

SELECT *
FROM percentpopulationvaccinated;
