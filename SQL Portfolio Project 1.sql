SELECT *
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at the Total Cases VS the Total Deaths
-- shows likelyhood of dying of you contact Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases VS Population

SELECT location, date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM CovidDeath
--WHERE location like '%igeri%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeath
--WHERE location like '%igeri%'
GROUP BY location, population
ORDER BY 4 DESC

--Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/poulation))*100 AS PercentPopulationDeath
FROM CovidDeath
--WHERE location like '%igeri%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/poulation))*100 AS PercentPopulationDeath
FROM CovidDeath
--WHERE continent like '%igeri%'
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/poulation))*100 AS PercentPopulationDeath
FROM CovidDeath
--WHERE continent like '%igeri%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- GLOBAL NUMBERS

SET ANSI_WARNINGS OFF
SELECT date, SUM(CAST(new_cases AS FLOAT)), SUM(CAST(new_deaths AS INT)), NULLIF (SUM(CAST(new_deaths AS INT))/SUM(CAST(new_cases AS INT)), 0)*100 AS DeathPercentage
FROM CovidDeath
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT *
FROM CovidVaccination

-- Looking at the Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, (vac.new_vaccinations)
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, (SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)/Population)*100
FROM CovidDeath as dea
JOIN CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeath as dea
JOIN CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac





-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric
,RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeath as dea
JOIN CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeath as dea
JOIN CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

CREATE VIEW HighestDeathContinent AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/poulation))*100 AS PercentPopulationDeath
FROM CovidDeath
--WHERE continent like '%igeri%'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY 2 DESC