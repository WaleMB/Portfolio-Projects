SELECT        location, date, total_cases, new_cases, total_deaths, population
FROM   [dbo].[CovidDeaths]   
where continent is not null
Order by 1, 2

--Looking at Total Cases vs Total Deaths
SELECT        location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM   [dbo].[CovidDeaths]


--Looking at Total Cases vs Total Deaths in United Kingdom
SELECT        location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM   [dbo].[CovidDeaths]
Where location like '%Kingdom%'

create view UkCasesVsDeath as
SELECT        location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM   [dbo].[CovidDeaths]
Where location like '%Kingdom%'

--Looking at percentage of cases by population
SELECT        location, date, total_cases, total_deaths, population, (total_cases/population)*100 as cases_percent
FROM   [dbo].[CovidDeaths]

--Looking at countries with the highest case compared to population
SELECT        location, population, MAX(total_cases) as Highest_cases, MAX((total_cases/population)*100) as cases_percent
FROM   [dbo].[CovidDeaths]
where continent is not null
group by location, population 
order by cases_percent desc

--Looking at countries with the total death count
SELECT        location, MAX(cast(total_deaths as int)) as death_count
FROM   [dbo].[CovidDeaths]
where continent is not null
group by location
order by death_count desc

--Looking at continents with the total death count
SELECT        continent, MAX(cast(total_deaths as int)) as death_count
FROM   [dbo].[CovidDeaths]
where continent is not null
group by continent
order by death_count desc

--Looking at global figures
SELECT        date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
FROM   [dbo].[CovidDeaths]
where continent is not null
group by date
order by 1, 2

SELECT         sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
FROM   [dbo].[CovidDeaths]
where continent is not null
order by 1, 2

SELECT        CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
FROM            CovidDeaths 
JOIN CovidVaccinations on CovidDeaths.location = CovidVaccinations.location and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 1, 2

--Looking at population vs vaccination

SELECT        CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
sum(cast(CovidVaccinations.new_vaccinations as int)) over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollings_sum_vacc
FROM            CovidDeaths 
JOIN CovidVaccinations on CovidDeaths.location = CovidVaccinations.location and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 1, 2

-- Use CTE
with popvsvacc (location, date, population, new_vaccination, rollings_sum_vacc)
as
(
SELECT        CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
sum(cast(CovidVaccinations.new_vaccinations as int)) over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollings_sum_vacc
FROM            CovidDeaths 
JOIN CovidVaccinations on CovidDeaths.location = CovidVaccinations.location and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
)
Select *,(rollings_sum_vacc/population)*100 as percent_vacc
from popvsvacc
 
 --Create Time Table
 Drop Table if exists #PercentPopualtionVaccinated
 create table #PercentPopualtionVaccinated 
 (
 location nvarchar(50),
 date datetime,
 population numeric,
 new_vaccination numeric,
 rollings_sum_vacc numeric
 )
 insert into #PercentPopualtionVaccinated
 SELECT        CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollings_sum_vacc
FROM            CovidDeaths 
JOIN CovidVaccinations on CovidDeaths.location = CovidVaccinations.location and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null

Select *, (rollings_sum_vacc/population)*100 as rollingsPercentPopulation
from #PercentPopualtionVaccinated

---Creating a view
create view PercentPopualtionVaccinated as 
 SELECT        CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollings_sum_vacc
FROM            CovidDeaths 
JOIN CovidVaccinations on CovidDeaths.location = CovidVaccinations.location and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null