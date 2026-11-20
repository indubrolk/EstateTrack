# EstateTrack

A responsive Next.js prototype of the Sri Lankan tea estate management system described in the community project proposal. The sample estate opens on 18 November 2026 with 128 fictional workers across three divisions.

## Run locally

Use Node.js 20.9 or later. Run `npm ci`, then `npm run dev` and open the local URL printed by Next.js. For the production version, run `npm run build` followed by `npm start`. The build also produces a static site in `out/`.

## Try the daily workflow

1. Open **Record field entry**. Select a date, worker, and attendance status, then enter the collection weight and field block. English, Sinhala, and Tamil entry labels are available.
2. Review the results in **Attendance**, **Harvest logs**, and the dashboard.
3. Generate a division wage sheet under **Payroll**. Switch demo roles from the profile menu to explore the clerk and manager review screens.
4. Approve a sheet to unlock individual wage slips and SMS receipt previews. Use the browser print dialog to print or save a PDF.
5. Under **Reports**, filter by worker, division, and pay period. The EPF / ETF report includes approved sheets contained within the selected range. Export the selected report as CSV.

## Data and integrations

Records persist in browser storage. The production build caches the application for offline use after its first connected visit. Device-to-server synchronization, identity verification, and live SMS delivery require a backend. The notifications screen records local actions.

Rates are illustrative and editable in Settings. Full days earn the worker's base rate, half days earn half the base rate, and harvest above the prorated norm earns the configured incentive. Employee EPF reduces take-home pay. Employer EPF and ETF are tracked separately. Approved sheets preserve their recorded amounts. Production payroll needs verified estate rules and statutory review.

## Asset credits

The estate banner uses a crop of [Tea plantation Nuwara Eliya](https://commons.wikimedia.org/wiki/File:Tea-plantation_Nuwara_Eliya-2567.jpg) by Bergentroll, dedicated to the public domain under CC0. The interface uses Geist by Vercel and Lucide icons.
