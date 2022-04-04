select*
from dbo.CovidDeaths$
where continent is not null
order by 3,4


select *
from dbo.CovidVaccinations$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths$
order by 1,2
-- looking at total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths$
where continent is not null
order by 1,2

--total cases vs population
-- shows the % of the population that has covid
select location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
order by 1,2


----looking at locations with the highest infection rates
select location, population, MAX(total_cases) as highest_infection, MAX(total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths$
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--looking at countries with the highest death count per population also shows the percentage of the population that died
select location, population, MAX(cast(total_deaths as int)) as TotalDeath, MAX(total_deaths/population)*100 as PercentPopulationDeath
from dbo.CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationDeath desc

-- breakdown of death by continent, shows the highest number of deaths per continent
select continent, MAX(cast(total_deaths as int)) as TotalDeath 
from dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeath desc

--breakdown globally
select SUM(new_cases) as total_newcases, 
SUM(cast(new_deaths as int)) as total_newdeaths,
SUM(cast(new_deaths as int))/SUM (new_cases)*100 as NewDeathPercentage
from dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2 

--looking at Total Population vs Vaccination
Select D.continent, D.location, D.date, D. population, V.new_vaccinations, 
SUM(convert (bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths$ D
Join dbo.CovidVaccinations$ V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 2,3

--USING CTE
with popvsvac(continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated) as
  (Select D.continent, D.location, D.date, D. population, V.new_vaccinations, 
SUM(convert (bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths$ D
Join dbo.CovidVaccinations$ V
on D.location = V.location
and D.date = V.date
where D.continent is not null)
select *, (Rollingpeoplevaccinated/population)*100
from popvsvac as PercentPopulationVaccinated

--USING TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D. population, V.new_vaccinations, 
SUM(convert (bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths$ D
Join dbo.CovidVaccinations$ V
on D.location = V.location
and D.date = V.date
where D.continent is not null

select *, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated as PercentPopulationVaccinated



--creating view to store data for later visualizations
create view PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D. population, V.new_vaccinations, 
SUM(convert (bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths$ D
Join dbo.CovidVaccinations$ V
on D.location = V.location
and D.date = V.date
where D.continent is not null
--order by 2,3