SELECT *
FROM PortfolioProject..COVIDdeaths

order by 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDdeaths
order by 1,2

--Total cases vs total deaths
-- likelyhood of dying from contracting COVID (U.S)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRATIO
FROM PortfolioProject..COVIDdeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, total_deaths, (total_cases/population)*100 AS CasePopulation
FROM PortfolioProject..COVIDdeaths
WHERE location like '%states%'
order by 1,2

-- countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population))*100 AS PopulationInfected
FROM PortfolioProject..COVIDdeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PopulationInfected desc

-- countries with highest death count per population (  )

SELECT location, MAX(cast(Total_deaths as int)) as totaldeathcount
FROM PortfolioProject..COVIDdeaths
WHERE continent is null
GROUP BY location
order by totaldeathcount desc

--Continents with highest death count per pop


SELECT continent, MAX(cast(Total_deaths as int)) as totaldeathcount
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
GROUP BY continent
order by totaldeathcount desc



--Global #'s

SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathRATIO
FROM PortfolioProject..COVIDdeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

-- COVID VACCINATIONS


SELECT * 
FROM PortfolioProject..COVIDdeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS RollingCountPeopleVacc
--, (RollingCountPeopleVacc/population)*100
FROM PortfolioProject..COVIDdeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE

WITH PopvsVac (Continent, Locaiton, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS RollingCountPeopleVacc
--, (RollingCountPeopleVacc/population)*100
FROM PortfolioProject..COVIDdeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM PopvsVac


--temp table
DROP table if exists #PercentPopVaccinated

Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS RollingCountPeopleVacc
--, (RollingCountPeopleVacc/population)*100
FROM PortfolioProject..COVIDdeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS RollingPercentVaccinated 
FROM #PercentPopVaccinated


SELECT *
FROM #PercentPopVaccinated

--Creating view to store data for Tableau
Create View PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS RollingCountPeopleVacc
--, (RollingCountPeopleVacc/population)*100
FROM PortfolioProject..COVIDdeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null