select * 
From Covid..Coviddeaths
where continent is not null
order by 3,4


--select * 
--From Covid..Covidvaccinations
--order by 3,4

--select data that we are going to use
select location, date, total_cases, new_cases,total_deaths,population
from covid..Coviddeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows percentage of dying if you contract covid in your country
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid..Coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

--total cases vs population
--shows that percentage of population got covid
select location, date, population,total_cases,(total_cases/population)*100 as percentofpopwithcovid
from covid..Coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2


--countries with highest infection rate compared to population
select location, population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentpopinfected
from covid..Coviddeaths
group by location,population
order by percentpopinfected desc

--countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from covid..Coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

--breaking things down by continent
--continents with highest death count per populatiion
select continent, max(cast(total_deaths as int)) as totaldeathcount
from covid..Coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid..Coviddeaths
where continent is not null
group by date
order by 1,2

--global numbers v2
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid..Coviddeaths
where continent is not null
--group by date
order by 1,2


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..Coviddeaths d
Join covid..Covidvaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..Coviddeaths d
Join covid..Covidvaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #percentpopulationvaccinated

--creating views

create view percentpopulationvaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..Coviddeaths d
Join covid..Covidvaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3

------------------------------------------------------------------------------------------------------

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid..Coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid..Coviddeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..Coviddeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..Coviddeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc