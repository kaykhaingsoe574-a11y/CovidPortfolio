SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE continent IS NULL
  ORDER BY 3,4

  --SELECT *
  --FROM [PortfolioProject].[dbo].[CovidVaccinations]
  --ORDER BY 3,4


  SELECT location, date,  total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  ORDER BY 1,2

  -----Looking at Total cases Vs Total death

    SELECT location, date,  total_cases, total_deaths, ROUND((total_deaths/ total_cases)*100,2) AS DeathPercentage
    FROM [PortfolioProject].[dbo].[CovidDeaths]
  ORDER BY 1,2

   SELECT location, date,  total_cases, population, ROUND((total_cases/ population)*100,2) AS DeathPercentage
    FROM [PortfolioProject].[dbo].[CovidDeaths]
    WHERE location Like 'My%'
  ORDER BY 1,2

 ----Looking at Highest Infection Rate compared to population

  SELECT location, population, MAX(total_cases) AS HighestInfectionCases, ROUND(MAX((total_cases/population))*100,2) AS PercentagePopulation
    FROM [PortfolioProject].[dbo].[CovidDeaths]
   ---WHERE location Like 'My%'
   GROUP BY location, population
  ORDER BY 4 DESC

  ---SHowing country with highest death count
  SELECT location, MAX(cast (total_deaths as Int)) AS TotalDeathCount
    FROM [PortfolioProject].[dbo].[CovidDeaths]
   ---WHERE location Like 'My%'
   GROUP BY location
  ORDER BY 2 DESC

  ---Let's Break down with Continent
   ---Showing the continent with highest death count
  SELECT continent, MAX(cast (total_deaths as Int)) AS TotalDeathCount
    FROM [PortfolioProject].[dbo].[CovidDeaths]
   ---WHERE location Like 'My%'
   WHERE continent is Not Null
   GROUP BY continent
  ORDER BY 2 DESC

 ----Global Numbers
 SELECT SUM(new_cases) as TotalCases, SUM(CAST(total_deaths as INT)) as TotalDeaths,
 ROUND(SUM(CAST(new_deaths as INT))/ SUM(new_cases)*100,2) AS DeathPercentage
  ----, ROUND((total_deaths/ total_cases)*100,2) AS DeathPercentage
    FROM [PortfolioProject].[dbo].[CovidDeaths]
    WHERE continent is NOT NULL
    ---GROUP BY date
  ORDER BY 1,2


  -----Looking at Total population vs Vaccinations
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) 
        AS RollingPeopleVacainated
  FROM [PortfolioProject].[dbo].[CovidDeaths] dea
  JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.date = vac.date
    AND dea.location = vac.location
    WHEre dea.continent is not null
    Order by 2,3

    ---USE CTE
    With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinatedd)
    AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) 
        AS RollingPeopleVaccinatedd
  FROM [PortfolioProject].[dbo].[CovidDeaths] dea
  JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.date = vac.date
    AND dea.location = vac.location
    WHEre dea.continent is not null
    --Order by 2,3
    )
    SELECT *, (RollingPeopleVaccinatedd/Population)*100 
    FROM PopvsVac



    ----Tem Table
    Drop Table if exists #PercentagePopulationVaccinated
    Create Table #PercentagePopulationVaccinated
    (
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinatedd numeric)



    Insert Into #PercentagePopulationVaccinated
     SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) 
        AS RollingPeopleVaccinatedd
  FROM [PortfolioProject].[dbo].[CovidDeaths] dea
  JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.date = vac.date
    AND dea.location = vac.location
    WHEre dea.continent is not null
    --Order by 2,3
     SELECT *, (RollingPeopleVaccinatedd/Population)*100 
    FROM #PercentagePopulationVaccinated

    --To view for vitualization
    Create View PercentagePopulationVaccinated AS 
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) 
        AS RollingPeopleVaccinatedd
  FROM [PortfolioProject].[dbo].[CovidDeaths] dea
  JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.date = vac.date
    AND dea.location = vac.location
    WHEre dea.continent is not null