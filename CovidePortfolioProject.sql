Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at total case vs total deaths
-- show likelyhood of dying it you contract the covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%italy%'
where continent is not NULL
order by 1,2

--- looking total cases vs population
-- shows what percantate got covid
Select location, date, total_cases, population, (total_cases/population) * 100 AS CovidInfected
from PortfolioProject.dbo.CovidDeaths
-- where location like '%italy%'
where continent is not NULL
order by 1,2

-- Looking at the country with the highest infection rate compared to population
Select location, population, MAX(total_cases) as highestInfection,  Max((total_cases/population)) * 100 AS PercentagePopupationInfected
from PortfolioProject.dbo.CovidDeaths
-- where location like '%italy%'
where continent is not NULL
group by location, population
order by PercentagePopupationInfected desc


-- Showing Countries with the highest death count per location
Select location, MAX(total_deaths) as highestDeathCount
from PortfolioProject.dbo.CovidDeaths
-- where location like '%italy%'
where continent is not NULL
group by location
order by highestDeathCount DESC

-- Showing Countries with the highest death count per continent
Select continent, MAX(total_deaths) as highestDeathCount
from PortfolioProject.dbo.CovidDeaths
-- where location like '%italy%'
where continent is not NULL
group by continent
order by highestDeathCount DESC

SET ARITHABORT OFF -- in order to remove the divide by 0 error
-- Global numbers
select  SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths) / SUM(new_cases) *100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where continent is not null and new_cases is not null
--group by date
order by 1,2

-- Looking total population vs vaccination



Select Cdea.continent,Cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
, SUM(cvac.new_vaccinations) over (partition by cdea.location order by cdea.location, cdea.date) as rollingPeopleVaccinated
-- ollingPeopleVaccinated/population) *100
from PortfolioProject.dbo.CovidDeaths Cdea
join PortfolioProject.dbo.CovidVaccinations	Cvac
ON Cdea.location = Cvac.location and Cdea.date = cvac.date
where cdea.continent is not null
order by 1,2,3


-- cte use

with PopvsVacs (continent, location, date, population, New_vaccinations, rollingVaccinated)
as 
(
Select Cdea.continent,Cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
, SUM(cvac.new_vaccinations) over (partition by cdea.location order by cdea.location, cdea.date) as rollingPeopleVaccinated
-- ollingPeopleVaccinated/population) *100
from PortfolioProject.dbo.CovidDeaths Cdea
join PortfolioProject.dbo.CovidVaccinations	Cvac
ON Cdea.location = Cvac.location and Cdea.date = cvac.date
where cdea.continent is not null
--order by 2,3
)
Select *, (rollingVaccinated/population)*100
from PopvsVacs


-- Temp table
Drop table if exists #PercentPopupulationVaccinated -- add every time
Create Table #PercentPopupulationVaccinated
(
Continent  nvarchar(50),
Location  nvarchar(50),
date  datetime,
population  numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopupulationVaccinated
Select Cdea.continent,Cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
, SUM(cvac.new_vaccinations) over (partition by cdea.location order by cdea.location, cdea.date) as rollingPeopleVaccinated
-- ollingPeopleVaccinated/population) *100
from PortfolioProject.dbo.CovidDeaths Cdea
join PortfolioProject.dbo.CovidVaccinations	Cvac
ON Cdea.location = Cvac.location and Cdea.date = cvac.date
where cdea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopupulationVaccinated


-- VIEWS to store date for later visualization

Create View PercentPopupationVaccinated as 
Select Cdea.continent,Cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
, SUM(cvac.new_vaccinations) over (partition by cdea.location order by cdea.location, cdea.date) as rollingPeopleVaccinated
-- ollingPeopleVaccinated/population) *100
from PortfolioProject.dbo.CovidDeaths Cdea
join PortfolioProject.dbo.CovidVaccinations	Cvac
ON Cdea.location = Cvac.location and Cdea.date = cvac.date
where cdea.continent is not null
--order by 2,3