# Power BI Dashboard Data Layer & Visual Specification

This directory contains flat, pre-processed CSV export files prepared by `notebooks/07_dashboard_prep.ipynb` for direct import into **Power BI Desktop**.

---

## 📁 Exported Tables Overview

| File Name | Row Count | Primary Power BI Visual | Key Metrics & Dimensions |
|---|---|---|---|
| `dashboard_forecast_vs_actual.csv` | 76,903 | Multi-line Time-Series Chart | `date`, `store_id`, `dept_id`, `weekly_sales`, `predicted_sales`, `abs_error`, `ape`, `low_confidence_ape` |
| `dashboard_inventory_health.csv` | 3,161 | Status Treemap & Distribution Matrix | `store_id`, `dept_id`, `store_type`, `status`, `reorder_point_usd`, `safety_stock_usd`, `simulated_inventory_usd`, `excess_value_inr` |
| `dashboard_sku_alerts.csv` | 2,186 | Actionable Priority Table | `store_id`, `dept_id`, `status`, `reorder_point_usd`, `simulated_inventory_usd`, `excess_value_inr`, `abs_deviation_usd`, `alert_message` |
| `dashboard_summary_kpis.csv` | 1 | Executive KPI Cards | `overall_rmse_usd`, `overall_wape_pct`, `wape_improvement_pct`, `total_excess_inventory_inr`, `healthy_pct`, `understocked_pct`, `overstocked_pct` |

---

## 📐 Data Model & Relationships (Power BI Model View)

When importing into Power BI Desktop, set up relationships between tables using the following keys:

```
+------------------------------------+          +----------------------------------+
| dashboard_forecast_vs_actual       |          | dashboard_inventory_health       |
+------------------------------------+          +----------------------------------+
| store_id   (Key: store_id + dept_id) <------->| store_id                         |
| dept_id                            |          | dept_id                          |
| date                               |          | status                           |
| weekly_sales                       |          | reorder_point_usd                |
| predicted_sales                    |          | safety_stock_usd                 |
| low_confidence_ape                 |          | simulated_inventory_usd          |
+------------------------------------+          | excess_value_inr                 |
                                                +----------------------------------+
                                                                 ^
                                                                 | (Filter: status != 'Healthy')
                                                                 v
                                                +----------------------------------+
                                                | dashboard_sku_alerts             |
                                                +----------------------------------+
                                                | store_id, dept_id                |
                                                | abs_deviation_usd                |
                                                | alert_message                    |
                                                +----------------------------------+
```

### Relationship Rules:
1. **`dashboard_forecast_vs_actual` ↔ `dashboard_inventory_health`**: Many-to-One composite relationship on `store_id` and `dept_id`.
2. **`dashboard_inventory_health` ↔ `dashboard_sku_alerts`**: One-to-One relationship on `store_id` and `dept_id` (alerts table is a filtered subset containing Understocked and Overstocked SKUs).
3. **`dashboard_summary_kpis`**: Standalone disconnected table used solely for top-level KPI Card visualizations.

---

## 🎨 Recommended Power BI Page Layout & Visuals

### Page 1: Executive Demand Forecasting Dashboard
- **Top Summary Bar (KPI Cards)**:
  - **Overall WAPE**: `overall_wape_pct` (7.77%)
  - **WAPE Improvement**: `wape_improvement_pct` (29.24% vs. Naive Baseline)
  - **Overall RMSE**: `overall_rmse_usd` ($2,586.34)
- **Main Visual (Line Chart)**:
  - **X-Axis**: `date`
  - **Y-Axis**: Sum of `weekly_sales` (Actuals) vs. Sum of `predicted_sales` (Random Forest Forecast)
  - **Legend**: Category / `store_type`
  - **Visual Filter**: Add page filter `low_confidence_ape = FALSE` for APE measures to exclude near-zero demand distorting rows.

### Page 2: Inventory Optimization & Risk Management
- **Headline KPI Cards**:
  - **Total Excess Capital Blocked**: `total_excess_inventory_inr` (₹72.84 Crore)
  - **Inventory Health Split**: % Healthy (30.8%), % Overstocked (60.6%), % Understocked (8.5%)
- **Visual 1 (Treemap / Donut Chart)**:
  - **Category**: `status` (Healthy, Overstocked, Understocked)
  - **Values**: Count of `dept_id` or Sum of `simulated_inventory_usd`
- **Visual 2 (Priority Alert Table)**:
  - **Data Source**: `dashboard_sku_alerts.csv`
  - **Columns**: `store_id`, `dept_id`, `store_type`, `status`, `abs_deviation_usd`, `alert_message`
  - **Sort Order**: Descending by `abs_deviation_usd` (highlights largest inventory discrepancies first).

---

## 💡 Best Practices & DAX Measures

- **Weighted Absolute Percentage Error (WAPE)** DAX Formula:
  ```dax
  WAPE = 
  DIVIDE(
      SUM('dashboard_forecast_vs_actual'[abs_error]),
      SUM('dashboard_forecast_vs_actual'[weekly_sales]),
      BLANK()
  )
  ```
- **Filtered APE** (excluding low-volume rows):
  ```dax
  Filtered_MAPE = 
  CALCULATE(
      AVERAGE('dashboard_forecast_vs_actual'[ape]),
      'dashboard_forecast_vs_actual'[low_confidence_ape] = FALSE()
  )
  ```
