# SUPERMUN dashboard

## Setup

1. Copy the raw data folder from Dropbox to supermun-dasboard/data:

- Option 1: manually copy and paste the files
- Option 2: create a symbolic link by typing the following commands on the terminal (adapt the file paths to the location of GitHub and Dropbox in your computer)
```
cd user/GitHub/supermun-dashboard
mklink /J data "C:\Users\wb501238\Dropbox\SUPERMUN dashboard\data"
```

2. Launch a new RStudio session by opening the file `supermun-dashboard.Rproj`

3. Install necessary packages: you will need to have at least `pacman` and `renv` installed in your computer for the code to run. Run [`package-installation.R`](https://github.com/dime-worldbank/supermun-dashboard/blob/main/package-installation.R) to install all necessary packages.

4. Run `code/data processing.R` to create the final data sets used in the dashboard.

5. Login to Posit Connect (can only be done from a World Bank computer connected to the intranet)
  - Open RStudio and on the top left menu, navigate to Tools > Global Options > Publishing
  - Click on "Connect" and then "Posit Connect"
  - Enter the URL to the server: w0lxopshyprd1b.worldbank.org:3939 and click "Next"
  - Follow the prompts to launch the web browser and login using your Posit Connect username (not your email) and password
  - Follow the prompts to complete the connection

## How to update the dashboard

- To update meta data such as variable units, titles, and definitions, edit the file `documentation/SUPERMUN Indicator List.csv`
- Whenever new data is added to `SUPERMUN panel.csv` or new metadata is added to `documentation/SUPERMUN Indicator List.csv`, run `code/data processing.R` to update the data used by the app
- Whenever new changes are made to the code for the dashboard, they need to be pulled from GitHub to the WB machine that will be used to publish it, and then published:
  - On GitHub Desktop, select `supermun-dashboard` under "Current repository" and `main` under "Current branch"
  - Click on "Fetch origin" and then "Pull changes"
  - Open `app/app.Rproj` and under the "Files" tab, click on `global.R`
  - Click on "Run app" on the top right corner
  - Check that all tabs in the app are rendered correctly
  - Click on "Republish" and follow the prompts on the pop-up window
