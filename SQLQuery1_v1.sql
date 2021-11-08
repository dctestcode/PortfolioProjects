/*

Queries for Tableau Project

*/


-- 1. Global Totals

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 3) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


-- 2. Death count by continent

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- 3. Percent positive by country

Select location, population, MAX(total_cases) as TotalCases, ROUND(MAX((total_cases/population))*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalPercentPositive desc


-- 4. Percent positive by country over time

Select location, population, date, MAX(total_cases) as TotalCases, ROUND(MAX((total_cases/population))*100, 3) as TotalPercentPositive
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population, date
Order by TotalPercentPositive desc