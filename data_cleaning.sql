SELECT * FROM nashville_housing



-- POPULATING PROPERTY ADDRESS COLUMN
--(First I did a self join of the table where property address was null from original table, then on basis of parcelid populated the null values using coalesce function)

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, COALESCE(a.property_address, b.property_address)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
	WHERE a.property_address IS null

--(Next I updated the original table from the above populated column and now the property address column has no null value)

UPDATE nashville_housing
SET property_address = COALESCE(nashville_housing.property_address, b.property_address)
FROM nashville_housing b
WHERE nashville_housing.parcel_id = b.parcel_id
AND nashville_housing.unique_id <> b.unique_id
AND nashville_housing.property_address IS null



-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
-- (First I sperated the poperty address column into two parts using Substring function. One contains the address and the other contains the city)

SELECT property_address, SUBSTRING(property_address, 1, POSITION(',' in property_address)-1) 
FROM nashville_housing

SELECT property_address, SUBSTRING(property_address, POSITION(',' in property_address)+2) 
FROM nashville_housing


-- (Then I added this two newly created columns into the table)

ALTER TABLE nashville_housing
ADD COLUMN property_split_address varchar

UPDATE nashville_housing
set property_split_address = SUBSTRING(property_address, 1, POSITION(',' in property_address)-1)

ALTER TABLE nashville_housing
ADD COLUMN property_city varchar

UPDATE nashville_housing
SET property_city = SUBSTRING(property_address, POSITION(',' in property_address)+2)



-- (Similarly, I split the owner address this time using the split_part function)

SELECT owner_address, 
split_part(owner_address, ', ', 1) AS owner_address_split, 
split_part(owner_address, ', ', 2) AS owner_city, 
split_part(owner_address, ', ', 3) AS owner_state
FROM nashville_housing

ALTER TABLE nashville_housing
ADD COLUMN owner_address_split varchar

UPDATE nashville_housing
SET owner_address_split = split_part(owner_address, ', ', 1)

ALTER TABLE nashville_housing
ADD COLUMN owner_city varchar

UPDATE nashville_housing
SET owner_city = split_part(owner_address, ', ', 2)

ALTER TABLE nashville_housing
ADD COLUMN owner_state varchar

UPDATE nashville_housing
SET owner_state = split_part(owner_address, ', ', 3)



-- CHANGE 'Y' AND 'N' TO 'Yes' AND 'No' IN SOLD AS VACANT
-- (Since there were irregularities in sthe sold_as_vacant column, I have updated the column using CASE)

SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	 WHEN sold_as_vacant = 'N' THEN 'No'
	 ELSE sold_as_vacant
	 END
FROM nashville_housing


UPDATE nashville_housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	 				 WHEN sold_as_vacant = 'N' THEN 'No'
	 				 ELSE sold_as_vacant
	 				 END
					 


-- DELETING UNUSED COLUMNS

ALTER TABLE nashville_housing
DROP COLUMN property_address,
DROP COLUMN owner_address,
DROP COLUMN tax_district



-- FILTERING TABLE
-- (I have filtered the table by land use and then ordered them by thier corresponding date and price using Windows Function)

SELECT *,
RANK() OVER(PARTITION BY land_use ORDER BY sale_date, sale_price)
FROM nashville_housing























