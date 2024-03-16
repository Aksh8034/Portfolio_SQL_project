select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [portfolio_project].[dbo].[covid_deaths]
where location like '%states%' and date >'2020-12-31'
order by 1,2;

--countries with highest infection rate
select location,population, max(total_cases)as max_cases,max((total_cases/population))*100 as infected_population 
from [portfolio_project].[dbo].[covid_deaths]
where date >'2020-12-31' and continent is not null 
group by location,population
order by infected_population desc;

--countries with highest death count
select location, max(cast(total_deaths as int))as totaldeaths--max((total_deaths/population))*100 as deathpercentage 
from [portfolio_project].[dbo].[covid_deaths]
where date >'2020-12-31' and continent is not null
group by location, population
order by totaldeaths desc;

--breaking up using continent 
select continent, max(cast(total_deaths as int))as totaldeaths--max((total_deaths/population))*100 as deathpercentage 
from [portfolio_project].[dbo].[covid_deaths]
where date >'2020-12-31' and continent is not null
group by continent
order by totaldeaths desc;

--global numbers
select sum(total_deaths)as total_deaths, sum(total_cases)as total_cases, (sum(total_deaths)/sum(total_cases))*100 as death_percentage
from [portfolio_project].[dbo].[covid_deaths]
where continent is not null
--group by continent
order by 1,2
 
--joining tables
select * 
from [portfolio_project].[dbo].[covid_deaths] as cd
join [portfolio_project].[dbo].[covid_vaccine] as cv
on cd.location=cv.location and cd.date=cv.date;

select * from [portfolio_project].[dbo].[covid_vaccine]

alter table [portfolio_project].[dbo].[covid_vaccine]
alter column new_vaccinations bigint
select sum(new_vaccinations) as t_v from [portfolio_project].[dbo].[covid_vaccine];

--total amount of people vaccinated
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date rows unbounded preceding) as rolling_sum --partition is helping in taking the rolling sum by location
from [portfolio_project].[dbo].[covid_deaths] as cd
join [portfolio_project].[dbo].[covid_vaccine] as cv
on cd.location=cv.location and cd.date=cv.date 
where cd.continent is not null and cd.date >'2020-12-31' and new_vaccinations is not null
order by 2,3;
-- unbounded preceding ??
--create views

--CTE table (no. of cols in cte should equal to original table)
with popvsvac (continent, location,date,population,rolling_sum,new_vaccinations)
as
(
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date rows unbounded preceding) as rolling_sum --partition is helping in taking the rolling sum by location
from [portfolio_project].[dbo].[covid_deaths] as cd
join [portfolio_project].[dbo].[covid_vaccine] as cv
on cd.location=cv.location and cd.date=cv.date 
where cd.continent is not null and cd.date >'2020-12-31' and new_vaccinations is not null 
)
select *,(rolling_sum/population)*100
from popvsvac


-- views
create view  
sum_ as
select sum(total_deaths)as total_deaths, sum(total_cases)as total_cases, (sum(total_deaths)/sum(total_cases))*100 as death_percentage
from [portfolio_project].[dbo].[covid_deaths]
where continent is not null
--group by continent
--order by 2,3

create view population_vac as
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date rows unbounded preceding) as rolling_sum --partition is helping in taking the rolling sum by location
from [portfolio_project].[dbo].[covid_deaths] as cd
join [portfolio_project].[dbo].[covid_vaccine] as cv
on cd.location=cv.location and cd.date=cv.date 
where cd.continent is not null and cd.date >'2020-12-31' and new_vaccinations is not null 