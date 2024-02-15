/*

Cleaning data in SQL

Jarred Petersen
*/

-- In this project, I will be using SQL to clean a dataset relating to Nashville housing sales.

------------------------------------------------------------------------------------------------------


SELECT *
FROM datacleaning.dbo.NashvilleHousing

-- Viewing data set, there are several things that need to be cleaned:
-- 1) Standardize date format in SaleDate variable
-- 2) Clean Null Values in PropertyAddress
-- 3) Take components of "PropertyAddress" and put them into their own columns (Address & City)
-- 4) Take components of "OwnerAddress" and separate into their own columns (Address, City, State)
-- 5) "SoldAsVacant" has 4 values; Y, Yes, N, and NO. Convert Y to Yes, and N to No
-- 6) Remove duplicate values from the data


-------------------------------------------------------------------------------------------------------


-- 1) Standardize date format in SaleDate variable

-- Select SaleDate variable from table 

SELECT SaleDate                                  
FROM datacleaning.dbo.NashvilleHousing



-- Create new variable in table with correct date format in table
-- firstly, add "CorrectDate" column

ALTER TABLE datacleaning.dbo.NashvilleHousing   
ADD CorrectDate DATE;



--Next, we set "CorrectDate" as "SalesDale" column converted to date format

UPDATE datacleaning.dbo.NashvilleHousing
SET CorrectDate = CONVERT(DATE,SaleDate)



-- View SaleDate variable to see if we have successfully changed the date format

SELECT CorrectDate                                
FROM datacleaning.dbo.NashvilleHousing



-- We now have the date in the correct format, we can now drop the "SaleDate" column form table

ALTER TABLE datacleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate



-- View entire table to check "SaleDate" column was successfully dropped

SELECT *
FROM datacleaning.dbo.NashvilleHousing



-- "SaleDate" has been successfully dropped, and "CorrectDate" added

------------------------------------------------------------------------------------------------------

-- 2) NULL values in "PropertyAddress"

-- View all data where "PropertyAddress" is NULL

SELECT *
FROM datacleaning.dbo.NashvilleHousing
WHERE PropertyAddress is null 



-- Group by "ParcelID" to find matching "ParcelID" values
-- Where "ParcelID" match, "PropertyAddress" is the same

SELECT *
FROM datacleaning.dbo.NashvilleHousing
ORDER BY ParcelID



-- if Properties have same ParcelID, use same PropertyAddress to populate NULL value

-- Use "JOIN" to Join the table to itself Where ParcelID from table a = ParcelID from table b
-- and where the "UniqueID" from table a is not equal to "UniqueID" from table b
-- and where "PropertyAddress" in table a ISNULL, use "PropertyAddress" from table b

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM datacleaning.dbo.NashvilleHousing a
JOIN datacleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL 

-- Here we see the matching "ParcelID" in table a and table b, and where the "PropertyAddress" in table a is NULL


-- Update table to populate "PropertyAddress" in a where "PropertyAddress" is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM datacleaning.dbo.NashvilleHousing a
JOIN datacleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL 



-- View all data where Property Address is NULL

SELECT *
FROM datacleaning.dbo.NashvilleHousing
WHERE PropertyAddress is null 

-- There is now no NULL values in "PropertyAddress"


------------------------------------------------------------------------------------------------------

-- 3) Take components of "PropertyAddress" and put them into their own columns
-- e.g. Address, City


-- Select "PropertyAddress" column

SELECT PropertyAddress
FROM datacleaning.dbo.NashvilleHousing


-- Use SUBSTRING and CHARINDEX to seperate "PropertyAddress" by ' , ' to get address
-- -1 removes comma from remaining string so we should just have the address
-- Store address in "Address" column

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)-1) AS Address
FROM datacleaning.dbo.NashvilleHousing


-- Use SUBSTRING and CHARINDEX to seperate "PropertyAddress" by ' , ' tp get city
-- +1 allows us to go to the other side of the ' , ' and then take the remaining length of value as city

SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM datacleaning.dbo.NashvilleHousing


-- Alter table to add two new columns for Address and City

-- Add column for address data & populate column with data

ALTER TABLE datacleaning.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE datacleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)-1)


-- Add column for city data & populate column with data

ALTER TABLE datacleaning.dbo.NashvilleHousing
ADD PropertyCityAddress NVARCHAR(255);

UPDATE datacleaning.dbo.NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress) + 1, LEN(PropertyAddress))


-- Select "PropertySplitAddress and "PropertyCityAddress"

SELECT PropertySplitAddress, PropertyCityAddress
FROM datacleaning.dbo.NashvilleHousing 


-- Address and City data is now in separate columns


-- Remove "PropertyAddress" from table 

ALTER TABLE datacleaning.dbo.NashvilleHousing
DROP COLUMN PropertyAddress



-- View entire data set

SELECT * 
FROM datacleaning.dbo.NashvilleHousing

-- "PropertyAddress" has been successfully dropped from table. Table has new columns "PropertySplitAddress" and "PropertyCityAddress"


------------------------------------------------------------------------------------------------------

-- Separte data in "OwnerAddress" into its own columns 
-- e.g Address, City, State

SELECT OwnerAddress
FROM datacleaning.dbo.NashvilleHousing


-- Using PARSENAME instead of SUBSTRING to separate "OwnerAddress" data in Address, City, State

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM datacleaning.dbo.NashvilleHousing


-- Add Columns to table for separated OwnerAddress, OwnerCity, OwnerState and populate with data

-- OwnerSplitAddress

ALTER TABLE datacleaning.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE datacleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


-- OwnerCity

ALTER TABLE datacleaning.dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE datacleaning.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-- OwnerState

ALTER TABLE datacleaning.dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE datacleaning.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Select new columns

SELECT OwnerSplitAddress, OwnerCity, OwnerState
FROM datacleaning.dbo.NashvilleHousing

-- We now have the three columns; "OwnerSplitAddress", "OwnerCity", "OwnerState" populated with the separate data taken from "OwnerAddress"


-- Remove "OwnerAddress" from table

ALTER TABLE datacleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress



-- View entire data set

SELECT * 
FROM datacleaning.dbo.NashvilleHousing

-- "OwnerAddress" has been successfully dropped from table


-----------------------------------------------------------------------------------------------------

-- 5) Clean "SoldAsVacant" column
-- Currently, the column has 4 values, Y, N, Yes & No. As shown below:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM datacleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant


-- I will change Y values to Yes, and N values to No

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM datacleaning.dbo.NashvilleHousing


-- We now update the table with this converted values

UPDATE datacleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM datacleaning.dbo.NashvilleHousing


-- Check distinct values in "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM datacleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant

-- We know only have "Yes" and "No" values in the "SoldAsVacant" column

-----------------------------------------------------------------------------------------------------

-- 6) Remove duplicate values in data 

-- Create a temp table called CTE of duplicate values

-- Using "ParcelID", "PropertySplitAddress", "SalePrice", "CorrectDate" and "LegalReference"
-- CTE will assign row numbers. If duplicate value, will have row number > 1 (e.g 2 or 3)
-- Can then delete from CTE where row number is > 1


WITH HousingCTE AS ( 
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 CorrectDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM datacleaning.dbo.NashvilleHousing
)
DELETE 
FROM HousingCTE
WHERE row_num > 1



-----------------------------------------------------------------------------------------------------

-- 7) View final data set

SELECT *
FROM datacleaning.dbo.NashvilleHousing

-- We have successfully:
-- Viewing data set, there are several things needing to be cleaned:
-- 1) Standardized date format in "SaleDate" column. Created "CorrectDate" column with correct data format. 
-- 2) Clean Null Values in PropertyAddress
-- 3) Take components of "PropertyAddress" and put them into their own columns (Address & City)
-- 4) Take components of "OwnerAddress" and separate into their own columns (Address, City, State)
-- 5) "SoldAsVacant" has 4 values; Y, Yes, N, and NO. Convert Y to Yes, and N to No
-- 6) Remove duplicate values from the data using a CTE
-- 7) Removed unnecessary columns from table ("SaleDate", "PropertyAddress", "OwnerAddress")

-- This concludes my data cleaning project using SQL, thank you!
