/*

COVID Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 3,4


Select *
From PortfolioProject1..CovidVaccinations
Where continent is not null
Order by 3,4


-- Select beginning data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Cases vs Total Deaths over time (U.S.)
-- Shows likelihood of death if you contract COVID in the U.S. over time

Select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 3) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
And continent is not null
Order by 1,2


-- Total Cases vs Total Deaths over time (world)
-- Shows likelihood of death if you contract COVID in your country over time

Select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 3) as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Order by 1,2


-- Total Cases vs Population over time (world)
-- Shows percentage of population that has tested positive for COVID over time

Select location, date, population, total_cases, ROUND((total_cases/population)*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Order by 1,2


-- Total Cases vs Population over time (U.S.)
-- Shows percentage of population that has tested positive for COVID over time

Select location, date, population, total_cases, ROUND((total_cases/population)*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
Where location like '%states%'
And continent is not null
Order by 1,2


-- Total Cases vs Population over time (U.K.)
-- Shows percentage of population that has tested positive for COVID over time

Select location, date, population, total_cases, ROUND((total_cases/population)*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
Where location like '%kingdom%'
And continent is not null
Order by 1,2


-- Highest Total Cases vs Population (world)
-- Shows total percentage of population that has tested positive for COVID

Select location, population, MAX(total_cases) as TotalCases, ROUND(MAX((total_cases/population))*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalPercentPositive desc


-- Highest Total Death Count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- BREAKING IT DOWN BY CONTINENT

-- Continents with highest death count

--Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject1..CovidDeaths
--Where continent is not null
--Group by continent
--Order by TotalDeathCount desc

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject1..CovidDeaths
--Where continent is null
--Group by location
--Order by TotalDeathCount desc

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Continents with highest case count

Select continent, SUM(new_cases) as TotalCaseCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalCaseCount desc


-- U.S. vs U.K. new cases over time
-- View trend in new cases between U.S. vs U.K.
Select location, date, new_cases
From PortfolioProject1..CovidDeaths
Where location like '%states%'
And continent is not null
Group by location, date, new_cases
Order by new_cases desc

Select location, date, new_cases
From PortfolioProject1..CovidDeaths
Where location like '%kingdom%'
And continent is not null
Group by location, date, new_cases
Order by new_cases desc


-- GLOBAL TOTALS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 3) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs New Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform calculation on Partition By in previous "Total Population vs New Vaccinations" query
-- Shows percentage of population that has received at least one COVID vaccine dose
-- Note: Since this is a sample project only, this example does NOT distinguish between 1st dose, 2nd dose, or booster, so more analysis would be needed for a more accurate Percent Vaccinated over time.

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, ROUND((RollingVaccinations/population)*100, 3) as PercentVaccinated
From PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous "Total Population vs New Vaccinations" query
-- Shows percentage of population that has received at least one COVID vaccine dose
-- Note: Since this is a sample project only, this example does NOT distinguish between 1st dose, 2nd dose, or booster, so more analysis would be needed for a more accurate Percent Vaccinated over time.

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, ROUND((RollingVaccinations/population)*100, 3) as PercentVaccinated
From #PercentPopulationVaccinated


--CREATING VIEWS to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Create View ContinentCaseCount as
Select continent, SUM(new_cases) as TotalCaseCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
--Order by TotalCaseCount desc


Create view ContinentDeathCount as
Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
--Order by TotalDeathCount desc


Create view PercentVaccinated as
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, ROUND((RollingVaccinations/population)*100, 3) as PercentVaccinated
From PopvsVac
