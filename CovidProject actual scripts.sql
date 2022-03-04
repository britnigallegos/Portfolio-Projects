SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT lOCATION, DATe,TOTAL_CASES,NEW_CASES, TOTAL_DEATHS, POPULATION
FROM PortfolioProject.. CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT lOCATION, DATe, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.. CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total cases vs population 
--shows what percentage of population got COVID

SELECT lOCATION, DATe, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.. CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT lOCATION, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
GROUP BY lOCATION, population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT pt 2

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

	-- Showing continents with the highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc

	-- GLOBAL NUMBERS/Total Global

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) as Total_Deaths,SUM(CAST(NEW_DEATHS AS INT))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

--GLOBAL NUMBERS / By Date

SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) as Total_Deaths,SUM(CAST(NEW_DEATHS AS INT))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

 --Looking at Total Population vs Vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population*100
  FROM PortfolioProject.. CovidDeaths dea
 Join PortfolioProject.. CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- USE CTE

 With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
 as 
  (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population*100
  FROM PortfolioProject.. CovidDeaths dea
 Join PortfolioProject.. CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3
 )
 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac

 -- TEMP TABLE

 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinate numeric
 )
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinate
 --, (RollingPeopleVaccinated/population*100
  FROM PortfolioProject.. CovidDeaths dea
 Join PortfolioProject.. CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3
 
SELECT *,(RollingPeopleVaccinate/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PopulationVaccPercent as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
  FROM PortfolioProject.. CovidDeaths dea
 Join PortfolioProject.. CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select *
 From PopulationVaccPercent