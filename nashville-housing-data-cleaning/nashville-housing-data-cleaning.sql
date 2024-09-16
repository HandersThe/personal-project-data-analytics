SELECT *
FROM public.nashville_housing_data


-- Populate propertyaddress data
SELECT *
FROM public.nashville_housing_data
WHERE propertyaddress IS NULL

SELECT *
FROM public.nashville_housing_data
ORDER BY parcelid

UPDATE public.nashville_housing_data a
SET propertyaddress = b.propertyaddress
FROM public.nashville_housing_data b
WHERE a.parcelid = b.parcelid
	AND a.propertyaddress IS NULL
	AND b.propertyaddress IS NOT NULL


-- Breaking out address into individual columns (address, city, state)
SELECT propertyaddress
FROM public.nashville_housing_data

SELECT
SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',') - 1),
SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',') + 1, LENGTH(propertyaddress))
FROM public.nashville_housing_data

ALTER TABLE public.nashville_housing_data
ADD propertysplitaddress varchar(50);

UPDATE public.nashville_housing_data
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',') - 1)

ALTER TABLE public.nashville_housing_data
ADD propertysplitcity varchar(50);

UPDATE public.nashville_housing_data
SET propertysplitcity = SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',') + 1, LENGTH(propertyaddress))


SELECT owneraddress
FROM public.nashville_housing_data

SELECT 
	SPLIT_PART(owneraddress, ',', 1),
	SPLIT_PART(owneraddress, ',', 2),
	SPLIT_PART(owneraddress, ',', 3)
FROM public.nashville_housing_data

ALTER TABLE public.nashville_housing_data
ADD ownersplitaddress varchar(50);

UPDATE public.nashville_housing_data
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE public.nashville_housing_data
ADD ownersplitcity varchar(50);

UPDATE public.nashville_housing_data
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE public.nashville_housing_data
ADD ownersplistate varchar(50);

UPDATE public.nashville_housing_data
SET ownersplistate = SPLIT_PART(owneraddress, ',', 3)


-- Change Y and N to Yes and No in soldasvacant field
SELECT 
	DISTINCT(soldasvacant),
	COUNT(soldasvacant)
FROM public.nashville_housing_data
GROUP BY soldasvacant
ORDER BY 2

SELECT 
	soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
FROM public.nashville_housing_data

UPDATE public.nashville_housing_data
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END


-- Remove duplicates
WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid) AS row_num
FROM public.nashville_housing_data
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress

WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid) AS row_num
FROM public.nashville_housing_data
)
DELETE
FROM public.nashville_housing_data
WHERE uniqueid IN(
	SELECT uniqueid
	FROM RowNumCTE
	WHERE row_num > 1)


-- Delete unused columns
SELECT *
FROM public.nashville_housing_data

ALTER TABLE public.nashville_housing_data
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress