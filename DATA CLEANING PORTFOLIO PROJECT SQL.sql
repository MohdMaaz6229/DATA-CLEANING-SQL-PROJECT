-- Data Cleaning

SELECT *
FROM layoffs;

-- 1.REMOVE DUPLICATES
-- 2. Standardize the data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;



SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,`date`,stage,funds_raised,
country) AS row_num
FROM layoffs_staging;

WITH duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,`date`,stage,funds_raised,
country) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE Company = 'Casper';


WITH duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,`date`,stage,funds_raised,
country) AS row_num
FROM layoffs_staging
)

DELETE
FROM duplicate_cte
WHERE row_num > 1;



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,`date`,stage,funds_raised,
country) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data ( Find isssues in data and fix it)

SELECT  distinct(company),TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT distinct industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET Industry = 'Crypto'
WHERE Industry LIKE 'Crypto%';

SELECT  *
FROM layoffs_staging2
WHERE Country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM Country)
WHERE Country LIKE 'United States';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `Date` DATE;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


SELECT DISTINCT industry
from layoffs_staging2
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Bally%';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL  ;  

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE(t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;   

SELECT *
FROM layoffs_staging2;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
