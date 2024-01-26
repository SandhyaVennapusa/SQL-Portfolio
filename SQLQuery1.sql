SELECT *
FROM Portofolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM Portofolioproject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portofolioproject..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as death_percentage
FROM Portofolioproject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2

--Total cases vs population
SELECT location, date, population, total_cases,(total_cases/population)*100 as infectedpercentage
FROM Portofolioproject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2

-- countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as infectedpercentage
FROM Portofolioproject..CovidDeaths
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY 4 DESC

--- By Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolioproject..CovidDeaths
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolioproject..CovidDeaths
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolioproject..CovidDeaths
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portofolioproject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- total cases, total deaths as of 24 jan 2024 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portofolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT * 
FROM Portofolioproject..CovidVaccinations

-- Joining both tables deaths and vaccinations

SELECT * 
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
ORDER BY dea.date 

-- total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- total vaccinations by country
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentofVaccination
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations
USE Portofolioproject
GO
CREATE View VaccinatedPeople as 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM Portofolioproject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM VaccinatedPeople

