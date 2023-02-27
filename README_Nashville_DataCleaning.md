# PortfolioProjectsSQL
# Nashville Data Cleaning Project

This code is written to clean and standardize the data in the "Nashville_housing" table in a SQL database.

The code includes several SQL queries that perform various data cleaning tasks, including standardizing the date format, 
populating property address data where it is null, breaking the address into individual columns, parsing the owner's address, 
and changing the values of "Y" and "N" in the "Sold_As_Vacant" column to "Yes" and "No" for uniformity.

Here is an overview of the queries used for each cleaning task:

1. Standardize date format:

    Adds a new column "sale_date_cleaned" of DATE data type to the "Nashville_housing" table.
    
    Updates the "sale_date_cleaned" column with the converted "sale_date" column using the CONVERT function.

2. Populate property address data where it is null:

    Finds rows with null values in the "property_address" column using a SELECT statement.
    
    Updates the null "property_address" values with non-null values from another row where the "Parcel_ID" matches and the "unique_id" 
    is different using the ISNULL function.

3. Break address into individual columns:

    Adds a new column "Property_address_split" and "Property_city" to the "Nashville_housing" table of NVARCHAR data type.
    
    Updates the new columns with the address information and the city information using SUBSTRING function.

4. Parse owner's address:

    Parses the owner's address, city, and state from the "address" column using the PARSENAME function and replaces commas
    with periods using the REPLACE function.
    
    Adds new columns for parsed address: "Owner_address", "Owner_city", and "Owner_state" of NVARCHAR data type.
    
    Updates the new columns with the parsed address information using the TRIM and PARSENAME functions.

5. Change "Y" and "N" to "Yes" and "No" for uniformity:

    Counts the number of properties sold as vacant and groups them by the "Sold_As_Vacant" column to check if there 
    is uniformity in the data.
    
    Changes the values of "Y" and "N" in the "Sold_As_Vacant" column to "Yes" and "No" using the CASE statement.



