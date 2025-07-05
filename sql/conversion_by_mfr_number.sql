sql/conversion_by_mfr_number.sql
-- Conversion Search by Manufacturer Number
-- This query compares primary and cross-reference items by manufacturer number
-- to estimate savings and identify contract opportunities.

WITH price_comparison AS (
  SELECT
    cr.PrimaryUIN,
    cr.CrossUIN,
    cr.Code AS Cross_Item_Code,

    base.Manufacturer_Catalog_Number AS PrimaryMFRNumber,
    base.Manufacturer_Name AS Primary_Manufacturer_Name,
    base.Tier_Name AS Primary_Tier_Name,
    base.Contract_Number AS Primary_Contract_Number,
    base.Item_Short_Description AS Primary_Item_Description,

    cross.Manufacturer_Catalog_Number AS CrossMFRNumber,
    cross.Manufacturer_Name AS Cross_Manufacturer_Name,
    cross.Tier_Name AS Cross_Tier_Name,
    cross.Contract_Number AS Cross_Contract_Number,
    cross.Item_Short_Description AS Cross_Item_Description,

    SAFE_DIVIDE(base.Contract_Unit_Price, base.Contract_UOM_Quantity_Of_Each) AS Primary_Each_Price,
    SAFE_DIVIDE(cross.Contract_Unit_Price, cross.Contract_UOM_Quantity_Of_Each) AS Cross_Each_Price,

    SAFE_DIVIDE(
      SAFE_DIVIDE(base.Contract_Unit_Price, base.Contract_UOM_Quantity_Of_Each)
      - SAFE_DIVIDE(cross.Contract_Unit_Price, cross.Contract_UOM_Quantity_Of_Each),
      SAFE_DIVIDE(base.Contract_Unit_Price, base.Contract_UOM_Quantity_Of_Each)
    ) AS Percent_Savings_Per_Unit

  FROM `project.dataset.item_cross_references` cr
  LEFT JOIN `project.dataset.item_prices` base
    ON cr.PrimaryUIN = base.HealthTrust_UIN
  LEFT JOIN `project.dataset.item_prices` cross
    ON cr.CrossUIN = cross.HealthTrust_UIN

  WHERE base.Manufacturer_Catalog_Number IN (
    -- Replace with relevant manufacturer numbers when deploying
    'MFR001', 'MFR002', 'MFR003', 'MFR004'
  )
),

contract_info AS (
  SELECT
    Contract_Number,
    Contract_Description,
    S2_Eligible_Indicator
  FROM `project.dataset.contracts`
),

summarized_pivot AS (
  SELECT
    pc.Cross_Contract_Number,
    ci.Contract_Description AS Cross_Contract_Description,
    ci.S2_Eligible_Indicator,

    MAX(pc.Primary_Item_Description) AS Primary_Item_Description,
    MAX(pc.Cross_Item_Description) AS Cross_Item_Description,
    MAX(pc.CrossMFRNumber) AS Cross_Manufacturer_Number,

    SUM(pc.Cross_Each_Price) AS total_est_cross_spend,
    SUM(pc.Cross_Each_Price - pc.Primary_Each_Price) AS total_est_savings

  FROM price_comparison pc
  LEFT JOIN contract_info ci
    ON pc.Cross_Contract_Number = ci.Contract_Number

  WHERE pc.Cross_Contract_Number IS NOT NULL
    AND ci.Contract_Description IS NOT NULL
    AND pc.CrossMFRNumber IS NOT NULL
    AND ci.S2_Eligible_Indicator IS NOT NULL
    AND pc.Cross_Each_Price IS NOT NULL

  GROUP BY ROLLUP(
    Cross_Contract_Description,
    Cross_Contract_Number,
    S2_Eligible_Indicator
  )
)

SELECT
  CAST(IFNULL(Cross_Contract_Number, -1) AS STRING) AS Cross_Contract_Number,
  IFNULL(Cross_Contract_Description, '') AS Cross_Contract_Description,
  CAST(IFNULL(S2_Eligible_Indicator, -1) AS STRING) AS S2_Eligible_Indicator,
  Cross_Manufacturer_Number,
  Primary_Item_Description,
  Cross_Item_Description,
  total_est_cross_spend,
  total_est_savings

FROM summarized_pivot

ORDER BY
  Cross_Contract_Description,
  Cross_Contract_Number,
  S2_Eligible_Indicator;
