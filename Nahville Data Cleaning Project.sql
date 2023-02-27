use PortfolioProject_1

-------------Cleaning data in SQL queries--------------------


select * from Nashville_housing

--------------------------------------------------------------
--Standardize date format

select sale_date, sale_date_cleaned from Nashville_housing



ALTER TABLE Nashville_housing
ADD sale_date_cleaned DATE;

UPDATE Nashville_housing 
SET sale_date_cleaned = convert(date, sale_date)


--------------------------------------------------------------

--populate property address data where property_address is a blank


select property_address from Nashville_housing
where property_address is null
order by Parcel_ID;


select nh1.Parcel_ID, nh1.Property_Address, nh2.Parcel_ID, nh2.Property_Address, ISNULL(nh1.Property_Address, nh2.Property_Address)
from Nashville_housing nh1
join Nashville_housing nh2
on nh1.Parcel_ID = nh2.Parcel_ID
and nh1.unique_id <> nh2.unique_id
where nh1.Property_Address is null

/*
This code updates the "property_address" column in the "Nashville_housing" table where it is null. 
It does this by joining the "Nashville_housing" table to itself on the "Parcel_ID" column, excluding 
any rows where the "unique_id" is the same. This ensures that only rows with the same "Parcel_ID" 
but different "unique_id" are compared.

The ISNULL function is then used to update the null "property_address" value with a non-null value 
from another row where the "Parcel_ID" matches and the "unique_id" is different.*/

UPDATE nh1
SET property_address = ISNULL(nh1.Property_Address, nh2.Property_Address)
from Nashville_housing nh1
join Nashville_housing nh2
on nh1.Parcel_ID = nh2.Parcel_ID
and nh1.unique_id <> nh2.unique_id
where nh1.Property_Address is null


--------------------------------------------------------------

-- Breaking address into induvisual columns (Address, City)

select property_address from Nashville_housing

SELECT
SUBSTRING(Property_address, 1, CHARINDEX(',', Property_address)-1) AS Address,
SUBSTRING(Property_address, CHARINDEX(',', Property_address)+1, LEN(Property_address)) AS City
from Nashville_housing

-- Add a new column called Property_address_split

ALTER TABLE Nashville_housing
ADD Property_address_split NVARCHAR(255);

-- Update the new column with the address information

UPDATE Nashville_housing
SET Property_address_split = SUBSTRING(Property_address, 1, CHARINDEX(',', Property_address)-1);

-- Add a new column called Property_city

ALTER TABLE Nashville_housing
ADD Property_City NVARCHAR(255);

-- Update the new column with the city information

UPDATE Nashville_housing
SET Property_city = SUBSTRING(Property_address, CHARINDEX(',', Property_address)+1, LEN(Property_address));

-- Select the original address column and the new columns for Address and City

SELECT 
Property_address, 
Property_address_split, 
Property_city 
FROM 
Nashville_housing

--------------------------------------------------------------
-- Breaking address into induvisual columns when there are more than one delimitter (Address, City, State)

--address = owner's address
SELECT
address
FROM 
Nashville_housing

/*This SQL query is extracting the owner's address, city, and state from the "address" column in the
"Nashville_housing" table.

REPLACE is used to replace the commas in the address with periods so that the PARSENAME 
function can be used to split the address into segments.

PARSENAME is used to split the address into segments based on the periods. 

The third, second, and first segments are selected for the owner's address, city, and state, respectively.

TRIM is used to remove any extra spaces from the segments.
*/

select 
TRIM(PARSENAME(REPLACE(address,',','.'), 3)) AS Owner_address,
TRIM(PARSENAME(REPLACE(address,',','.'), 2)) AS Owner_city,
TRIM(PARSENAME(REPLACE(address,',','.'), 1)) AS Owner_state
from 
Nashville_housing

-- Add new columns for parsed address
ALTER TABLE Nashville_housing
ADD 
Owner_address NVARCHAR(255),
Owner_city NVARCHAR(255),
Owner_state NVARCHAR(255)

-- Parse address and update new columns
UPDATE Nashville_housing
SET
Owner_address = TRIM(PARSENAME(REPLACE(address,',','.'), 3)),
Owner_city = TRIM(PARSENAME(REPLACE(address,',','.'), 2)),
Owner_state = TRIM(PARSENAME(REPLACE(address,',','.'), 1))

-- Display parsed address columns
SELECT 
address,
Owner_address,
Owner_city,
Owner_state
FROM Nashville_housing

--------------------------------------------------------------
-- Change Y and N to Yes and No for uniformity in data

--Count the number of properties sold as vacant and group them by "Sold_As_Vacant" column
-- to see if there is uniformity in data as the value can onlye be "yes" or "no".
SELECT 
DISTINCT(Sold_As_Vacant),
COUNT(Sold_As_Vacant) AS count
FROM Nashville_housing
GROUP BY Sold_As_Vacant
order by 2

--Replacing Y and N with Yes and No values
SELECT 
Sold_As_Vacant,
CASE WHEN Sold_As_Vacant = 'Y' THEN 'Yes'
	 WHEN Sold_As_Vacant = 'N' THEN 'No'
	 ELSE Sold_As_Vacant
	 END 
FROM Nashville_housing

--Updates the "Sold_As_Vacant" column with the standardized values.
UPDATE Nashville_housing
SET Sold_As_Vacant = 
CASE WHEN Sold_As_Vacant = 'Y' THEN 'Yes'
	 WHEN Sold_As_Vacant = 'N' THEN 'No'
	 ELSE Sold_As_Vacant
	 END

--------------------------------------------------------------

/* Finding duplicates by assigning row number to data partitioned (grouping) by 
parcel_id, property_address, sale_date, legal_reference.
If we get a row number 2 assigned to a row that is a duplicate.
*/

WITH Row_num_cte AS
(SELECT 
*,
ROW_NUMBER() OVER (
PARTITION BY 
	parcel_id, 
	property_address, 
	sale_date, 
	legal_reference
	ORDER BY Unique_id) row_num
FROM Nashville_housing
)
--checking if there are any duplicates
Select * from Row_num_cte
WHERE Row_num > 1


--Deleting duplicates from CTE (i.e where row number is greater than 1)
DELETE
FROM Row_num_cte
WHERE row_num > 1



--------------------------------------------------------------
-- Deleting unused columns that we have cleaned/ broken down into parts.

ALTER TABLE Nashville_housing
DROP COLUMN 
	sale_date, 
	property_address, 
	address

SELECT 
*
FROM Nashville_housing
order by sale_date_cleaned
