SELECT * 
FROM SQLPortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM SQLPortfolioProject..CovidVaccinations
--ORDER BY 3,4
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS death_percentage
FROM SQLPortfolioProject..CovidDeaths
--WHERE total_cases IS NOT NULL
--WHERE location LIKE '%India%'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, ((CAST(total_deaths AS INT))/(CAST(total_cases AS INT)))*100 AS death_percentage
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1,2

--Likelihood of increasing deaths
SELECT location, date, total_cases, total_deaths
FROM SQLPortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Looking at total cases by population infected
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_infected
FROM SQLPortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Looking at countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases/population))*100 AS population_infected
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
GROUP BY location, population
ORDER BY population_infected DESC

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Death_count
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY Death_count DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS Death_count
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY Death_count DESC


SELECT location, MAX(CAST(total_deaths AS INT)) AS Death_count
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS null
GROUP BY location
ORDER BY Death_count DESC

--Showing the continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Death_count
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY Death_count DESC

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/(SUM(NULLIF(new_cases,0)))*100 AS death_percentage
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/(SUM(NULLIF(new_cases,0)))*100 AS death_percentage
FROM SQLPortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT * 
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--use CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0) AS new_vaccinations,
 SUM(NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0)) OVER (PARTITION BY dea.location)
--ORDER BY dea.location, 
--CAST (dea.date AS DATETIME))
AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac

-- Temp Table


CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0) AS new_vaccinations,
 SUM(NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0)) OVER (PARTITION BY dea.location)
--ORDER BY dea.location, 
--CAST (dea.date AS DATETIME))
AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Drop Table
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--RollingPeopleVaccinated numeric,
--)

--INSERT INTO #PercentPopulationVaccinated

--SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0) AS new_vaccinations,
-- SUM(NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0)) OVER (PARTITION BY dea.location)
----ORDER BY dea.location, 
----CAST (dea.date AS DATETIME))
--AS RollingPeopleVaccinated
--FROM SQLPortfolioProject..CovidDeaths dea
--JOIN SQLPortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
----WHERE dea.continent is not null
----ORDER BY 2,3

--SELECT *, (RollingPeopleVaccinated/population)*100
--FROM #PercentPopulationVaccinated



--Creating view to store data later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0) AS new_vaccinations,
 SUM(NULLIF(CONVERT(FLOAT, vac.new_vaccinations),0)) OVER (PARTITION BY dea.location)
--ORDER BY dea.location, 
--CAST (dea.date AS DATETIME))
AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * FROM PercentPopulationVaccinated